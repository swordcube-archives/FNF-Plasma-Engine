package gameplay;

import hscript.HScript;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import openfl.media.Sound;
import states.PlayState;
import systems.Conductor;
import systems.ExtraKeys;
import systems.Ranking;
import ui.NoteSplash;

using StringTools;

class StrumLine extends FlxTypedSpriteGroup<StrumNote>
{
	public var hasInput:Bool = true;

	public var keyCount:Int = 4;
	public var notes:FlxTypedGroup<Note>;

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var missSounds:Map<String, Sound> = [
		"miss1" => FNFAssets.returnAsset(SOUND, AssetPaths.sound("missnote1")),
		"miss2" => FNFAssets.returnAsset(SOUND, AssetPaths.sound("missnote2")),
		"miss3" => FNFAssets.returnAsset(SOUND, AssetPaths.sound("missnote3")),
	];

	function getSingAnimation(noteData:Int):String
	{
		var dir:String = ExtraKeys.arrowInfo[keyCount - 1][0][noteData];
		switch (dir)
		{
			case "space":
				dir = "up";
		}

		return "sing" + dir.toUpperCase();
	}

	public var judgementScript:HScript;
	public var noteSplashScript:HScript;

	public function new(x:Float, y:Float, keyCount:Int = 4)
	{
		super(x, y);

		this.keyCount = keyCount;

		notes = new FlxTypedGroup<Note>();
		generateArrows();

		judgementScript = new HScript('scripts/Judgement');
		judgementScript.start();

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		var cacheSplash:NoteSplash = new NoteSplash(100, 100, [255, 0, 0], members[0].json.splash_assets);
		cacheSplash.alpha = 0.001;
		grpNoteSplashes.add(cacheSplash);

		noteSplashScript = new HScript('scripts/NoteSplash');
		noteSplashScript.set("add", grpNoteSplashes.add);
		noteSplashScript.set("remove", grpNoteSplashes.remove);
		noteSplashScript.start();
	}

	public function generateArrows()
	{
		while (members.length > 0)
		{
			var bemb:StrumNote = members[0];
			remove(bemb, true);
			bemb.kill();
			bemb.destroy();
		}

		for (i in 0...keyCount)
		{
			var strum:StrumNote = new StrumNote((Note.swagWidth * ExtraKeys.arrowInfo[keyCount - 1][2]) * i, -10, i);
			strum.parent = this;
			strum.alpha = 0;
			var arrowSkin:String = PlayState.current != null ? PlayState.current.currentSkin.replace("default", Settings.get("Arrow Skin").toLowerCase()) : cast(Settings.get("Arrow Skin"), String).toLowerCase();
			strum.loadSkin(arrowSkin);
			strum.setColor();
			add(strum);
			FlxTween.tween(strum, {y: strum.y + 10, alpha: Settings.get("Opaque Strums") ? 1 : 0.75}, 0.5, {ease: FlxEase.circOut, startDelay: i * 0.3})
				.start();
		}
	}

	public function reloadSkin()
	{
		var arrowSkin:String = PlayState.current.currentSkin.replace("default", Settings.get("Arrow Skin").toLowerCase());
		for (bemb in members)
			bemb.loadSkin(arrowSkin);
	}

	function sortNotes(Sort:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note):Int
		return Obj1.strumTime < Obj2.strumTime ? Sort : Obj1.strumTime > Obj2.strumTime ? -Sort : 0;

	var noteSortTimer:Float = 0.0;

	var justPressed:Array<Bool> = [];
	var pressed:Array<Bool> = [];
	var justReleased:Array<Bool> = [];
	var noteDataTimes:Array<Float> = [];

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var inCutscene:Bool = PlayState.current != null ? PlayState.current.inCutscene : false;

		if (!hasInput)
		{
			for (strum in members)
			{
				if (PlayState.current != null
					&& strum.animation.curAnim != null
					&& strum.animation.curAnim.name == "confirm"
					&& strum.animation.curAnim.finished)
				{
					strum.colorSwap.enabled.value = [false];
					strum.alpha = Settings.get("Opaque Strums") ? 1 : 0.75;
					strum.playAnim("static");
				}
			}
		}

		if (PlayState.current != null)
		{
			var stepHeight = (0.45 * Conductor.stepCrochet * PlayState.SONG.speed);

			noteSortTimer += elapsed;

			if (noteSortTimer >= 1.0)
			{
				noteSortTimer = 0;
				notes.members.sort(function(Obj1:Note, Obj2:Note)
				{
					return sortNotes(FlxSort.DESCENDING, Obj1, Obj2);
				});
			}

			if (hasInput)
			{
				justPressed = [];
				pressed = [];
				justReleased = [];
				noteDataTimes = [];

				var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;
				for (i in 0...keyCount)
				{
					justPressed.push(!inCutscene ? (botPlay ? false : FlxG.keys.checkStatus(Init.keyBinds[keyCount - 1][i], JUST_PRESSED)) : false);
					pressed.push(!inCutscene ? (botPlay ? false : FlxG.keys.checkStatus(Init.keyBinds[keyCount - 1][i], PRESSED)) : false);
					justReleased.push(!inCutscene ? (botPlay ? false : FlxG.keys.checkStatus(Init.keyBinds[keyCount - 1][i], JUST_RELEASED)) : false);
					noteDataTimes.push(-1);
				}
			}

			var possibleNotes:Array<Note> = [];
			notes.forEachAlive(function(note:Note)
			{
				if (note.noteData < 0)
					return;

				note.x = members[note.noteData].x;

				var scrollAmount:Float = (note.isDownScroll ? 0.45 : -0.45);
				var cum:Float = (note.isDownScroll ? note.noteYOff : -note.noteYOff);
				note.y = members[note.noteData].y + (scrollAmount * (Conductor.position - note.strumTime) * PlayState.current.scrollSpeed) - cum;

				if (hasInput)
				{
					var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;
					if (!botPlay && (Conductor.position - note.strumTime) > Conductor.safeZoneOffset)
					{
						PlayState.current.vocals.volume = 0;
						if(!PlayState.current.customHealth) {
							PlayState.current.health -= PlayState.current.healthLoss;
							boundHealth();
						}

						if (!note.isSustain)
						{
							PlayState.current.combo = 0;
							PlayState.current.songMisses++;

							PlayState.current.songScore -= 10; // i forgor to put this here 💀💀💀💀💀

							FlxG.sound.play(missSounds["miss" + FlxG.random.int(1, 3)], FlxG.random.float(0.1, 0.2));

							PlayState.current.totalNotes++;
							PlayState.current.calculateAccuracy();

							PlayState.current.callOnHScripts("noteMiss", [note]);
							PlayState.current.UI.healthBarScript.call("updateScoreText");
						}

						if (note.canBeHit && PlayState.current.bf != null)
						{
							PlayState.current.bf.playAnim(getSingAnimation(note.noteData) + "miss", true);

							for (c in PlayState.current.bfs)
							{
								if (PlayState.current.bf.animation.curAnim.name != null && c != null && c.animation.curAnim != null)
								{
									c.holdTimer = 0.0;
									c.playAnim(PlayState.current.bf.animation.curAnim.name, true);
								}
							}
						}

						notes.forEachAlive(function(deezNote:Note)
						{
							if (deezNote.isSustain && deezNote.sustainParent == note)
								deezNote.canBeHit = false;
						});
						note.kill();
						note.destroy();
						notes.remove(note, true);
					}

					// Make the note possible to hit if it's in the safe zone to be hit.
					var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;
					if (note.canBeHit && ((Conductor.position - note.strumTime) >= (botPlay ? 0.0 : -Conductor.safeZoneOffset)))
					{
						possibleNotes.push(note);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
					}
				}
				else
				{
					if ((Conductor.position - note.strumTime) >= 0.0)
					{
						if (PlayState.current.dad != null)
						{
							PlayState.current.dad.holdTimer = 0.0;
							if (note.altAnim && PlayState.current.dad.animation.exists(getSingAnimation(note.noteData) + "-alt"))
								PlayState.current.dad.playAnim(getSingAnimation(note.noteData) + "-alt", true);
							else
								PlayState.current.dad.playAnim(getSingAnimation(note.noteData), true);

							for (c in PlayState.current.dads)
							{
								if (PlayState.current.dad.animation.curAnim != null && c != null && c.animation.curAnim != null)
								{
									c.holdTimer = 0.0;
									c.playAnim(PlayState.current.dad.animation.curAnim.name, true);
								}
							}
						}

						PlayState.current.vocals.volume = 1;
						members[note.noteData].alpha = 1;
						members[note.noteData].colorSwap.setColors(note.theColor[0], note.theColor[1], note.theColor[2]);
						members[note.noteData].colorSwap.enabled.value = [true];
						members[note.noteData].playAnim("confirm", true);

						PlayState.current.callOnHScripts("opponentNoteHit", [note]);

						note.kill();
						note.destroy();
						notes.remove(note, true);
					}
				}
			});

			if (hasInput)
			{
				var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;

				var i:Int = 0;
				for (strum in members)
				{
					if (justPressed[i] && !inCutscene && !botPlay)
					{
						if (!Settings.get("Ghost Tapping") && possibleNotes.length <= 0)
						{
							if(!PlayState.current.customHealth) {
								PlayState.current.health -= PlayState.current.healthLoss;
								boundHealth();
							}

							PlayState.current.combo = 0;
							PlayState.current.songMisses++;

							FlxG.sound.play(missSounds["miss" + FlxG.random.int(1, 3)], FlxG.random.float(0.1, 0.2));

							PlayState.current.totalNotes++;
							PlayState.current.calculateAccuracy();

							PlayState.current.UI.healthBarScript.call("updateScoreText");
						}

						strum.colorSwap.enabled.value = [true];
						strum.playAnim("press", true);
						strum.alpha = 1;
					}

					if ((justReleased[i] && !inCutscene && !botPlay)
						|| (botPlay
							&& strum.animation.curAnim != null
							&& strum.animation.curAnim.name == "confirm"
							&& strum.animation.curAnim.finished))
					{
						strum.colorSwap.enabled.value = [false];
						strum.playAnim("static", true);
						strum.alpha = Settings.get("Opaque Strums") ? 1 : 0.75;
					}

					i++;
				}

				if (possibleNotes.length > 0)
				{
					for (note in possibleNotes)
					{
						// If we're not sending inputs to the keyboard, why even try to do input?
						if (!pressed.contains(true) && !botPlay)
							break;

						// Check if we just pressed the keybind the note has and if we're allowed to hit the note
						// If both are true, then we delete the note.

						if ((justPressed[note.noteData] || botPlay) && !note.isSustain && noteDataTimes[note.noteData] == -1)
						{
							PlayState.current.vocals.volume = 1;
							justPressed[note.noteData] = false;
							noteDataTimes[note.noteData] = note.strumTime;

							members[note.noteData].alpha = 1;
							members[note.noteData].colorSwap.setColors(note.theColor[0], note.theColor[1], note.theColor[2]);
							members[note.noteData].colorSwap.enabled.value = [true];
							members[note.noteData].playAnim("confirm", true);
							goodNoteHit(note);
						}
						else if (!note.isSustain && Math.abs(note.strumTime - noteDataTimes[note.noteData]) <= 5)
						{
							// we hate stacked notes >:((((
							possibleNotes.remove(note);
							notes.remove(note, true);
							note.kill();
							note.destroy();
						}

						if ((pressed[note.noteData] || botPlay) && note.isSustain && (Conductor.position - note.strumTime) >= 0.0)
						{
							PlayState.current.vocals.volume = 1;
							if(!PlayState.current.customHealth) {
								PlayState.current.health += PlayState.current.healthGain;
								boundHealth();
							}
							members[note.noteData].alpha = 1;
							members[note.noteData].colorSwap.setColors(note.theColor[0], note.theColor[1], note.theColor[2]);
							members[note.noteData].colorSwap.enabled.value = [true];
							members[note.noteData].playAnim("confirm", true);
							note.kill();
							note.destroy();
							notes.remove(note, true);
							if (PlayState.current.bf != null && !PlayState.current.bf.specialAnim)
							{
								PlayState.current.bf.holdTimer = 0.0;
								if (note.altAnim && PlayState.current.bf.animation.exists(getSingAnimation(note.noteData) + "-alt"))
									PlayState.current.bf.playAnim(getSingAnimation(note.noteData) + "-alt", true);
								else
									PlayState.current.bf.playAnim(getSingAnimation(note.noteData), true);

								for (c in PlayState.current.bfs)
								{
									if (PlayState.current.bf.animation.curAnim != null && c != null && c.animation.curAnim != null)
									{
										c.holdTimer = 0.0;
										c.playAnim(PlayState.current.bf.animation.curAnim.name, true);
									}
								}
							}
						}
					}
				}

				if (PlayState.current != null
					&& PlayState.current.bf != null
					&& PlayState.current.bf.animation.curAnim != null
					&& PlayState.current.bf.holdTimer > Conductor.stepCrochet * PlayState.current.bf.singDuration * 0.001
					&& !pressed.contains(true))
				{
					if (PlayState.current.bf.animation.curAnim.name.startsWith('sing')
						&& !PlayState.current.bf.animation.curAnim.name.endsWith('miss'))
					{
						PlayState.current.bf.dance();

						for (c in PlayState.current.bfs)
						{
							if (PlayState.current.bf.animation.curAnim.name != null && c != null && c.animation.curAnim != null)
							{
								c.holdTimer = 0.0;
								c.playAnim(PlayState.current.bf.animation.curAnim.name, true);
							}
						}
					}
				}
			}

			var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;
			notes.forEachAlive(function(note:Note)
			{
				if (note.isDownScroll)
				{
					if (note.isSustain)
					{
						note.y -= note.height - stepHeight;

						if ((botPlay || !hasInput || (hasInput && note.canBeHit && pressed[note.noteData]))
							&& note.y - note.offset.y * note.scale.y + note.height >= (this.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							var swagRect = new FlxRect(0, 0, note.frameWidth * 2, note.frameHeight * 2);
							swagRect.height = (members[note.noteData].y + Note.swagWidth / 2 - note.y) / note.scale.y;
							swagRect.y = note.frameHeight - swagRect.height;

							note.clipRect = swagRect;
						}
					}
				}
				else
				{
					if (note.isSustain)
					{
						note.y += 5;

						if ((botPlay || !hasInput || (hasInput && note.canBeHit && pressed[note.noteData]))
							&& note.y + note.offset.y * note.scale.y <= (this.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							var swagRect = new FlxRect(0, 0, note.width / note.scale.x, note.height / note.scale.y);
							swagRect.y = (members[note.noteData].y + Note.swagWidth / 2 - note.y) / note.scale.y;
							swagRect.height -= swagRect.y;

							note.clipRect = swagRect;
						}
					}
				}
			});
		}

		for (i in 0...justPressed.length)
		{
			justPressed[i] = false;
		}

		for (i in 0...justReleased.length)
		{
			justReleased[i] = false;
		}
	}

	function goodNoteHit(note:Note)
	{
		var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;

		PlayState.current.totalNotes++;

		var judgement:String = Ranking.judgeNote(note.strumTime);
		var judgeData:Judgement = Ranking.getInfo(botPlay ? "marvelous" : judgement);

		if (!botPlay)
			PlayState.current.songScore += judgeData.score;

		PlayState.current.totalHit += judgeData.mod;
		if (judgement != "bad" && !PlayState.current.customHealth)
			PlayState.current.health += PlayState.current.healthGain;

		if(!PlayState.current.customHealth) {
			PlayState.current.health += judgeData.health;
			boundHealth();
		}

		if (Settings.get("Note Splashes") && judgeData.noteSplash)
			noteSplashScript.call("spawnSplash", [
				members[note.noteData].x,
				members[note.noteData].y,
				note.theColor,
				members[note.noteData].json.splash_assets
			]);

		PlayState.current.calculateAccuracy();

		PlayState.current.combo++;

		judgementScript.call("popUpScore", [
			judgeData.name,
			PlayState.current.combo,
			PlayState.current.ratingScale,
			PlayState.current.comboScale
		]);

		PlayState.current.UI.healthBarScript.call("updateScoreText");

		if (PlayState.current.bf != null && !PlayState.current.bf.specialAnim)
		{
			PlayState.current.bf.holdTimer = 0.0;
			if (note.altAnim && PlayState.current.bf.animation.exists(getSingAnimation(note.noteData) + "-alt"))
				PlayState.current.bf.playAnim(getSingAnimation(note.noteData) + "-alt", true);
			else
				PlayState.current.bf.playAnim(getSingAnimation(note.noteData), true);

			for (c in PlayState.current.bfs)
			{
				if (PlayState.current.bf.animation.curAnim != null && c != null && c.animation.curAnim != null)
				{
					c.holdTimer = 0.0;
					c.playAnim(PlayState.current.bf.animation.curAnim.name, true);
				}
			}
		}

		PlayState.current.callOnHScripts("goodNoteHit", [note]);
		PlayState.current.callOnHScripts("playerNoteHit", [note]);

		note.kill();
		note.destroy();
		notes.remove(note, true);
	}

	function boundHealth()
		PlayState.current.health = FlxMath.bound(PlayState.current.health, PlayState.current.minHealth, PlayState.current.maxHealth);
}

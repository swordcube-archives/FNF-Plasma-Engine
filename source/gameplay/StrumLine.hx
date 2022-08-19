package gameplay;

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
import ui.JudgementUI;
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

	public function new(x:Float, y:Float, keyCount:Int = 4)
	{
		super(x, y);

		this.keyCount = keyCount;

		notes = new FlxTypedGroup<Note>();

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		splash.kill();
		grpNoteSplashes.add(splash);

		generateArrows();
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
			var arrowSkin:String = (PlayState.current != null
				&& PlayState.current.currentSkin != "default") ? PlayState.current.currentSkin : cast(Settings.get("Arrow Skin"), String).toLowerCase();
			strum.loadSkin(arrowSkin);
			add(strum);
			FlxTween.tween(strum, {y: strum.y + 10, alpha: Settings.get("Opaque Strums") ? 1 : 0.75}, 0.5,
				{ease: FlxEase.circOut, startDelay: i * 0.3})
				.start();
		}
	}

	public function reloadSkin()
	{
		var arrowSkin:String = PlayState.current.currentSkin != "default" ? PlayState.current.currentSkin : cast(Settings.get("Arrow Skin"), String).toLowerCase();
		for (bemb in members)
			bemb.loadSkin(arrowSkin);
	}

	function sortNotes(Sort:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note):Int
		return Obj1.strumTime < Obj2.strumTime ? Sort : Obj1.strumTime > Obj2.strumTime ? -Sort : 0;

	var noteSortTimer:Float = 0.0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var inCutscene:Bool = PlayState.current != null ? PlayState.current.inCutscene : false;

		grpNoteSplashes.forEachDead(function(sprite:NoteSplash)
		{
            if (grpNoteSplashes.length > 1)
            {
                grpNoteSplashes.remove(sprite, true);
                sprite.kill();
                sprite.destroy();
            }
		});

		if (!hasInput)
		{
			for (strum in members)
			{
				if (PlayState.current != null
					&& strum.animation.curAnim != null
					&& strum.animation.curAnim.name == "confirm"
					&& strum.animation.curAnim.finished)
				{
					strum.resetColor();
					strum.colorSwap.enabled.value = [false];
					strum.alpha = Settings.get("Opaque Strums") ? 1 : 0.75;
					strum.playAnim("static");
				}
			}
		}

		if (PlayState.current != null)
		{
			var stepHeight = (0.45 * Conductor.stepCrochet * PlayState.current.scrollSpeed);

			noteSortTimer += elapsed;

			if (noteSortTimer >= 1.0)
			{
				noteSortTimer = 0;
				notes.members.sort(function(Obj1:Note, Obj2:Note)
				{
					return sortNotes(FlxSort.DESCENDING, Obj1, Obj2);
				});
			}

            var justPressed:Array<Bool> = [];
            var pressed:Array<Bool> = [];
            var noteDataTimes:Array<Float> = [];

            if(hasInput)
            {
                justPressed = [];
                pressed = [];
                noteDataTimes = [];

                var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;
                for(i in 0...keyCount)
                {
                    justPressed.push(!inCutscene ? (botPlay ? false : FlxG.keys.checkStatus(Init.keyBinds[keyCount-1][i], JUST_PRESSED)) : false);
                    pressed.push(!inCutscene ? (botPlay ? false : FlxG.keys.checkStatus(Init.keyBinds[keyCount-1][i], PRESSED)) : false);
                    noteDataTimes.push(-1);
                }
			}

			var possibleNotes:Array<Note> = [];
			notes.forEachAlive(function(note:Note)
			{
				if (note.noteData < 0)
					return;
				
				note.x = members[note.noteData].x;

				var scrollAmount:Float = (note.isDownScroll ? -1 : 1) * 0.45;
				note.y = members[note.noteData].y - (scrollAmount * (Conductor.position - note.strumTime) * PlayState.current.scrollSpeed);

				if (hasInput)
				{
					var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;
					if (!botPlay && (Conductor.position - note.strumTime) > Conductor.safeZoneOffset)
					{
						PlayState.current.vocals.volume = 0;
						PlayState.current.health -= PlayState.current.healthLoss;
						boundHealth();

						if (!note.isSustain)
						{
							PlayState.current.combo = 0;
							PlayState.current.songMisses++;

							FlxG.sound.play(missSounds["miss" + FlxG.random.int(1, 3)], FlxG.random.float(0.1, 0.2));

                            PlayState.current.totalNotes++;
                            PlayState.current.calculateAccuracy();

							PlayState.current.UI.healthBarScript.call("updateScoreText");
						}

						if (note.canBeHit && PlayState.current.bf != null)
							PlayState.current.bf.playAnim(getSingAnimation(note.noteData) + "miss", true);

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
                    if((pressed.contains(true) || botPlay) && note.canBeHit && ((Conductor.position - note.strumTime) >= (botPlay ? 0.0 : -Conductor.safeZoneOffset)))
					{
                        possibleNotes.push(note);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
					}
                }
                else
                {
                    if((Conductor.position - note.strumTime) >= 0.0)
                    {
                        if(PlayState.current.dad != null)
                        {
                            PlayState.current.dad.holdTimer = 0.0;
                            if(note.altAnim && PlayState.current.dad.animation.exists(getSingAnimation(note.noteData)+"-alt"))
                                PlayState.current.dad.playAnim(getSingAnimation(note.noteData)+"-alt", true);
                            else
                                PlayState.current.dad.playAnim(getSingAnimation(note.noteData), true);
                        }
                        
                        PlayState.current.vocals.volume = 1;
                        members[note.noteData].alpha = 1;
                        members[note.noteData].setColor();
                        members[note.noteData].colorSwap.enabled.value = [true];
                        members[note.noteData].playAnim("confirm", true);

                        PlayState.current.callOnHScripts("opponentNoteHit", [note]);

                        note.kill();
                        note.destroy();
                        notes.remove(note, true);
                    }
                }
            });



            if(hasInput)
            {
				var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;

                var i:Int = 0;
                for(strum in members)
                {
                    var key:FlxKey = Init.keyBinds[keyCount-1][i];
                    if(FlxG.keys.checkStatus(key, JUST_PRESSED) && !inCutscene && !botPlay)
                    {
                        if(!Settings.get("Ghost Tapping") && possibleNotes.length <= 0)
                        {
                            PlayState.current.health -= PlayState.current.healthLoss;
                            
                            PlayState.current.combo = 0;
                            PlayState.current.songMisses++;

							FlxG.sound.play(missSounds["miss" + FlxG.random.int(1, 3)], FlxG.random.float(0.1, 0.2));

							PlayState.current.totalNotes++;
							PlayState.current.calculateAccuracy();

							PlayState.current.UI.healthBarScript.call("updateScoreText");
						}

                        strum.setColor();
                        strum.colorSwap.enabled.value = [true];
                        strum.playAnim("press", true);
                        strum.alpha = 1;
                    }
    
                    if((FlxG.keys.checkStatus(key, JUST_RELEASED) && !inCutscene && !botPlay) || (botPlay && strum.animation.curAnim != null && strum.animation.curAnim.name == "confirm" && strum.animation.curAnim.finished))
                    {
                        strum.colorSwap.enabled.value = [false];
                        strum.resetColor();
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
						if(!pressed.contains(true))
							break;

						// Check if we just pressed the keybind the note has and if we're allowed to hit the note
						// If both are true, then we delete the note.

						if ((justPressed[note.noteData] || botPlay) && !note.isSustain)
						{
							PlayState.current.vocals.volume = 1;
							justPressed[note.noteData] = false;
                            noteDataTimes[note.noteData] = note.strumTime;

							members[note.noteData].alpha = 1;
							members[note.noteData].setColor();
							members[note.noteData].colorSwap.enabled.value = [true];
							members[note.noteData].playAnim("confirm", true);
							goodNoteHit(note);
						}

						if ((pressed[note.noteData] || botPlay) && note.isSustain && (Conductor.position - note.strumTime) >= 0.0)
						{
							PlayState.current.vocals.volume = 1;
							PlayState.current.health += PlayState.current.healthGain;
							boundHealth();
							members[note.noteData].alpha = 1;
							members[note.noteData].setColor();
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
							}
						}
					}

                    // we hate stacked notes!
                    for(note in possibleNotes) {
                        if(!note.isSustain && note.strumTime == noteDataTimes[note.noteData])
                        {
                            possibleNotes.remove(note);
                            notes.remove(note, true);
                            note.kill();
                            note.destroy();
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
						PlayState.current.bf.dance();
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
						note.y += 10;

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
						note.y += 10;

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
	}

	function goodNoteHit(note:Note)
	{
		var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;

        PlayState.current.health += PlayState.current.healthGain;

		PlayState.current.totalNotes++;

		var judgement:String = Ranking.judgeNote(note.strumTime);
		var judgeData:Judgement = Ranking.getInfo(botPlay ? "marvelous" : judgement);

		if (!botPlay)
			PlayState.current.songScore += judgeData.score;

		PlayState.current.totalHit += judgeData.mod;
		PlayState.current.health += judgeData.health;
		boundHealth();

		if (Settings.get("Note Splashes") && judgeData.noteSplash)
		{
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.alpha = 1;
			splash.setupNoteSplash(members[note.noteData].x, members[note.noteData].y, members[note.noteData].json.splash_assets, note.noteData);
			grpNoteSplashes.add(splash);
		}

		PlayState.current.calculateAccuracy();

		PlayState.current.combo++;

		var judgeUI:JudgementUI = new JudgementUI(judgement, PlayState.current.combo, PlayState.current.ratingScale, PlayState.current.comboScale);
		PlayState.current.insert(PlayState.current.members.length + 1, judgeUI);

        PlayState.current.UI.healthBarScript.call("updateScoreText");

        if(PlayState.current.bf != null && !PlayState.current.bf.specialAnim)
        {
            PlayState.current.bf.holdTimer = 0.0;
            if(note.altAnim && PlayState.current.bf.animation.exists(getSingAnimation(note.noteData)+"-alt"))
                PlayState.current.bf.playAnim(getSingAnimation(note.noteData)+"-alt", true);
            else
                PlayState.current.bf.playAnim(getSingAnimation(note.noteData), true);
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

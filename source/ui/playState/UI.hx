package ui.playState;

import base.Conductor;
import base.Controls;
import base.ManiaShit;
import base.Ranking;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import haxe.Json;
import states.PlayState;
import ui.playState.StrumNote;

using StringTools;

class UI extends FlxGroup
{
	public var defaultStrumY:Float = 50;

	// Strum Lines
	public var opponentStrums:StrumLine;
	public var playerStrums:StrumLine;

	// Notes
	public var notes:FlxTypedGroup<Note>;

	// Health Bar & Icons
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var iconP2:HealthIcon;
	public var iconP1:HealthIcon;

	// Text
	public var scoreTxt:FlxText;

	// Ratings
	public var ratings:FlxTypedGroup<FlxSprite>;

	// Extra Variables
	public var downscroll:Bool = Init.getOption('downscroll');

	// Miss Sounds
	public var missSounds:Map<String, Dynamic> = new Map<String, Dynamic>();

	// Functions
	public function new()
	{
		super();

		// Strum Lines
		var xMult:Float = 85;

		if (downscroll == true)
			defaultStrumY = FlxG.height - 150;

		var uiSkin:String = PlayState.instance.uiSkin;

		opponentStrums = new StrumLine(xMult, defaultStrumY, uiSkin, 4);
		add(opponentStrums);

		playerStrums = new StrumLine((FlxG.width / 2) + xMult, defaultStrumY, uiSkin, 4);
		add(playerStrums);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		ratings = new FlxTypedGroup<FlxSprite>();
		add(ratings);

		// Health Bar
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(GenesisAssets.getAsset('ui/healthBar', IMAGE));
		healthBarBG.screenCenter(X);
		if (downscroll == true)
			healthBarBG.y = 60;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8),
			PlayState.instance, 'health', PlayState.instance.minHealth, PlayState.instance.maxHealth);
		healthBar.scrollFactor.set();
		var colors:Array<FlxColor> = [
			FlxColor.fromString(PlayState.instance.dad.healthBarColor),
			FlxColor.fromString(PlayState.instance.bf.healthBarColor)
		];
		healthBar.createFilledBar(colors[0], colors[1]);
		add(healthBar);

		// Icons
		iconP2 = new HealthIcon(PlayState.instance.dad.healthIcon);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		iconP1 = new HealthIcon(PlayState.instance.bf.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		scoreTxt = new FlxText(0, healthBarBG.y + 35, 0, "", 16);
		scoreTxt.setFormat(GenesisAssets.getAsset('vcr.ttf', FONT), 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(scoreTxt);

		var cacheSplash:NoteSplash = new NoteSplash(100, 100, "A");
		cacheSplash.alpha = 0.01;
		add(cacheSplash);

		missSounds.set('missnote1', GenesisAssets.getAsset('missnote1', SOUND));
		missSounds.set('missnote2', GenesisAssets.getAsset('missnote2', SOUND));
		missSounds.set('missnote3', GenesisAssets.getAsset('missnote3', SOUND));
	}

	var physicsUpdateTimer:Float = 0;

	public var justPressed:Array<Bool> = [];
	public var pressed:Array<Bool> = [];
	public var released:Array<Bool> = [];

	public function calculateAccuracy()
	{
		if (PlayState.instance.totalHit != 0 && PlayState.instance.totalNotes != 0)
			PlayState.instance.songAccuracy = (PlayState.instance.totalHit / PlayState.instance.totalNotes);
		else
			PlayState.instance.songAccuracy = 0;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		calculateAccuracy();

		var accuracy:Float = PlayState.instance.songAccuracy * 100;

		scoreTxt.text = ("Score: " + PlayState.instance.songScore + " // " + "Misses: " + PlayState.instance.songMisses + " // " + "Accuracy: "
			+ FlxMath.roundDecimal(accuracy, 2) + "% // " + "Rank: " + Ranking.getRank(accuracy));
		scoreTxt.screenCenter(X);

		physicsUpdateTimer += elapsed;

		if (physicsUpdateTimer > 1 / 60)
		{
			physicsUpdate();
			physicsUpdateTimer = 0;
		}

		if (healthBar.percent < 20)
			iconP1.animation.play('losing');
		else if (healthBar.percent > 80)
			iconP1.animation.play('winning');
		else
			iconP1.animation.play('normal');

		if (healthBar.percent > 80)
			iconP2.animation.play('losing');
		else if (healthBar.percent < 20)
			iconP2.animation.play('winning');
		else
			iconP2.animation.play('normal');

		opponentStrums.forEachAlive(function(strum:StrumNote)
		{
			if (strum.animation.curAnim != null)
			{
				if (strum.animFinished && strum.animation.curAnim.name == "confirm")
					strum.playAnim("static");
			}
		});

		if (Init.getOption('botplay') == true)
		{
			playerStrums.forEachAlive(function(strum:StrumNote)
			{
				if (strum.animation.curAnim != null)
				{
					if (strum.animFinished && strum.animation.curAnim.name == "confirm")
						strum.playAnim("static");
				}
			});
		}

		notes.forEachAlive(function(daNote:Note)
		{
			var scrollSpeed:Float = PlayState.instance.scrollSpeed;

			var strum:StrumNote = daNote.mustPress ? playerStrums.members[daNote.noteData] : opponentStrums.members[daNote.noteData];

			daNote.x = strum.x;

			if (daNote.isSustainNote)
			{
				if (daNote.json.skinType == "pixel")
					daNote.x += daNote.width / 1.5;
				else
					daNote.x += daNote.width;
			}

			if (daNote.downscrollNote)
				daNote.y = strum.y + (0.45 * (Conductor.songPosition - daNote.strumTime) * scrollSpeed);
			else
				daNote.y = strum.y - (0.45 * (Conductor.songPosition - daNote.strumTime) * scrollSpeed);

			var center = strum.y + (Note.swagWidth / 2);

			if (daNote.downscrollNote)
			{
				if (daNote.isSustainNote)
				{
					if (daNote.isEndOfSustain && daNote.prevNote != null)
						daNote.y += daNote.prevNote.height;
					else
						daNote.y += daNote.height / 2;

					if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
						&& (!daNote.mustPress || (pressed[daNote.noteData] || Init.getOption('botplay'))))
					{
						var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
						swagRect.height = (center - daNote.y) / daNote.scale.y;
						swagRect.y = daNote.frameHeight - swagRect.height;

						daNote.clipRect = swagRect;
					}
				}
			}
			else
			{
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y * daNote.scale.y <= center
					&& (!daNote.mustPress || (daNote.wasGoodHit || (pressed[daNote.noteData] || Init.getOption('botplay')))))
				{
					var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
					swagRect.y = (center - daNote.y) / daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}
			}

			if (!daNote.mustPress)
			{
				if (daNote.isSustainNote)
				{
					if (Conductor.songPosition >= (daNote.strumTime + (Conductor.safeZoneOffset / 4)))
					{
						killOpponentNote(daNote);
					}
				}
				else
				{
					if (Conductor.songPosition >= daNote.strumTime)
					{
						killOpponentNote(daNote);
					}
				}
			}

			if (!Init.getOption('botplay') && Conductor.songPosition - daNote.strumTime > Conductor.safeZoneOffset)
			{
				notes.remove(daNote, true);
				daNote.kill();
				daNote.destroy();

				if (!daNote.isEndOfSustain)
				{
					PlayState.instance.health -= 0.045;
					PlayState.instance.voices.volume = 0;
					PlayState.instance.songMisses++;
					PlayState.instance.songScore -= 10;
					PlayState.instance.combo = 0;
					PlayState.instance.totalNotes++;

					FlxG.sound.play(missSounds['missnote' + FlxG.random.int(1, 3)], FlxG.random.float(0.1, 0.2));

					if (!PlayState.instance.bf.specialAnim)
					{
						PlayState.instance.bf.holdTimer = 0;
						PlayState.instance.bf.playAnim(ManiaShit.singAnims[PlayState.songData.keyCount][daNote.noteData] + "miss", true);
					}
				}
			}
		});

		keyShit();
		var boyfriend = PlayState.instance.bf;
		if (pressed.contains(true))
			boyfriend.holdTimer = 0;

		if (!pressed.contains(true)
			&& boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration
			&& boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			boyfriend.dance();
	}

	function killOpponentNote(daNote:Note)
	{
		PlayState.instance.voices.volume = 1;

		PlayState.instance.dad.holdTimer = 0;
		PlayState.instance.dad.playAnim(ManiaShit.singAnims[PlayState.songData.keyCount][daNote.noteData], true);

		opponentStrums.members[daNote.noteData].playAnim("confirm", true);
		notes.remove(daNote, true);
		daNote.kill();
		daNote.destroy();
	}

	function keyShit()
	{
		var keyCount:Int = PlayState.songData.keyCount;

		var testBinds:Array<FlxKey> = Controls.gameControls.get(keyCount + "_key")[0];
		var testBindsAlt:Array<FlxKey> = Controls.gameControls.get(keyCount + "_key")[1];

		justPressed = [];
		pressed = [];
		released = [];

		for (i in 0...keyCount)
		{
			justPressed.push(false);
			pressed.push(false);
			released.push(false);
		}

		for (i in 0...testBinds.length)
		{
			justPressed[i] = testBinds[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBinds[i], FlxInputState.JUST_PRESSED) : false;
			pressed[i] = testBinds[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBinds[i], FlxInputState.PRESSED) : false;
			released[i] = testBinds[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBinds[i], FlxInputState.RELEASED) : false;

			if (released[i] == true)
			{
				justPressed[i] = testBindsAlt[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBindsAlt[i], FlxInputState.JUST_PRESSED) : false;
				pressed[i] = testBindsAlt[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBindsAlt[i], FlxInputState.PRESSED) : false;
				released[i] = testBindsAlt[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBindsAlt[i], FlxInputState.RELEASED) : false;
			}
		}

		if (Init.getOption('botplay') != true)
		{
			for (i in 0...justPressed.length)
			{
				if (justPressed[i])
				{
					playerStrums.members[i].playAnim("press", true);
				}
			}

			for (i in 0...released.length)
			{
				if (released[i])
				{
					playerStrums.members[i].playAnim("static");
				}
			}
		}

		var possibleNotes:Array<Note> = [];

		notes.forEach(function(note:Note)
		{
			note.calculateCanBeHit();

			if (Init.getOption('botplay') != true)
			{
				if (note.canBeHit && note.mustPress && !note.tooLate && !note.isSustainNote)
					possibleNotes.push(note);
			}
			else
			{
				if ((!note.isSustainNote ? note.strumTime : note.strumTime + (Conductor.safeZoneOffset / 4)) <= Conductor.songPosition && note.mustPress)
					possibleNotes.push(note);
			}
		});

		possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dontHitTheseDirectionsLol:Array<Bool> = [];
		var noteDataTimes:Array<Float> = [];

		for (i in 0...keyCount)
		{
			dontHitTheseDirectionsLol.push(false);
			noteDataTimes.push(-1);
		}

		if (possibleNotes.length > 0)
		{
			for (i in 0...possibleNotes.length)
			{
				var note = possibleNotes[i];

				if (((justPressed[note.noteData] && !dontHitTheseDirectionsLol[note.noteData]) && Init.getOption('botplay') != true)
					|| Init.getOption('botplay') == true)
				{
					if (!note.isSustainNote)
					{
						playerStrums.members[note.noteData].playAnim("confirm", true);
						dontHitTheseDirectionsLol[note.noteData] = true;
						noteDataTimes[note.noteData] = note.strumTime;

						goodNoteHit(note);
					}
				}
			}

			for (i in 0...possibleNotes.length)
			{
				var note = possibleNotes[i];

				if (note.strumTime == noteDataTimes[note.noteData] && dontHitTheseDirectionsLol[note.noteData])
				{
					notes.remove(note);
					note.kill();
					note.destroy();
				}
			}
		}

		notes.forEach(function(note:Note)
		{
			if (note.isSustainNote && note.mustPress)
			{
				if ((pressed[note.noteData] || Init.getOption('botplay') == true)
					&& Conductor.songPosition >= note.strumTime + (Conductor.safeZoneOffset / 4))
				{
					if (!PlayState.instance.bf.specialAnim)
					{
						PlayState.instance.bf.holdTimer = 0;
						PlayState.instance.bf.playAnim(ManiaShit.singAnims[PlayState.songData.keyCount][note.noteData], true);
					}

					playerStrums.members[note.noteData].playAnim("confirm", true);
					PlayState.instance.health += 0.023;

					PlayState.instance.voices.volume = 1;
					note.wasGoodHit = true;
					notes.remove(note, true);
					note.kill();
					note.destroy();
				}
			}
		});
	}

	public function physicsUpdate()
	{
		var scale = FlxMath.lerp(iconP2.scale.x, 1, 0.2);

		iconP2.scale.set(scale, scale);
		iconP2.updateHitbox();

		iconP1.scale.set(scale, scale);
		iconP1.updateHitbox();

		positionIcons();
	}

	public function beatHit()
	{
		iconP2.scale.set(1.2, 1.2);
		iconP2.updateHitbox();

		iconP1.scale.set(1.2, 1.2);
		iconP1.updateHitbox();

		positionIcons();
	}

	public function positionIcons()
	{
		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
	}

	public function stepHit()
	{
		// this might never do anything, but idk yet
	}

	public function goodNoteHit(daNote:Note)
	{
		if (!daNote.wasGoodHit)
		{
			daNote.wasGoodHit = true;

			PlayState.instance.combo++;
			popUpScore(daNote.strumTime, daNote);

			PlayState.instance.voices.volume = 1;
			PlayState.instance.health += 0.023;

			if (!PlayState.instance.bf.specialAnim)
			{
				PlayState.instance.bf.holdTimer = 0;
				PlayState.instance.bf.playAnim(ManiaShit.singAnims[PlayState.songData.keyCount][daNote.noteData], true);
			}

			notes.remove(daNote, true);
			daNote.kill();
			daNote.destroy();
		}
	}

	public function popUpScore(strumTime:Float, daNote:Note)
	{
		// Accuracy Shit
		var ratingStr:String = Ranking.judgeNote(strumTime);

		switch (ratingStr)
		{
			case "marvelous" | "sick":
				PlayState.instance.songScore += Ranking.getRatingScore(ratingStr);
				PlayState.instance.totalHit += 1;

				if (!Init.getOption('disable-note-splashes'))
				{
					var strum:StrumNote = playerStrums.members[daNote.noteData];
					var newSplash:NoteSplash = new NoteSplash(strum.x, strum.y, ManiaShit.letterDirections[PlayState.songData.keyCount][daNote.noteData]);
					add(newSplash);
				}
			case "good":
				PlayState.instance.songScore += Ranking.getRatingScore(ratingStr);
				PlayState.instance.totalHit += 0.7;
			case "bad":
				PlayState.instance.songScore += Ranking.getRatingScore(ratingStr);
				PlayState.instance.totalHit += 0.45;
			case "shit":
				PlayState.instance.health -= 0.15;
				PlayState.instance.songScore += Ranking.getRatingScore(ratingStr);
		}

		PlayState.instance.totalNotes += 1;

		// Spawning the Rating & Combo
		var coolObject:FlxObject = new FlxObject(FlxG.width * 0.35);
		coolObject.screenCenter(Y);

		var json:ArrowSkin = Json.parse(GenesisAssets.getAsset('images/ui/skins/${PlayState.instance.uiSkin}/config.json', TEXT));

		var loadedGraphics:Map<String, Dynamic> = [
			"marvelous" => GenesisAssets.getAsset('ui/skins/${json.ratingSkin}/ratings/marvelous', IMAGE),
			"sick" => GenesisAssets.getAsset('ui/skins/${json.ratingSkin}/ratings/sick', IMAGE),
			"good" => GenesisAssets.getAsset('ui/skins/${json.ratingSkin}/ratings/good', IMAGE),
			"bad" => GenesisAssets.getAsset('ui/skins/${json.ratingSkin}/ratings/bad', IMAGE),
			"shit" => GenesisAssets.getAsset('ui/skins/${json.ratingSkin}/ratings/shit', IMAGE),
		];

		var rating:FlxSprite = new FlxSprite(coolObject.x - 40, coolObject.y - 60);
		rating.loadGraphic(loadedGraphics[ratingStr]);
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		rating.setGraphicSize(Std.int(rating.width * json.ratingScale));
		rating.updateHitbox();

		ratings.add(rating);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onComplete: function(twn:FlxTween)
			{
				ratings.remove(rating, true);
				rating.kill();
				rating.destroy();
			}
		});

		var seperatedScore:Array<Int> = [];

		if (PlayState.instance.combo >= 1000)
			seperatedScore.push(Math.floor(PlayState.instance.combo / 1000) % 10);

		seperatedScore.push(Math.floor(PlayState.instance.combo / 100) % 10);
		seperatedScore.push(Math.floor(PlayState.instance.combo / 10) % 10);
		seperatedScore.push(PlayState.instance.combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite();
			numScore.loadGraphic(GenesisAssets.getAsset('ui/skins/${json.comboSkin}/combo/num${Std.int(i)}', IMAGE));
			numScore.x = coolObject.x + (43 * daLoop) - 90;
			numScore.y = coolObject.y + 80;
			numScore.setGraphicSize(Std.int(numScore.width * json.comboScale));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			ratings.add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					ratings.remove(numScore, true);
					numScore.kill();
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
	}
}

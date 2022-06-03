package ui.playState;

import base.Conductor;
import base.Controls;
import base.Ranking;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import states.PlayState;

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

    // Extra Variables
    public var downscroll:Bool = Init.getOption('downscroll');

    // Functions
    public function new()
    {
        super();
        
        // Strum Lines
		var xMult:Float = 85;

		if(downscroll == true)
			defaultStrumY = FlxG.height - 150;

        var uiSkin:String = PlayState.instance.uiSkin;

        opponentStrums = new StrumLine(xMult, defaultStrumY, uiSkin, 4);
        add(opponentStrums);

        playerStrums = new StrumLine((FlxG.width / 2) + xMult, defaultStrumY, uiSkin, 4);
        add(playerStrums);

        notes = new FlxTypedGroup<Note>();
        add(notes);

        // Health Bar
        healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(GenesisAssets.getAsset('ui/healthBar', IMAGE));
		healthBarBG.screenCenter(X);
        if(downscroll == true)
            healthBarBG.y = 60;
        add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), PlayState.instance,
			'health', PlayState.instance.minHealth, PlayState.instance.maxHealth);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

        // Icons
        iconP2 = new HealthIcon(PlayState.songData.player2);
        iconP2.y = healthBar.y - (iconP2.height / 2);
        add(iconP2);

        iconP1 = new HealthIcon(PlayState.songData.player1, true);
        iconP1.y = healthBar.y - (iconP1.height / 2);
        add(iconP1);

        scoreTxt = new FlxText(0, healthBarBG.y + 35, 0, "", 16);
        scoreTxt.setFormat(GenesisAssets.getAsset('vcr.ttf', FONT), 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        add(scoreTxt);
    }

    var physicsUpdateTimer:Float = 0;

	public var justPressed:Array<Bool> = [];
	public var pressed:Array<Bool> = [];
	public var released:Array<Bool> = [];

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var accuracy:Float = PlayState.instance.songAccuracy * 100;

        scoreTxt.text = (
            "Score: " + PlayState.instance.songScore + " // " +
            "Misses: " + PlayState.instance.songMisses + " // " +
            "Accuracy: " + FlxMath.roundDecimal(accuracy, 2) + "% // " +
            "Rank: " + Ranking.getRank(accuracy)
        );
        scoreTxt.screenCenter(X);

		physicsUpdateTimer += elapsed;
        
		if(physicsUpdateTimer > 1 / 60)
		{
			physicsUpdate();
			physicsUpdateTimer = 0;
		}

        opponentStrums.forEachAlive(function(strum:StrumNote) {
            if(strum.animation.curAnim != null)
            {
                if(strum.animFinished && strum.animation.curAnim.name == "confirm")
                    strum.playAnim("static");
            }
        });

        if(Init.getOption('botplay') == true)
        {
            playerStrums.forEachAlive(function(strum:StrumNote) {
                if(strum.animation.curAnim != null)
                {
                    if(strum.animFinished && strum.animation.curAnim.name == "confirm")
                        strum.playAnim("static");
                }
            });
        }

        notes.forEachAlive(function(daNote:Note) {
            var scrollSpeed:Float = PlayState.instance.scrollSpeed;

            var strum:StrumNote = daNote.mustPress ? playerStrums.members[daNote.noteData] : opponentStrums.members[daNote.noteData];
            
            daNote.x = strum.x;

            if(daNote.isSustainNote)
            {
                if(daNote.json.skinType == "pixel")
                    daNote.x += daNote.width / 1.5;
                else
                    daNote.x += daNote.width;
            }

            daNote.y = strum.y - (0.45 * (Conductor.songPosition - daNote.strumTime) * scrollSpeed);
            var center = strum.y + (Note.swagWidth / 2);

            if (Math.abs(scrollSpeed) != scrollSpeed)
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

            if(!daNote.mustPress)
            {
                if(daNote.isSustainNote)
                {
                    if(Conductor.songPosition >= (daNote.strumTime + (Conductor.safeZoneOffset / 4)))
                    {
                        killOpponentNote(daNote);
                    }
                }
                else
                {
                    if(Conductor.songPosition >= daNote.strumTime)
                    {
                        killOpponentNote(daNote);
                    }
                }
            }
            
            if(Conductor.songPosition - daNote.strumTime > Conductor.safeZoneOffset)
            {
                notes.remove(daNote, true);
                daNote.kill();
                daNote.destroy();

                PlayState.instance.voices.volume = 0;

                if(!daNote.isSustainNote)
                    PlayState.instance.songMisses++;
                
                PlayState.instance.songScore -= 10;

                PlayState.instance.totalNotes++;
            }
        });

        keyShit();
    }

    function killOpponentNote(daNote:Note)
    {
        PlayState.instance.voices.volume = 1;
        
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

		for(i in 0...keyCount)
		{
			justPressed.push(false);
			pressed.push(false);
			released.push(false);
		}

        for(i in 0...testBinds.length)
        {
            justPressed[i] = testBinds[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBinds[i], FlxInputState.JUST_PRESSED) : false;
            pressed[i] = testBinds[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBinds[i], FlxInputState.PRESSED) : false;
            released[i] = testBinds[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBinds[i], FlxInputState.RELEASED) : false;

            if(released[i] == true)
            {
                justPressed[i] = testBindsAlt[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBindsAlt[i], FlxInputState.JUST_PRESSED) : false;
                pressed[i] = testBindsAlt[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBindsAlt[i], FlxInputState.PRESSED) : false;
                released[i] = testBindsAlt[i] != FlxKey.NONE ? FlxG.keys.checkStatus(testBindsAlt[i], FlxInputState.RELEASED) : false;
            }
        }

        if(Init.getOption('botplay') != true)
        {
            for(i in 0...justPressed.length)
            {
                if(justPressed[i])
                {
                    playerStrums.members[i].playAnim("press", true);
                }
            }

            for(i in 0...released.length)
            {
                if(released[i])
                {
                    playerStrums.members[i].playAnim("static");
                }
            }
        }

        var possibleNotes:Array<Note> = [];

        notes.forEach(function(note:Note) {
			note.calculateCanBeHit();

			if(Init.getOption('botplay') != true)
			{
				if(note.canBeHit && note.mustPress && !note.tooLate && !note.isSustainNote)
					possibleNotes.push(note);
			}
			else
			{
				if((!note.isSustainNote ? note.strumTime : note.strumTime + (Conductor.safeZoneOffset / 4)) <= Conductor.songPosition && note.mustPress)
					possibleNotes.push(note);
			}
        });

        possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dontHitTheseDirectionsLol:Array<Bool> = [];
		var noteDataTimes:Array<Float> = [];

		for(i in 0...keyCount)
        {
            dontHitTheseDirectionsLol.push(false);
            noteDataTimes.push(-1);
        }

		if(possibleNotes.length > 0)
		{
			for(i in 0...possibleNotes.length)
			{
				var note = possibleNotes[i];

				if(((justPressed[note.noteData] && !dontHitTheseDirectionsLol[note.noteData]) && Init.getOption('botplay') != true) || Init.getOption('botplay') == true)
				{
                    playerStrums.members[note.noteData].playAnim("confirm", true);
                    dontHitTheseDirectionsLol[note.noteData] = true;
                    noteDataTimes[note.noteData] = note.strumTime;

                    PlayState.instance.voices.volume = 1;
                    note.wasGoodHit = true;

					notes.remove(note, true);
					note.kill();
					note.destroy();
                }
            }

            for(i in 0...possibleNotes.length)
            {
                var note = possibleNotes[i];

                if(note.strumTime == noteDataTimes[note.noteData] && dontHitTheseDirectionsLol[note.noteData])
                {
                    PlayState.instance.voices.volume = 1;
                    note.wasGoodHit = true;
                    notes.remove(note);
                    note.kill();
                    note.destroy();
                }
            }
        }

        notes.forEach(function(note:Note) {
            if(note.isSustainNote && note.mustPress)
            {
                if((pressed[note.noteData] || Init.getOption('botplay') == true) && Conductor.songPosition >= note.strumTime + (Conductor.safeZoneOffset / 4))
                {
                    playerStrums.members[note.noteData].playAnim("confirm", true);

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
        var scale = FlxMath.lerp(1, iconP2.scale.x, 0.5);

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
}
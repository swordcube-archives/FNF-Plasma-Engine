package ui.playState;

import base.Conductor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.ui.FlxBar;
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

    public var downscroll:Bool = Init.getOption('downscroll');

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
    }

    var physicsUpdateTimer:Float = 0;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

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
                    if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
                        daNote.y += daNote.prevNote.height;
                    else
                        daNote.y += daNote.height / 2;

                    if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
                        && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
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
                    && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
                {
                    var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
                    swagRect.y = (center - daNote.y) / daNote.scale.y;
                    swagRect.height -= swagRect.y;

                    daNote.clipRect = swagRect;
                }
            }

            if(!daNote.mustPress)
            {
                if(Conductor.songPosition >= daNote.strumTime)
                {
                    opponentStrums.members[daNote.noteData].playAnim("confirm", true);
                    notes.remove(daNote, true);
                    daNote.kill();
                    daNote.destroy();
                }
            }
            
            if(Conductor.songPosition - daNote.strumTime > Conductor.safeZoneOffset)
            {
                notes.remove(daNote, true);
                daNote.kill();
                daNote.destroy();
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
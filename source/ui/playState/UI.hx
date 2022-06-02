package ui.playState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import states.PlayState;

class UI extends FlxSpriteGroup
{
    public var defaultStrumY:Float = 50;

    // Strum Lines
    public var opponentStrums:StrumLine;
    public var playerStrums:StrumLine;

    // Health Bar & Icons
    public var healthBarBG:FlxSprite;
    public var healthBar:FlxBar;

    public var iconP2:HealthIcon;
    public var iconP1:HealthIcon;

    public function new()
    {
        super(); 
        
        // Strum Lines
		var xMult:Float = 65;

		if(Init.getOption('downscroll') == true)
			defaultStrumY = FlxG.height - 150;

        defaultStrumY -= 15;

        opponentStrums = new StrumLine(xMult, defaultStrumY, 'arrows', 4);
        add(opponentStrums);

        playerStrums = new StrumLine((FlxG.width / 2) + xMult, defaultStrumY, 'arrows', 4);
        add(playerStrums);

        // Health Bar
        healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(GenesisAssets.getAsset('ui/healthBar', IMAGE));
		healthBarBG.screenCenter(X);
        if(Init.getOption('downscroll') == true)
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

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var scale = FlxMath.lerp(1, iconP2.scale.x, 0.3);

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
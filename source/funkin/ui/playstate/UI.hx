package funkin.ui.playstate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import funkin.game.Note;
import funkin.game.PlayState;
import funkin.systems.Conductor;
import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import funkin.systems.Ranking;

class UI extends flixel.group.FlxGroup
{
    public static var delta:Float = 0.0;

    public static var instance:UI;
    public var opponentStrums:StrumLine;
    public var playerStrums:StrumLine;

    public var healthBarBG:FlxSprite; 
    public var healthBar:FlxBar;

	public var iconP2:HealthIcon;
	public var iconP1:HealthIcon;

	public var scoreTxt:FlxText;
    
    public function new()
    {
        super();

        instance = this;

        var arrowOffset:Float = 10.0;
        var arrowSpacing:Float = 300.0;

        var strumY:Float = 60;
        if(PlayState.downScroll)
            strumY = FlxG.height - 160;

        // All strumlines with hasInput set to false will automatically hit every note.
        opponentStrums = new StrumLine(0, strumY, PlayState.instance.uiSkin, PlayState.SONG.keyCount, false);
        opponentStrums.screenCenter(X);
        opponentStrums.x -= arrowSpacing;
        opponentStrums.x += arrowOffset;
        add(opponentStrums);
        add(opponentStrums.notes);

        // All strumlines with hasInput set to true will require you to hit every note.
        playerStrums = new StrumLine(0, strumY, PlayState.instance.uiSkin, PlayState.SONG.keyCount, true);
        playerStrums.screenCenter(X);
        playerStrums.x += arrowSpacing;
        playerStrums.x += arrowOffset;
        add(playerStrums);
        add(playerStrums.notes);

		// Health Bar
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(FunkinAssets.getImage(Paths.image('ui/skins/${PlayState.instance.uiSkinJson.healthBarSkin}/healthBar')));
		healthBarBG.screenCenter(X);
		if(PlayState.downScroll)
			healthBarBG.y = 60;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8),
			PlayState.instance, 'health', PlayState.instance.minHealth, PlayState.instance.maxHealth);
		healthBar.scrollFactor.set();
		var colors:Array<FlxColor> = [
			0xFFFF0000,//FlxColor.fromString(PlayState.instance.dad.healthBarColor),
			0xFF66FF33,//FlxColor.fromString(PlayState.instance.bf.healthBarColor),
		];
		healthBar.createFilledBar(colors[0], colors[1]);
		add(healthBar);

		// Icons
		iconP1 = new HealthIcon(PlayState.SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);
		
		iconP2 = new HealthIcon(PlayState.SONG.player2);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(0, healthBarBG.y + 35, FlxG.width, "", 16);
		scoreTxt.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(scoreTxt);

        updateScoreText();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var curState:Dynamic = FlxG.state;
        delta = curState.delta;

		var scale = FlxMath.lerp(iconP2.scale.x, 1, delta * 15);

		iconP2.scale.set(scale, scale);
		iconP2.updateHitbox();

		iconP1.scale.set(scale, scale);
		iconP1.updateHitbox();

        positionIcons();

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
    }

	public function beatHit()
	{
		iconP2.scale.set(1.2, 1.2);
		iconP2.updateHitbox();

		iconP1.scale.set(1.2, 1.2);
		iconP1.updateHitbox();

		positionIcons();
	}

    public function stepHit() {} // your mom :D

	public function positionIcons()
	{
		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
	}

    public function updateScoreText()
    {
        var accuracy:Float = PlayState.instance.songAccuracy * 100;

		scoreTxt.text = (
            "Score: " + PlayState.instance.songScore + " // " + 
            "Misses: " + PlayState.instance.songMisses + " // " + 
            "Accuracy: " + FlxMath.roundDecimal(accuracy, 2) + "% // " + 
            "Rank: " + Ranking.getRank(accuracy)
        );
    }
}
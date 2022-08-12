package gameplay;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hscript.HScript;
import states.PlayState;
import systems.Conductor;
import ui.HealthIcon;

using StringTools;

class GameplayUI extends FlxGroup
{
    public var scoreTxt:FlxText;

    public var songTxt:FlxText;
    public var engineTxt:FlxText;

    public var opponentStrums:StrumLine;
    public var playerStrums:StrumLine;

    public var engineVersion:String = 'Plasma Engine v${Main.engineVersion}';

    public var healthBarBG:FlxSprite;
    public var healthBar:FlxSprite;
    public var iconP2:HealthIcon;
    public var iconP1:HealthIcon;

    public var timeBarBG:FlxSprite;
    public var timeBar:FlxSprite;
    public var timeTxt:FlxText;

    // Scripts
    public var healthBarScript:HScript;
    public var timeBarScript:HScript;

    public var healthColors:Array<FlxColor> = [];

    public function new()
    {
        super();
    
        // Arrows
        var arrowOffset:Float = 90.0;
        var strumY:Float = Init.trueSettings.get("Downscroll") ? FlxG.height - 165 : 50.0;

        opponentStrums = new StrumLine(arrowOffset, strumY, PlayState.SONG.keyCount);
        opponentStrums.hasInput = false;
        add(opponentStrums);
        add(opponentStrums.notes);
        add(opponentStrums.grpNoteSplashes);

        playerStrums = new StrumLine((FlxG.width/2)+arrowOffset, strumY, PlayState.SONG.keyCount);
        playerStrums.hasInput = true;
        add(playerStrums);
        add(playerStrums.notes);
        add(playerStrums.grpNoteSplashes);

        if(Init.trueSettings.get("Centered Notes"))
        {
            opponentStrums.x = -9999;
            playerStrums.screenCenter(X);
        }

        // Text
        songTxt = new FlxText(5, FlxG.height - 25, 0, '${PlayState.SONG.song} - ${PlayState.currentDifficulty.toUpperCase()}', 16);
        songTxt.setFormat(AssetPaths.font("vcr"), 16, FlxColor.WHITE, LEFT);
        songTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        add(songTxt);

        engineTxt = new FlxText(0, FlxG.height - 25, 0, engineVersion, 16);
        engineTxt.setFormat(AssetPaths.font("vcr"), 16, FlxColor.WHITE, RIGHT);
        engineTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        engineTxt.x = FlxG.width - (engineTxt.width + 5);
        add(engineTxt);

        healthBarScript = new HScript("scripts/HealthBar");
        healthBarScript.setVariable("add", this.add);
        healthBarScript.setVariable("remove", this.remove);
        healthBarScript.setVariable("ui", this);
        healthBarScript.start();
        PlayState.current.scripts.push(healthBarScript);

        timeBarScript = new HScript("scripts/TimeBar");
        timeBarScript.setVariable("add", this.add);
        timeBarScript.setVariable("remove", this.remove);
        timeBarScript.setVariable("ui", this);
        timeBarScript.start();
        PlayState.current.scripts.push(timeBarScript);
    }
}
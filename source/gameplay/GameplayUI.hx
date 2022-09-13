package gameplay;

import systems.ExtraKeys;
import systems.ScriptedSprite;
import flixel.ui.FlxBar;
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

class GameplayUI extends FlxGroup {
    public var scoreTxt:FlxText;

    public var songTxt:FlxText;
    public var engineTxt:FlxText;

    public var opponentStrums:StrumLine;
    public var playerStrums:StrumLine;

    public var engineVersion:String = 'Plasma Engine v${Main.engineVersion}';

    public var healthBarBG:FlxSprite;
    public var healthBar:FlxBar;
    public var iconP2:HealthIcon;
    public var iconP1:HealthIcon;

    public var timeBarBG:FlxSprite;
    public var timeBar:FlxSprite;
    public var timeTxt:FlxText;

    public var laneUnderlayOpponent:FlxSprite;
    public var laneUnderlayPlayer:FlxSprite;

    // Scripts
    public var healthBarScript:HScript;
    public var timeBarScript:HScript;

    public var healthColors:Array<FlxColor> = [];

    public function new()
    {
        super();
    
        // Arrows
        var arrowSpacing:Float = FlxG.width / 4;
        var strumY:Float = Settings.get("Downscroll") ? FlxG.height - 165 : 50.0;

        opponentStrums = new StrumLine(0, strumY, PlayState.SONG.keyCount);
        opponentStrums.hasInput = false;
        add(opponentStrums);
        add(opponentStrums.notes);
        add(opponentStrums.grpNoteSplashes);
        opponentStrums.screenCenter(X);
        opponentStrums.x -= arrowSpacing;
        
        playerStrums = new StrumLine(0, strumY, PlayState.SONG.keyCount);
        playerStrums.hasInput = true;
        add(playerStrums);
        add(playerStrums.notes);
        add(playerStrums.grpNoteSplashes);
        playerStrums.screenCenter(X);
        playerStrums.x += arrowSpacing;

        if(Settings.get("Centered Notes"))
        {
            opponentStrums.x = -9999;
            playerStrums.screenCenter(X);
        }

        laneUnderlayOpponent = new FlxSprite(opponentStrums.x - 5).makeGraphic(Std.int(opponentStrums.width) + 10, FlxG.height, FlxColor.BLACK);
        laneUnderlayOpponent.alpha = Settings.get("Lane Underlay");
        insert(members.indexOf(opponentStrums) - 1, laneUnderlayOpponent);

        laneUnderlayPlayer = new FlxSprite(playerStrums.x - 5).makeGraphic(Std.int(playerStrums.width) + 10, FlxG.height, FlxColor.BLACK);
        laneUnderlayPlayer.alpha = Settings.get("Lane Underlay");
        insert(members.indexOf(playerStrums) - 1, laneUnderlayPlayer);

        // Text
        songTxt = new FlxText(5, FlxG.height - 25, 0, '${PlayState.actualSongName} - ${PlayState.currentDifficulty.toUpperCase()}', 16);
        songTxt.setFormat(AssetPaths.font("vcr"), 16, FlxColor.WHITE, LEFT);
        songTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        add(songTxt);

        engineTxt = new FlxText(0, FlxG.height - 25, 0, engineVersion, 16);
        engineTxt.setFormat(AssetPaths.font("vcr"), 16, FlxColor.WHITE, RIGHT);
        engineTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        engineTxt.x = FlxG.width - (engineTxt.width + 5);
        add(engineTxt);

        healthBarScript = new HScript("scripts/HealthBar");
        healthBarScript.set("add", this.add);
        healthBarScript.set("remove", this.remove);
        healthBarScript.set("ui", this);
        healthBarScript.start();
        PlayState.current.scripts.push(healthBarScript);

        timeBarScript = new HScript("scripts/TimeBar");
        timeBarScript.set("add", this.add);
        timeBarScript.set("remove", this.remove);
        timeBarScript.set("ui", this);
        timeBarScript.start();
        PlayState.current.scripts.push(timeBarScript);
    }
}
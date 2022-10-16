package funkin.gameplay;

import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import scenes.PlayState;

class UI extends FlxGroup {
    public var enemyStrums:StrumLine;
    public var playerStrums:StrumLine;

    public var healthBarBG:Sprite;
    public var healthBar:FlxBar;

    public var iconP2:HealthIcon;
    public var iconP1:HealthIcon;

    public var scoreTxt:Text;

    public function new() {
        super();
        var arrowSpacing:Float = FlxG.width / 4;
        var strumY:Float = Settings.get("Downscroll") ? FlxG.height - 155 : 50.0;

        enemyStrums = new StrumLine(0, strumY, PlayState.SONG.keyCount);
        enemyStrums.isOpponent = true;
        enemyStrums.generateStrums();
        add(enemyStrums);
        add(enemyStrums.notes);
        //add(enemyStrums.grpNoteSplashes);
        enemyStrums.screenCenter(X);
        enemyStrums.x -= arrowSpacing;
        
        playerStrums = new StrumLine(0, strumY, PlayState.SONG.keyCount);
        playerStrums.isOpponent = false;
        playerStrums.generateStrums();
        add(playerStrums);
        add(playerStrums.notes);
        //add(playerStrums.grpNoteSplashes);
        playerStrums.screenCenter(X);
        playerStrums.x += arrowSpacing;

        if(Settings.get("Centered Notes"))
        {
            enemyStrums.x = -9999;
            playerStrums.screenCenter(X);
        }
    }
}
package funkin.gameplay;

import funkin.states.PlayState;
import flixel.group.FlxGroup;

class FunkinUI extends FlxGroup {
    public var healthBar:HealthBar;
    public var enemyStrums:StrumLine;
    public var playerStrums:StrumLine;

    public function new() {
        super();

        var strumSpacing:Float = FlxG.width / 4.0;
        var strumY:Float = Settings.get("Downscroll") ? FlxG.height - 160 : 50.0;

        enemyStrums = new StrumLine(0, strumY, PlayState.songData.keyCount);
        enemyStrums.screenCenter(X);
        enemyStrums.x -= strumSpacing;
        enemyStrums.isOpponent = true;
        add(enemyStrums);

        playerStrums = new StrumLine(0, strumY, PlayState.songData.keyCount);
        playerStrums.screenCenter(X);
        playerStrums.x += strumSpacing;
        add(playerStrums);

        healthBar = new HealthBar(0, Settings.get("Downscroll") ? 72 : FlxG.height * 0.9);
        add(healthBar);
    }

    public function beatHit(curBeat:Int) {
        healthBar.beatHit(curBeat);
    }
}
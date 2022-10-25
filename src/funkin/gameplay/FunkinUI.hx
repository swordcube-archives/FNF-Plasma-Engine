package funkin.gameplay;

import flixel.group.FlxGroup;

class FunkinUI extends FlxGroup {
    public var healthBar:HealthBar;
    public var enemyStrums:StrumLine;
    public var playerStrums:StrumLine;

    public function new() {
        super();

        var strumSpacing:Float = FlxG.width / 4.0;

        enemyStrums = new StrumLine(0, FlxG.height - 160, 4);
        enemyStrums.screenCenter(X);
        enemyStrums.x -= strumSpacing;
        enemyStrums.isOpponent = true;
        add(enemyStrums);

        playerStrums = new StrumLine(0, FlxG.height - 160, 4);
        playerStrums.screenCenter(X);
        playerStrums.x += strumSpacing;
        add(playerStrums);

        healthBar = new HealthBar(0, 72);
        add(healthBar);
    }
}
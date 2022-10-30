package funkin.gameplay;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import funkin.states.PlayState;
import flixel.group.FlxGroup;

class FunkinUI extends FlxGroup {
    public var healthBar:HealthBar;
    public var enemyStrums:StrumLine;
    public var playerStrums:StrumLine;
    public var scoreTxt:FlxText;

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

        scoreTxt = new FlxText(0, healthBar.bg.y + 40, 0, "???");
        scoreTxt.setFormat(Paths.font("vcr.ttf"), 17, FlxColor.WHITE, CENTER);
        scoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.2);
        scoreTxt.screenCenter(X);
        scoreTxt.antialiasing = Settings.get("Antialiasing");
        add(scoreTxt);

        updateScoreText();
    }

    public static final scoreDivider:String = " • ";

    public function updateScoreText() {
        scoreTxt.text = ("Score: " + PlayState.current.score + scoreDivider +
            "Misses: " + PlayState.current.misses + scoreDivider +
            "Accuracy: " + MathUtil.roundDecimal(PlayState.current.accuracy*100.0, 2) + "%" + scoreDivider +
            "Rank: " + Ranking.getRank(PlayState.current.accuracy*100.0)
        );
        scoreTxt.screenCenter(X);
    }

    public function beatHit(curBeat:Int) {
        healthBar.beatHit(curBeat);
    }
}
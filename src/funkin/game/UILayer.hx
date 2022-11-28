package funkin.game;

import flixel.FlxBasic;
import flixel.math.FlxMath;
import funkin.system.MathUtil;
import flixel.text.FlxText;
import funkin.states.PlayState;
import funkin.ui.HealthIcon;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

using StringTools;

class UILayer extends FlxGroup {
    public var iconP2:HealthIcon;
	public var iconP1:HealthIcon;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var opponentStrums:StrumLine;
	public var playerStrums:StrumLine;

	public var scoreTxt:FlxText;

    public function new() {
		super();

		var prefs = PlayerSettings.prefs;
		var strumY:Float = prefs.get("Downscroll") ? FlxG.height - 160 : 30;
		var strumSpacing:Float = FlxG.width / 4;
		
		var noteSkin:String = PlayState.current.noteSkin.replace("Default", PlayerSettings.prefs.get("Note Skin"));

		opponentStrums = new StrumLine(0, strumY, PlayState.SONG.keyAmount, noteSkin);
		opponentStrums.screenCenter(X);
		opponentStrums.x -= strumSpacing;
		opponentStrums.isOpponent = true;

		playerStrums = new StrumLine(0, strumY, PlayState.SONG.keyAmount, noteSkin);
		playerStrums.screenCenter(X);
		playerStrums.x += strumSpacing;

		if(prefs.get("Play As Opponent")) {
			if(prefs.get("Centered Notes")) {
				opponentStrums.x -= 9999;
				playerStrums.screenCenter(X);
			} else {
				var old = [opponentStrums.x, opponentStrums.y];
				var old2 = [playerStrums.x, playerStrums.y];
				opponentStrums.setPosition(old2[0], old2[1]);
				playerStrums.setPosition(old[0], old[1]);
			}
		} else {
			if(prefs.get("Centered Notes")) {
				opponentStrums.x -= 9999;
				playerStrums.screenCenter(X);
			}
		}

		add(opponentStrums);
		add(playerStrums);
	}

	public function initHealthBar() {
		var prefs = PlayerSettings.prefs;
		
		healthBarBG = new FlxSprite(0, prefs.get("Downscroll") ? 72 : FlxG.height * 0.9).loadGraphic(Assets.load(IMAGE, Paths.image('ui/healthBar')));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		var game = PlayState.current;
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8),
			PlayState.current, 'health', game.minHealth, game.maxHealth);
		healthBar.createFilledBar(
			game.dad != null ? game.dad.healthBarColor : 0xFFFF0000, 
			game.bf != null ? game.bf.healthBarColor : 0xFF66FF33
		);
		healthBar.scrollFactor.set();
		add(healthBar);

		iconP1 = new HealthIcon().loadIcon(game.bf != null ? game.bf.healthIcon : "face");
		iconP1.y = healthBar.y - 75;
		iconP1.flipX = true;
		add(iconP1);

		iconP2 = new HealthIcon().loadIcon(game.dad != null ? game.dad.healthIcon : "face");
		iconP2.y = healthBar.y - 75;
		add(iconP2);

		scoreTxt = new FlxText(0, healthBarBG.y + 35, 0);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 17, CENTER, OUTLINE, FlxColor.BLACK);
		scoreTxt.antialiasing = true;
		add(scoreTxt);
		updateScoreText();

		// preload default note splash because tasty
		var splash = new NoteSplash(0,0,[255, 0, 0]);
		splash.alpha = 0.001;
		add(splash);
	}

	public static final scoreDivider:String = " • ";

	public function updateScoreText() {
		var game = PlayState.current;
        scoreTxt.text = ("Score: " + game.score + scoreDivider +
            "Misses: " + game.misses + scoreDivider +
            "Accuracy: " + MathUtil.roundDecimal(game.accuracy*100.0, 2) + "%" + scoreDivider +
            "Rank: " + Ranking.getRank(game.accuracy*100.0)
        );
        scoreTxt.screenCenter(X);
	}

	public function beatHit(curBeat:Int) {
		iconP2.scale.add(0.2, 0.2);
		iconP2.updateHitbox();

		iconP1.scale.add(0.2, 0.2);
		iconP1.updateHitbox();

		updateIcons();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		var iconLerp:Float = 0.25;

		iconP2.scale.set(CoolUtil.fixedLerp(iconP2.scale.x, 1, iconLerp), CoolUtil.fixedLerp(iconP2.scale.y, 1, iconLerp));
		iconP2.updateHitbox();

		iconP1.scale.set(CoolUtil.fixedLerp(iconP1.scale.x, 1, iconLerp), CoolUtil.fixedLerp(iconP1.scale.y, 1, iconLerp));
		iconP1.updateHitbox();
		updateIcons();
	}

	function updateIcons() {
		var iconOffset:Int = 26;
		iconP1.iconHealth = healthBar.percent;
		iconP2.iconHealth = 100 - healthBar.percent;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
	}

	override public function add(obj:FlxBasic) {
		if (obj is FlxSprite && cast(obj, FlxSprite).antialiasing && !PlayerSettings.prefs.get("Antialiasing"))
			cast(obj, FlxSprite).antialiasing = false;
		return super.add(obj);
	}
}
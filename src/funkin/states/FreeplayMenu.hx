package funkin.states;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.media.Sound;

using StringTools;

typedef FreeplaySong = {
	var song:String;
	var character:String;
	@:optional var displayName:String;

	var color:FlxColor;
	var difficulties:Array<String>;
}

class FreeplayMenu extends FunkinState {
	var bg:Sprite;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	static var curSpeed:Float = 1.0;

    var grpSongs:FlxTypedGroup<Alphabet>;
    var grpIcons:FlxTypedGroup<HealthIcon>;

	var cachedSounds:Map<String, Sound> = [
		"scroll" => Assets.load(SOUND, Paths.sound("menus/scrollMenu")),
		"cancel" => Assets.load(SOUND, Paths.sound("menus/cancelMenu")),
	];

	var scoreBG:Sprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var speedText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	var songList:Array<FreeplaySong> = Utilities.loadSongListXML(Assets.load(TEXT, Paths.xml("data/freeplaySongs")));
	var colorTween:FlxTween;

	override function create() {
		super.create();

		bg = new Sprite().load(IMAGE, Paths.image("menus/menuBGDesat"));
		add(bg);

        grpSongs = new FlxTypedGroup<Alphabet>();
        add(grpSongs);

        grpIcons = new FlxTypedGroup<HealthIcon>();
        add(grpIcons);

        for(i in 0...songList.length) {
            var song:FreeplaySong = songList[i];
            var text:Alphabet = new Alphabet(0, (70 * i) + 30, Bold, song.displayName);
            text.isMenuItem = true;
            text.targetY = i;
            text.ID = i;
            grpSongs.add(text);

            var icon:HealthIcon = new HealthIcon(text.x, text.y, song.character);
			icon.sprTracker = text;
			grpIcons.add(icon);
        }

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
	
		scoreBG = new Sprite(scoreText.x - 6, 0).makeGraphic(1, 99, 0xFF000000);
		scoreBG.antialiasing = false;
		scoreBG.alpha = 0.6;
		add(scoreBG);
	
		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);
	
		speedText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		speedText.font = scoreText.font;
		add(speedText);
	
		add(scoreText);

		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		updateScore();

		if(Controls.getP("ui_up"))
			changeSelection(-1);

		if(Controls.getP("ui_down"))
			changeSelection(1);

		if(Controls.getP("ui_left"))
			changeDifficulty(-1);

		if(Controls.getP("ui_right"))
			changeDifficulty(1);

		if(Controls.getP("accept")) {
			Main.switchState(new PlayState());
		}

		if(Controls.getP("back")) {
			FlxG.sound.play(cachedSounds["cancel"]);
			Main.switchState(new MainMenu());
		}
	}

	function updateScore() {
		intendedScore = Highscore.getScore(songList[curSelected].song+"-"+songList[curSelected].difficulties[curDifficulty].trim());
	
		lerpScore = FlxMath.lerp(lerpScore, intendedScore, FlxG.elapsed * 9.0);
	
		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);
	
		speedText.text = "Speed: " + curSpeed;
		positionHighscore();
	}
	
	function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
	
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
		diffText.x = scoreBG.x + scoreBG.width / 2;
		diffText.x -= diffText.width / 2;
	
		speedText.x = scoreBG.x + scoreBG.width / 2;
		speedText.x -= speedText.width / 2;
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if(curSelected < 0)
		    curSelected = grpSongs.length-1;
		if(curSelected > grpSongs.length-1)
		    curSelected = 0;

        grpSongs.forEach(function(text:Alphabet) {
            text.alpha = curSelected == text.ID ? 1 : 0.6;
            text.targetY = text.ID - curSelected;
        });

		if(colorTween != null)
			colorTween.cancel();

		colorTween = FlxTween.color(bg, 0.45, bg.color, songList[curSelected].color);

		FlxG.sound.play(cachedSounds["scroll"]);
		changeDifficulty();
	}

	function changeDifficulty(change:Int = 0) {
		curDifficulty += change;
		if(curDifficulty < 0)
			curDifficulty = songList[curSelected].difficulties.length - 1;
		if(curDifficulty > songList[curSelected].difficulties.length - 1)
			curDifficulty = 0;
	
		diffText.text = "< " + songList[curSelected].difficulties[curDifficulty].toUpperCase() + " >";
		updateScore();
	}
}

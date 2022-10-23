package funkin.states;

import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.media.Sound;

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

    var grpSongs:FlxTypedGroup<Alphabet>;
    var grpIcons:FlxTypedGroup<HealthIcon>;

	var cachedSounds:Map<String, Sound> = [
		"scroll" => Assets.load(SOUND, Paths.sound("menus/scrollMenu")),
		"cancel" => Assets.load(SOUND, Paths.sound("menus/cancelMenu")),
	];

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

		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.getP("ui_up"))
			changeSelection(-1);

		if (Controls.getP("ui_down"))
			changeSelection(1);

		if (Controls.getP("back")) {
			FlxG.sound.play(cachedSounds["cancel"]);
			Main.switchState(new MainMenu());
		}
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
	}
}

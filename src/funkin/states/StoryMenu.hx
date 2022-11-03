package funkin.states;

import openfl.media.Sound;

using StringTools;

class StoryMenu extends FunkinState {
	var cachedSounds:Map<String, Sound> = [
		"scroll"  => Assets.load(SOUND, Paths.sound("menus/scrollMenu")),
		"cancel"  => Assets.load(SOUND, Paths.sound("menus/cancelMenu")),
		"confirm" => Assets.load(SOUND, Paths.sound("menus/confirmMenu")),
	];

	override function create() {
		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(Controls.getP("back")) {
			FlxG.sound.play(cachedSounds["cancel"]);
			Main.switchState(new MainMenu());
		}
	}
}

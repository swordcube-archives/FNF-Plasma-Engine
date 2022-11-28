package funkin.states.menus;

using StringTools;

// gonna rewrite this shit ass soon
class StoryMenuState extends FNFState {
	override function create() {
		super.create();
	}

    override function update(elapsed:Float) {
		super.update(elapsed);

		if(controls.getP("BACK")) {
			FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
			FlxG.switchState(new funkin.states.menus.MainMenuState());
		}
	}
}
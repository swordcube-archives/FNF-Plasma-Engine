package funkin.options;

import funkin.options.screens.ControlsMenu;
import funkin.options.screens.AppearanceMenu;
import funkin.options.screens.PreferencesMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.states.menus.MainMenuState;
import funkin.states.FNFState;
import funkin.ui.Alphabet;
import flixel.FlxSprite;

class OptionsMenu extends FNFState {
	public var curSelected:Int = 0;
	public var categories:CategoryGroup;

	public var bg:FlxSprite;

	override function create() {
        super.create();

		allowSwitchingMods = false;
        
		bg = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image('menuBGDesat')));
		bg.color = 0xFFea71fd;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = PlayerSettings.prefs.get("Antialiasing");
		add(bg);

		categories = new CategoryGroup();
		add(categories);

		// Adding categories
		categories.addCategory("Preferences", function() {
			openSubState(new PreferencesMenu());
		});
		categories.addCategory("Appearance", function() {
			openSubState(new AppearanceMenu());
		});
		categories.addCategory("Controls", function() {
			openSubState(new ControlsMenu());
		});
		categories.addCategory("Exit", function() {
			FlxG.switchState(new MainMenuState());
		});

		// Correcting the appearance of the categories
		categories.forEach(function(text:CategoryText) {
			text.y -= 90 * (categories.length / 2);
		});
		categories.changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.getP("BACK")) {
			PlayerSettings.prefs.flush();
			PlayerSettings.controls.flush();
			FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
			FlxG.switchState(new MainMenuState());
		}
	}
}

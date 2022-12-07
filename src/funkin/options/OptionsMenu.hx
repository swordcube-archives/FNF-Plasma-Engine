package funkin.options;

import funkin.scripting.HScriptModule;
import funkin.options.screens.CustomScreen;
import funkin.scripting.events.StateCreationEvent;
import funkin.scripting.Script;
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

	public var script:ScriptModule;

	override function create() {
        super.create();

		allowSwitchingMods = false;

		script = Script.load(Paths.script('data/states/OptionsMenu'));
		script.setParent(this);
        switch(script.scriptType) {
            case HScript:
                var casted:HScriptModule = cast script;
                casted.addClass(CustomScreen);
            default: // add more here yourself
        }
		script.run(false);
		script.event("onStateCreation", new StateCreationEvent(this));
        
		bg = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image('menus/menuBGDesat')));
		bg.color = 0xFFea71fd;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = PlayerSettings.prefs.get("Antialiasing");
		add(bg);

		categories = new CategoryGroup();
		add(categories);

		// Adding categories
		script.event("onAddCategories", new StateCreationEvent(this));

		categories.addCategory("Preferences", function() {
			openSubState(new PreferencesMenu());
		});
		categories.addCategory("Appearance", function() {
			openSubState(new AppearanceMenu());
		});
		categories.addCategory("Controls", function() {
			openSubState(new ControlsMenu());
		});

		script.event("onAddCategoriesPost", new StateCreationEvent(this));
		
		categories.addCategory("Exit", function() {
			goBack();
		});

		// Correcting the appearance of the categories
		categories.forEach(function(text:CategoryText) {
			text.y -= 90 * (categories.length / 2);
		});
		categories.changeSelection();

		script.event("onStateCreationPost", new StateCreationEvent(this));
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.getP("BACK")) goBack();
	}

	function goBack() {
		PlayerSettings.prefs.flush();
		PlayerSettings.controls.flush();
		FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
		FlxG.switchState(new MainMenuState());
	}
}

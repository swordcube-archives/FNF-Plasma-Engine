package funkin.states;

import flixel.addons.transition.FlxTransitionableState;
import haxe.io.Path;
import flixel.FlxBasic;
import flixel.FlxSprite;
import funkin.system.PlayerPrefs;
import funkin.system.PlayerControls;
import funkin.system.PlayerSettings;
import funkin.game.Note;
import openfl.system.System;
import flixel.system.FlxSound;
import flixel.addons.ui.FlxUIState;

using StringTools;

class FNFState extends FlxUIState {
	public var allowSwitchingMods:Bool = true;

	public var controls(get, null):PlayerControls;
	function get_controls() {
		return PlayerSettings.controls;
	}

	public var prefs(get, null):PlayerPrefs;
	function get_prefs() {
		return PlayerSettings.prefs;
	}

	// convienience function
	// use in create!
	function enableTransitions() {
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
	}

	function disableTransitions() {
		transIn = null;
		transOut = null;
	}

	override function create() {
		super.create();

		persistentUpdate = false;
		persistentDraw = true;
		
		prefs.reload();

		Conductor.reset();

		// Clear the cache!!!
		FlxG.sound.list.forEach(function(sound:FlxSound) {
			FlxG.sound.list.remove(sound, true);
			sound.stop();
			sound.destroy();
		});
		FlxG.sound.list.clear();

		FlxG.bitmap.dumpCache();
		FlxG.bitmap.clearCache();

		OpenFLAssets.cache.clear();
		LimeAssets.cache.clear();

		Assets.cache.clear();

		System.gc();

		// Load note skins because heheheha
		Note.skinJSONs = [];
		for(json in CoolUtil.readDirectory("data/note_skins")) {
			if(FileSystem.exists(Paths.asset("data/note_skins/"+json)) && json.endsWith(".json"))
				Note.skinJSONs[json.split(".json")[0]] = Json.parse(Assets.load(TEXT, Paths.asset("data/note_skins/"+json)));
		}

		// Load note splashes because heheheha
		Note.splashSkinJSONs = [];
		for(json in CoolUtil.readDirectory("data/note_splashes")) {
			if(FileSystem.exists(Paths.asset("data/note_splashes/"+json)) && json.endsWith(".json"))
				Note.splashSkinJSONs[json.split(".json")[0]] = Json.parse(Assets.load(TEXT, Paths.asset("data/note_splashes/"+json)));
		}

		// Load note type scripts because3 hgnz,fiybriugf8yugbr ivfufd
		Note.noteTypeScripts = [];
		for(file in CoolUtil.readDirectory("data/scripts/note_types")) {
			if(FileSystem.exists(Paths.asset("data/scripts/note_types/"+file)) && Paths.scriptExtensions.contains("."+Path.extension(file)))
				Note.noteTypeScripts[file.split("."+Path.extension(file))[0]] = {
					code: Assets.load(TEXT, Paths.asset("data/scripts/note_types/"+file)),
					ext: Path.extension(file)
				};
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.keys.justPressed.F3) FlxG.resetState();

		if(allowSwitchingMods && FlxG.keys.justPressed.TAB) {
            persistentUpdate = false;
            persistentDraw = true;
            openSubState(new funkin.substates.ModSelection());
        }
	}

	override public function add(obj:FlxBasic) {
		if (obj is FlxSprite && cast(obj, FlxSprite).antialiasing && !PlayerSettings.prefs.get("Antialiasing"))
			cast(obj, FlxSprite).antialiasing = false;
		return super.add(obj);
	}

	override public function insert(pos:Int, obj:FlxBasic) {
		if (obj is FlxSprite && cast(obj, FlxSprite).antialiasing && !PlayerSettings.prefs.get("Antialiasing"))
			cast(obj, FlxSprite).antialiasing = false;
		return super.insert(pos, obj);
	}
}
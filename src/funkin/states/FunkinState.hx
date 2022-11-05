package funkin.states;

import openfl.Lib;
import funkin.gameplay.Note;
import openfl.system.System;
import flixel.system.FlxSound;
import flixel.addons.transition.FlxTransitionableState;
import base.Conductor;
import flixel.FlxState;

using StringTools;

class FunkinState extends FlxState {
	public var allowSwitchingMods:Bool = true;

    override function create() {
        super.create();

		Conductor.reset();

        if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new Transition(0.45, true));

		// Clears sounds from memory
		FlxG.sound.list.forEach(function(sound:FlxSound) {
			FlxG.sound.list.remove(sound, true);
			sound.stop();
			sound.destroy();
		});
		FlxG.sound.list.clear();

        // Clear all bitmaps from memory
		FlxG.bitmap.dumpCache();
		FlxG.bitmap.clearCache();

		// Clear all cache
		Assets.cache.clear();

        // Run the garbage collector
        System.gc();

		// Load note skins because heheheha
		Note.skinJSONs = [];
		for(json in CoolUtil.readDirectory("data/note_skins")) {
			if(FileSystem.exists(Paths.asset("data/note_skins/"+json)) && json.endsWith(".json"))
				Note.skinJSONs[json.split(".json")[0]] = TJSON.parse(Assets.load(TEXT, Paths.asset("data/note_skins/"+json)));
		}
    }

    override function update(elapsed:Float) {
		Lib.current.stage.frameRate = Settings.get("Framerate Cap");
		FlxG.autoPause = Settings.get("Auto Pause");

		if(FlxG.keys.justPressed.F5)
			Main.resetState();

		if(allowSwitchingMods && FlxG.keys.justPressed.TAB) {
            persistentUpdate = false;
            persistentDraw = true;
            openSubState(new funkin.states.substates.ModSelection());
        }
        super.update(elapsed);
    }
}
package engine;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxSound;
import funkin.Transition;
import funkin.gameplay.Note;
import openfl.system.System;
import scenes.PlayState;

using StringTools;

// I like calling states scenes shut the fuck up
class Scene extends FlxUIState {
	public var allowF5Refreshing:Bool = true;

    // Doing this stupidness so i can forget to do super.blablabla and not worry about that
    @:noCompletion override function create() {
        super.create();
        if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new Transition(0.45, true));

		// clears sounds from memory
		FlxG.sound.list.forEachAlive(function(sound:FlxSound) {
			FlxG.sound.list.remove(sound, true);
			sound.stop();
			sound.kill();
			sound.destroy();
		});
		FlxG.sound.list.clear();

        // clears all bitmaps from memory
		FlxG.bitmap.dumpCache();
		FlxG.bitmap.clearCache();

		// clear all cache
		Assets.clearCache();

        // run the garbage collector
        System.gc();

		// Preload Note Skins & Key Amount Info
		// We do this so we don't parse a json everytime a note spawns.
		// We like performance
		Note.noteSkins = [];
		for(item in CoolUtil.readDirectory('note_skins')) {
			if(item.endsWith(".json")) {
				var split:String = item.split(".json")[0];
				Note.noteSkins.set(split, Assets.get(JSON, Paths.json('note_skins/$split')));
			}
        }

		Note.noteColors = Assets.get("JSON", Paths.json("key_colors")).colors;
		Note.noteDirections = Assets.get("JSON", Paths.json("key_directions")).directions;
		Note.noteScales = Assets.get("JSON", Paths.json("key_scales")).scales;
		Note.noteSpacing = Assets.get("JSON", Paths.json("key_spacing")).spacing;

        start();
    }

    // Override these!
    public function start() {}

    public function process(delta:Float) {}

    public function beatHit(curBeat:Int) {}
    public function stepHit(curStep:Int) {}

    @:noCompletion override function update(elapsed:Float) {
        super.update(elapsed);

		if (FlxG.state == PlayState.current) {
			if(allowF5Refreshing && FlxG.keys.justPressed.F5) {
				PlayState.current = null;
				Main.resetScene();
			}
		} else {
			if(allowF5Refreshing && FlxG.keys.justPressed.F5)
				Main.resetScene();
		}

		if (FlxG.keys.justPressed.F11)
			FlxG.fullscreen = !FlxG.fullscreen;

        Conductor.update(elapsed);
        process(elapsed);
    }
}
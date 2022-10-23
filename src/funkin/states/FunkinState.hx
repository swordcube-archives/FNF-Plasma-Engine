package funkin.states;

import openfl.system.System;
import flixel.system.FlxSound;
import flixel.addons.transition.FlxTransitionableState;
import base.Conductor;
import flixel.FlxState;

class FunkinState extends FlxState {
    var curStep:Int = 0;
	var curBeat:Int = 0;

    override function create() {
        super.create();

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
    }

    override function update(elapsed:Float) {
        var oldStep:Int = curStep;
        var oldBeat:Int = curBeat;

		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.position >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.position - lastChange.songTime) / Conductor.stepCrochet);
        curBeat = Math.floor(curStep / 4);

        if (oldStep != curStep && curStep > 0)
            stepHit(curStep);

        if (oldBeat != curBeat && curBeat > 0)
            beatHit(curBeat);

		#if debug
		if(FlxG.keys.justPressed.F5)
			Main.resetState();
		#end

        super.update(elapsed);
    }

    public function beatHit(curBeat:Int) {}
    public function stepHit(curStep:Int) {}
}
package funkin.states.substates;

import flixel.FlxSubState;
import openfl.system.System;
import flixel.system.FlxSound;
import base.Conductor;

class FunkinSubState extends FlxSubState {
    var curStep:Int = 0;
	var curBeat:Int = 0;

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

		if(FlxG.keys.justPressed.F5)
			Main.resetState();

        super.update(elapsed);
    }

    public function beatHit(curBeat:Int) {}
    public function stepHit(curStep:Int) {}
}
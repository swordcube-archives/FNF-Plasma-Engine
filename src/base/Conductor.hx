package base;

import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.system.FlxSound;
import base.SongLoader;

#if docs @:noCompletion #end typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

/**
 * A class that handles the usage and control of songs
 */
class Conductor {
	public static var rate:Float = 1.0;
	public static var bpm:Float = 100;

	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds

	public static var position:Float = 0;

    public static var safeFrames:Int = 10;
    public static var safeZoneOffset:Float = (safeFrames / 60) * 1000;

	public static var onBeat:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public static var onStep:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static var curStep:Int = 0;
	public static var curBeat:Int = 0;

	public static var curStepFloat:Float = 0;
	public static var curBeatFloat:Float = 0;

	/**
	 * Initializes the Conductor and make it update automatically.
	 */
	public static function init() {
		FlxG.signals.preUpdate.add(update);
		reset();
	}
	public static function reset() {
		onBeat.removeAll();
		onStep.removeAll();
	}

	public static function mapBPMChanges(song:Song) {
		bpmChangeMap = [];
		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length) {
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM) {
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}
			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}

	public static function changeBPM(newBpm:Float, measure:Float = 4 / 4) {
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = (crochet / 4) * measure;
	}

	/**
	 * Returns if a sound is in sync with the `position` variable.
	 * @param sound The sound to check.
	 */
	public static function isAudioSynced(sound:FlxSound) {
        return !(sound.time > position + (20.0 * sound.pitch) || sound.time < position - (20.0 * sound.pitch));
    }

	public static function update() {
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

		curStepFloat = lastChange.stepTime + ((Conductor.position - lastChange.songTime) / Conductor.stepCrochet);
        curBeatFloat = curStepFloat / 4;

        if (oldStep != curStep && curStep > 0) onStep.dispatch(curStep);
        if (oldBeat != curBeat && curBeat > 0) onBeat.dispatch(curBeat);
	}
}

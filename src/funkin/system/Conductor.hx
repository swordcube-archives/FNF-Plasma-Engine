package funkin.system;

import flixel.system.FlxSound;
import flixel.util.FlxSignal.FlxTypedSignal;

@:dox(hide)
typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor {
	public static var bpm(default, set):Float = 100;

	static function set_bpm(v:Float) {
		crochet = ((60.0 / v) * 1000.0);
		stepCrochet = crochet / 4.0;
		return bpm = v;
	}

	public static var rate:Float = 1.0;

	/**
	 * The time between beats in milliseconds.
	 */
	public static var crochet:Float = ((60 / bpm) * 1000.0);

	/**
	 * The time between steps in milliseconds.
	 */
	public static var stepCrochet:Float = crochet / 4.0;

	public static var position:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static var onBeat:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public static var onStep:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public static var curStep:Int = 0;
	public static var curBeat:Int = 0;

	public static var curStepFloat:Float = 0;
	public static var curBeatFloat:Float = 0;

	public static function init() {
		FlxG.signals.preUpdate.add(update);
		reset();
	}

	public static function reset() {
		onBeat.removeAll();
		onStep.removeAll();
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
		curBeatFloat = curStepFloat / 4.0;

		if (oldStep != curStep && curStep > 0) onStep.dispatch(curStep);
		if (oldBeat != curBeat && curBeat > 0) onBeat.dispatch(curBeat);
	}

	public static function mapBPMChanges(song:Song) {
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.sections.length) {
			if (song.sections[i].changeBPM && song.sections[i].bpm != curBPM) {
				curBPM = song.sections[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.sections[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}

	public static function isAudioSynced(sound:FlxSound) {
        return !(sound.time > position + 20 || sound.time < position - 20);
    }
}

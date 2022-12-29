package funkin.system;

import funkin.states.PlayState;
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
	public static var onSection:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public static var curStep:Int = 0;
	public static var curBeat:Int = 0;

	public static var curDecStep:Float = 0;
	public static var curDecBeat:Float = 0;

	public static var curSection:Int = 0;

	static var stepsToDo:Int = 0;

	public static function init() {
		FlxG.signals.preUpdate.add(update);
		reset();
	}

	public static function reset() {
		storedSteps = [];
		skippedSteps = [];
		onBeat.removeAll();
		onStep.removeAll();
	}

	static var oldStep:Int = 0;
	static var storedSteps:Array<Int> = [];
	static var skippedSteps:Array<Int> = [];

	public static function update() {
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
		curDecStep = lastChange.stepTime + ((Conductor.position - lastChange.songTime) / Conductor.stepCrochet);

		curBeat = Math.floor(curDecStep / 4.0);
		curDecBeat = curDecStep / 4.0;

		var trueStep:Int = curStep;
		for (i in storedSteps)
			if (i < oldStep)
				storedSteps.remove(i);

		for (i in oldStep...trueStep) {
			if (!storedSteps.contains(i) && i > 0) {
				curStep = i;
				stepHit();
				skippedSteps.push(i);
			}
		}
		if (skippedSteps.length > 0)
			skippedSteps = [];

		curStep = trueStep;

		if (oldStep != curStep && curStep > 0 && !storedSteps.contains(curStep))
			stepHit();

		oldStep = curStep;
	}

	static function getSectionSteps(song:Song, section:Int):Int {
		var val:Null<Int> = null;
		if (song.sections[section] != null)
			val = song.sections[section].lengthInSteps;
		return val != null ? val : 16;
	}

	static function stepHit() {
		if (PlayState.SONG != null && FlxG.state == PlayState.current) {
			if (oldStep < curStep)
				updateSection();
			else
				rollbackSection();
		} else
			curSection = Std.int(curStep / 16);

		onStep.dispatch(curStep);
		if (curStep % 4 == 0)
			onBeat.dispatch(Math.floor(curStep / 4.0));

		if (!storedSteps.contains(curStep))
			storedSteps.push(curStep);
	}

	static function updateSection():Void {
		if (stepsToDo < 1)
			stepsToDo = getSectionSteps(PlayState.SONG, curSection);
		while (curStep >= stepsToDo) {
			curSection++;
			stepsToDo += getSectionSteps(PlayState.SONG, curSection);
			onSection.dispatch(curSection);
		}
	}

	static function rollbackSection():Void {
		if (curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.sections.length) {
			if (PlayState.SONG.sections[i] != null) {
				stepsToDo += getSectionSteps(PlayState.SONG, curSection);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}

		if (curSection > lastSection)
			onSection.dispatch(curSection);
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

			var deltaSteps:Int = getSectionSteps(song, i);
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}

	public static function isAudioSynced(sound:FlxSound) {
		var resyncTime:Float = #if windows 30 #else 20 #end; // i hate windows
		resyncTime *= FlxG.sound.music.pitch;
		return !(sound.time > position + resyncTime || sound.time < position - resyncTime);
	}
}

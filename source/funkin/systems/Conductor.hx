package funkin.systems;

import flixel.system.FlxSound;
import funkin.game.Song;

typedef BPMChange = {
    var stepPosition:Int;
    var position:Float;
    var bpm:Float;
};

class Conductor
{
    /**
        The song position in milliseconds.
    **/
    public static var position:Float = 0.0;

    /**
        The current beat of the song.
    **/
    public static var currentBeat:Int = 0;

    /**
        The current beat of the song. (but with decimals)
    **/
    public static var currentBeatFloat:Float = 0.0;

    /**
        The current step of the song.
    **/
    public static var currentStep:Int = 0;

    /**
        The current step of the song. (but with decimals)
    **/
    public static var currentStepFloat:Float = 0.0;

    /**
        The beats per minute of the song.
    **/
    public static var bpm:Float = 0.0;

    /**
        The time between beats in milliseconds.
    **/
    public static var crochet:Float = 0.0;

    /**
        The time between steps in milliseconds.
    **/
    public static var stepCrochet:Float = 0.0;

    /**
        Determines how early or late you can hit notes.
    **/
    public static var safeFrames:Float = 15;

    /**
        Basically `safeFrames` but in milliseconds.
    **/
    public static var safeZoneOffset:Float = (safeFrames / 60.0) * 1000.0;

    /**
        An array containing info about when mid-song BPM changes happen.
    **/
    public static var bpmChanges:Array<BPMChange> = [];

    /**
        Makes the `bpmChanges` array contain info about when mid-song BPM changes happen
        using data from the `song` parameter.

        @param song      The song to get BPM changes from
    **/
	public static function mapBPMChanges(song:Song)
	{
		bpmChanges = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChange = {
					stepPosition: totalSteps,
					position: totalPos,
					bpm: curBPM
				};
				bpmChanges.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}

    /**
        Changes the current BPM to `newBpm`
        @param newBPM      The BPM to change to.
    **/
	public static function changeBPM(newBPM:Float)
	{
		bpm = newBPM;

		crochet = ((60.0 / bpm) * 1000.0);
		stepCrochet = crochet / 4.0;
	}

    public static function isAudioSynced(sound:FlxSound)
    {
        return !(sound.time > position + 35 || sound.time < position - 35);
    }
}
package systems;

import states.PlayState;
import flixel.system.FlxSound;
import gameplay.Song;

typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

typedef TimeScaleChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var timeScale:Array<Int>;
}

class Conductor {
    /**
        The beats per minute of the song.
    **/
    public static var bpm:Float = 100.0;

    /**
        The time between beats.
    **/
    public static var crochet:Float = (60.0 / bpm) * 1000.0;

    /**
        The time between steps.
    **/
    public static var stepCrochet:Float = crochet / 4.0;

    /**
        The current position of the song in milliseconds
    **/
    public static var position:Float = 0.0;

    /**
        The current beat of the song.
    **/
    public static var currentBeat:Int = 0;

    /**
        The current beat of the song. (with decimals!)
    **/
    public static var currentBeatFloat:Float = 0.0;
    
    /**
        The current step of the song.
    **/
    public static var currentStep:Int = 0;

    /**
        The current step of the song. (with decimals!)
    **/
    public static var currentStepFloat:Float = 0.0;

    /**
        The amount of safe frames you get when hitting notes.
    **/
	public static var safeFrames:Float = 10.0;

    /**
        safeFrames but in milliseconds.
    **/
	public static var safeZoneOffset:Float = (safeFrames / 60.0) * 1000.0;

    public static var timeScale:Array<Int> = [4, 4];

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
    public static var timeScaleChangeMap:Array<TimeScaleChangeEvent> = [];

	public static function mapBPMChanges(song:Song)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
        var curTimeScale:Array<Int> = timeScale;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
        
		for (i in 0...song.notes.length)
		{
            // YCE charts have like 9273829 nulls in them so yknow balls
            if (song.notes[i] != null)
            {
                if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
                {
                    curBPM = song.notes[i].bpm;
                    var event:BPMChangeEvent = {
                        stepTime: totalSteps,
                        songTime: totalPos,
                        bpm: curBPM
                    };
                    bpmChangeMap.push(event);
                }

                if (song.notes[i].changeTimeScale
                    && song.notes[i].timeScale[0] != curTimeScale[0]
                    && song.notes[i].timeScale[1] != curTimeScale[1])
                {
                    curTimeScale = song.notes[i].timeScale;
    
                    var event:TimeScaleChangeEvent = {
                        stepTime: totalSteps,
                        songTime: totalPos,
                        timeScale: curTimeScale
                    };
    
                    timeScaleChangeMap.push(event);
                }

                var deltaSteps:Int = Math.floor((16 / curTimeScale[1]) * curTimeScale[0]);
                totalSteps += deltaSteps;
    
                totalPos += ((60 / curBPM) * 1000 / curTimeScale[0]) * deltaSteps;
            }
		}
	}

	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

    public static function recalculateShit() {
        safeZoneOffset = ((safeFrames / 60.0) * 1000.0) * PlayState.songMultiplier;
    }

    public static function isAudioSynced(sound:FlxSound)
    {
        return !(sound.time > position + 20 || sound.time < position - 20);
    }
}
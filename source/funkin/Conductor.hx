package funkin;

import flixel.system.FlxSound;

typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor {
	public static var bpm:Float = 100;

	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds

	public static var position:Float;

    public static var safeFrames:Int = 10;
    public static var safeZoneOffset:Float = (safeFrames / 60) * 1000;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

    public static var curBeat:Int = 0;
    public static var curStep:Int = 0;

    public static var curBeatFloat:Float = 0.0;
    public static var curStepFloat:Float = 0.0;

	public static function mapBPMChanges(song:Song) {
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length) {
            if(song.notes[i] != null) {
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
	}

    public static function update(elapsed:Float) {
        var oldBeat = curBeat;
        var oldStep = curStep;
    
        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: 0
        };

        for(change in bpmChangeMap) {
            if(position >= change.songTime) {
                lastChange = change;
                changeBPM(change.bpm);
            }
            else
                break;
        }

        curStepFloat = lastChange.stepTime + ((position - lastChange.songTime) / stepCrochet);
        curBeatFloat = curStepFloat / 4.0;
        
        curStep = lastChange.stepTime + Math.floor((position - lastChange.songTime) / stepCrochet);
        curBeat = Math.floor(curStep / 4);
        
        var scene:Scene = cast FlxG.state;
        var subscene:Subscene = cast FlxG.state.subState;
        if(curStep != oldStep && curStep > oldStep && curStep > 0 && Std.isOfType(FlxG.state, Scene)) {
            scene.stepHit(curStep);
            if(subscene != null)
                subscene.stepHit(curStep);
        }

        if(curBeat != oldBeat && curBeat > oldBeat && curBeat > 0 && Std.isOfType(FlxG.state, Scene)) {
            scene.beatHit(curBeat);
            if(subscene != null)
                subscene.beatHit(curBeat);
        }
    }

	public static function changeBPM(newBpm:Float, measure:Float = 4 / 4) {
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = (crochet / 4) * measure;
	}

    public static function isAudioSynced(sound:FlxSound) {
        return !(sound.time > position + 20 || sound.time < position - 20);
    }
}
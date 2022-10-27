package funkin.states;

import funkin.gameplay.Note;
import funkin.gameplay.StrumLine;
import flixel.util.FlxSort;
import flixel.system.FlxSound;
import base.SongLoader;
import openfl.media.Sound;
import flixel.FlxCamera;
import funkin.gameplay.FunkinUI;

using StringTools;

typedef UnspawnNote = {
	var strumTime:Float;
	var noteData:Int;
	var susLength:Float;
	var mustPress:Bool;
	var stepCrochet:Float;
	var altAnim:Bool;
}

class PlayState extends FunkinState {
    public static var songData:Song = SongLoader.returnSong("bopeebo", "hard");
    public static var current:PlayState;
    public static var isStoryMode:Bool = false;

    public var unspawnNotes:Array<UnspawnNote> = [];
    public var UI:FunkinUI;

    public var health:Float = 1.0;
    public var minHealth:Float = 0.0;
    public var maxHealth:Float = 2.0;

    public var healthGain:Float = 0.023;
    public var healthLoss:Float = 0.0475;

    /**
		Controls if the camera is allowed to lerp back to it's default zoom.
	**/
	public var camZooming:Bool = true;
	/**
		Controls if the camera is allowed to zoom in every few beats.
	**/
	public var camBumping:Bool = true;

	public var defaultCamZoom:Float = 1.0;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

    public var songSpeed:Float = 1.0;

    public var startedSong:Bool = false;
    public var endingSong:Bool = false;

    public var cachedSounds:Map<String, Sound> = [
        // Music
        "titleScreen" => Assets.load(SOUND, Paths.music("menus/titleScreen"))
    ];
    public var vocals:FlxSound = new FlxSound();

    public var currentSkin:String = "Default";

    public function new(songSpeed:Float = 1.0) {
        super();
        current = this;
        this.songSpeed = songSpeed;
    }

    override function create() {
        super.create();
        current = this;
		
        // Stop the currently playing music because grrr >:(
		FlxG.sound.music.stop();

        // Setup cameras
        camGame = FlxG.camera;
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor = 0x0;
		camOther.bgColor = 0x0;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

        // Setup song
        Conductor.changeBPM(songData.bpm);
        Conductor.mapBPMChanges(songData);
        Conductor.position = Conductor.crochet * -5;

        if(songData.keyCount == null)
            songData.keyCount = 4;

        if(songData.keyNumber != null)
            songData.keyCount = songData.keyNumber;

        if(songData.mania != null) {
			switch(songData.mania) {
				case 1: songData.keyCount = 6;
				case 2: songData.keyCount = 7;
				case 3: songData.keyCount = 9;
				default: songData.keyCount = 4;
			}
		}

        cachedSounds["inst"] = Assets.load(SOUND, Paths.songInst(songData.song));
        if(FileSystem.exists(Paths.songVoices(songData.song))) {
            cachedSounds["voices"] = Assets.load(SOUND, Paths.songVoices(songData.song));
            vocals.loadEmbedded(cachedSounds["voices"]);
        }
        FlxG.sound.list.add(vocals);

        // Load the notes
		for(section in songData.notes) {
			if(section != null) {
				for(note in section.sectionNotes) {
					var strumTime:Float = note[0];
					var gottaHitNote:Bool = section.mustHitSection;
					if (note[1] > (songData.keyCount - 1))
						gottaHitNote = !section.mustHitSection;

					var susLength:Float = note[2] / Conductor.stepCrochet;

					var altAnim:Bool = section.altAnim;
					if(note[3])
						altAnim = note[3];

					unspawnNotes.push({
						strumTime: strumTime, // 0 = strum tie m
						noteData: Std.int(note[1]) % songData.keyCount, // 1 = ntpeo data
						susLength: susLength, // 2 = sussy amongle sus length! (sustain length)
						mustPress: gottaHitNote, // 3 = must press
						stepCrochet: Conductor.stepCrochet, // 4 = sustain bullshit
						altAnim: altAnim // 5 = alt anim
					});
				}
			}
		}
		unspawnNotes.sort(unspawnNoteSorting);

        // Setup UI
        UI = new FunkinUI();
        UI.cameras = [camHUD];
        add(UI);
    }

    function unspawnNoteSorting(Obj1:UnspawnNote, Obj2:UnspawnNote):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

    override function update(elapsed:Float) {
        super.update(elapsed);

        Conductor.position += (elapsed * 1000.0) * songSpeed;
        if(Conductor.position >= 0 && !startedSong)
            startSong();

        if(!(Conductor.isAudioSynced(FlxG.sound.music) && Conductor.isAudioSynced(vocals)))
            resyncSong();

        for(note in unspawnNotes) {
			var parent:StrumLine = note.mustPress ? UI.playerStrums : UI.enemyStrums;
			var spawnMult:Float = (2500 / Math.abs(parent.noteSpeed)) * songSpeed;
			if(note.strumTime + (Settings.get("Note Offset") * songSpeed) > Conductor.position + spawnMult)
				break;

			var noteSkin:String = currentSkin.replace("Default", Settings.get("Note Skin"));

			var dunceNote:Note = new Note(-9999, -9999, parent, note.noteData, false, false, noteSkin);
			dunceNote.stepCrochet = Conductor.stepCrochet;
			dunceNote.rawStrumTime = note.strumTime;
			dunceNote.strumTime = note.strumTime + (Settings.get("Note Offset") * songSpeed);
			dunceNote.altAnim = note.altAnim;
			dunceNote.parent = note.mustPress ? UI.playerStrums : UI.enemyStrums;
            var event = new funkin.events.NoteCreationEvent();
            event.note = dunceNote;
            dunceNote.script.call("onNoteCreation", [event]);
            if(event.cancelled) {
                dunceNote.script.destroy();
                dunceNote.destroy();
                dunceNote = null;
            } else {
                // Make the note have a shader if it's enabled
                if(dunceNote.useRGBShader) {
                    var rgb = Note.keyInfo[parent.keyCount].colors[dunceNote.direction];
                    dunceNote.colorShader.setColors(rgb[0], rgb[1], rgb[2]);
                    dunceNote.shader = dunceNote.colorShader;
                };
                var cum:Int = Math.floor(note.susLength);
                for(i in 0...cum) {
                    var susNote:Note = new Note(-9999, -9999, parent, note.noteData, true, false, noteSkin);
                    susNote.stepCrochet = Conductor.stepCrochet;
                    susNote.rawStrumTime = note.strumTime;
                    susNote.strumTime = dunceNote.strumTime + (Conductor.stepCrochet * i) + Conductor.stepCrochet;
                    susNote.altAnim = note.altAnim;
                    susNote.parent = note.mustPress ? UI.playerStrums : UI.enemyStrums;
                    if(i >= cum-1) {
                        susNote.isSustainTail = true;
                        susNote.playAnim("tail");
                    }
                    var event = new funkin.events.NoteCreationEvent();
                    event.note = susNote;
                    susNote.script.call("onNoteCreation", [event]);
                    if(event.cancelled) {
                        susNote.script.destroy();
                        susNote.destroy();
                        susNote = null;
                    } else {
                        // Make the note have a shader if it's enabled
                        if(susNote.useRGBShader) {
                            var rgb = Note.keyInfo[parent.keyCount].colors[susNote.direction];
                            susNote.colorShader.setColors(rgb[0], rgb[1], rgb[2]);
                            susNote.shader = susNote.colorShader;
                        };
                        susNote.parent.notes.add(susNote);
                    }
                }
                dunceNote.parent.notes.add(dunceNote);
            }
			unspawnNotes.remove(note);
		}

        if(Controls.getP("back")) {
            endingSong = true;
            FlxG.sound.playMusic(cachedSounds["titleScreen"]);
            Main.switchState(new FreeplayMenu());
        }
    }

    public function resyncSong() {
        if(!startedSong || endingSong) return;
        
		if(cachedSounds.exists("vocals")) {
            FlxG.sound.music.pause();
            vocals.pause();
            Conductor.position = FlxG.sound.music.time;
            vocals.time = FlxG.sound.music.time;
            if(vocals.time < vocals.length)
                vocals.play();
            FlxG.sound.music.play();
		} else Conductor.position = FlxG.sound.music.time;
	}

    function startSong() {
        startedSong = true;
        Conductor.position = 0;
        FlxG.sound.playMusic(cachedSounds["inst"], 1, false);
        if(cachedSounds.exists("voices"))
            vocals.play();

        FlxG.sound.music.pause();
        vocals.pause();
        FlxG.sound.music.time = 0;
        vocals.time = 0;
        FlxG.sound.music.play();
        vocals.play();
    }

    override public function destroy() {
        current = null;
        super.destroy();
    }
}
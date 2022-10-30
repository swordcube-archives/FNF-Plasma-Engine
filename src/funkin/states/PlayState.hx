package funkin.states;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
import flixel.math.FlxMath;
import scripting.HScriptModule;
import haxe.io.Path;
import scripting.Script;
import scripting.ScriptModule;
import scripting.Script.ScriptGroup;
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
    // Song stuff
    public static var songData:Song = SongLoader.returnSong("bopeebo", "hard");
    public static var current:PlayState;
	public static var currentDifficulty:String = "hard";
	public static var availableDifficulties:Array<String> = ["easy", "normal", "hard"];
	public static var isStoryMode:Bool = false;
	public static var weekName:String = "";
	public static var storyScore:Int = 0;
	public static var storyPlaylist:Array<String> = [];
    public var vocals:FlxSound = new FlxSound();

    public var unspawnNotes:Array<UnspawnNote> = [];

    // UI
    public var UI:FunkinUI;

    // Health
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

	/**
	 * The amount of zoom the background has (UI is unaffected)
	 */
	public var defaultCamZoom:Float = 1.0;

    public var camFollow:FlxObject;
	public static var prevCamFollow:FlxObject;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

    public var startedSong:Bool = false;
    public var endingSong:Bool = false;

    // Sounds that are cached
    public var cachedSounds:Map<String, Sound> = [
        // Music
        "titleScreen" => Assets.load(SOUND, Paths.music("menus/titleScreen"))
    ];

    /**
     * The skin the notes use for the current song.
     * 
     * Change this to something else to forcefully override to a different skin.
     */
    public var currentSkin:String = "Default";

    // Accuracy Stuff
    public var combo:Int = 0;
    public var score:Int = 0;
    public var misses:Int = 0;
    public var totalNotes:Int = 0;
    public var totalHit:Float = 0.0;
    // uses a getter function because fuck you
    public var accuracy(get, null):Float;

    function get_accuracy() {
        var calculated:Float = 0;
        if((totalNotes+misses) != 0 && totalHit != 0.0)
            calculated = totalHit / (totalNotes+misses);
        return calculated;
    }

    // Scripts
    public var songScript:ScriptModule;
    public var scripts:ScriptGroup = new ScriptGroup();

    // Stage & Characters
    public var stage:Stage;

    public var dad:Character;
    public var gf:Character;
    public var bf:Character;

    public var dads:Array<Character> = [];
    public var bfs:Array<Character> = [];

    // Misc
    public var inCutscene:Bool = false;
    public var usedPractice:Bool = false;
	public var practiceMode:Bool = false;

    public var countdownProperties = {
        scale: 1,
        imagePath: "gameplay/countdown/default",
        soundPath: "gameplay/countdown/default"
    };

    public var judgementProperties = {
        ratingPath: "ui/judgements/default/judgements",
        comboPath: "ui/judgements/default/comboNumbers",

        ratingScale: 0.7,
        comboScale: 0.5,

        ratingAntialiasing: true,
        comboAntialiasing: true,

        ratingSize: [394, 152],
        comboSize: [150, 150]
    };

    public function new() {
        super();
        current = this;
    }

    override function create() {
        super.create();
        current = this;

        persistentUpdate = true;
        persistentDraw = true;
		
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

        countdownReady.antialiasing = Settings.get("Antialiasing");
		countdownReady.cameras = [camHUD];
		countdownReady.alpha = 0;
		add(countdownReady);

		countdownSet.antialiasing = Settings.get("Antialiasing");
		countdownSet.cameras = [camHUD];
		countdownSet.alpha = 0;
		add(countdownSet);

		countdownGo.antialiasing = Settings.get("Antialiasing");
		countdownGo.cameras = [camHUD];
		countdownGo.alpha = 0;
		add(countdownGo);

        camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 1);

        // Setup song
        Conductor.changeBPM(songData.bpm);
        Conductor.mapBPMChanges(songData);
        Conductor.position = Conductor.crochet * -5;

        if(songData.keyCount == null)
            songData.keyCount = 4;

        if(songData.keyNumber != null)
            songData.keyCount = songData.keyNumber;

        if(songData.stage == null)
            songData.stage = "default";

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

        DiscordRPC.changePresence(
            "Playing "+songData.song,
            "Starting song..."
        );

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
        
        // Setup scripts
        songScript = Script.create(Paths.hxs('songs/${songData.song.toLowerCase()}/script'));
        if(Std.isOfType(songScript, HScriptModule)) cast(songScript, HScriptModule).setScriptObject(this);
        songScript.start(true, []);
        for(item in CoolUtil.readDirectory('data/scripts/global')) {
            var path:String = "data/scripts/global/"+item.split("."+Path.extension(item))[0];
            var script:ScriptModule = Script.create(Paths.hxs(path));
            if(Std.isOfType(script, HScriptModule)) cast(script, HScriptModule).setScriptObject(this);
            script.start(true, []);
            scripts.addScript(script);
        }
        if(!inCutscene) startCountdown();
        // Initialize the gfVersion used for creating Girlfriend.
		var gfVersion:String = "gf";
		if(songData.player3 != null)
			gfVersion = songData.player3;
		if(songData.gfVersion != null)
			gfVersion = songData.gfVersion;
		if(songData.gf != null)
			gfVersion = songData.gf;
		songData.gf = gfVersion;
        // Setup stage + characters
        stage = new Stage().loadStage(songData.stage);
        add(stage);
        camGame.zoom = defaultCamZoom;
        var point = stage.characterPositions["dad"];
        dad = new Character(point.x, point.y).loadCharacter(songData.player2);
        if(gfVersion == songData.player2) {
            var point = stage.characterPositions["gf"];
            dad.setPosition(point.x, point.y);
            add(stage.layeredGroups[1]);
        } else {
            var point = stage.characterPositions["gf"];
            gf = new Character(point.x, point.y).loadCharacter(gfVersion);
            add(gf);
            add(stage.layeredGroups[1]);
        }
        add(dad);
        add(stage.layeredGroups[0]);
        var point = stage.characterPositions["bf"];
        bf = new Character(point.x, point.y, true).loadCharacter(songData.player1);
        add(bf);
        add(stage.layeredGroups[2]);
        moveCamera(!songData.notes[0].mustHitSection);
        dads.push(dad);
        bfs.push(bf);

        // Setup UI
        UI = new FunkinUI();
        UI.cameras = [camHUD];
        add(UI);

        scripts.call("onCreatePost", []);
    }

    function unspawnNoteSorting(Obj1:UnspawnNote, Obj2:UnspawnNote):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

    public function moveCamera(mustHitSection:Bool) {
		if(!mustHitSection) {
			if(dad == null) return;
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraOffset.x;
			camFollow.y += dad.cameraOffset.y;
		} else {
			if(bf == null) return;
			camFollow.setPosition(bf.getMidpoint().x - 100, bf.getMidpoint().y - 100);
			camFollow.x -= bf.cameraOffset.x;
			camFollow.y += bf.cameraOffset.y;
		}
	}

    // Countdown stuff!!
	public var countdownReady:Sprite = new Sprite();
	public var countdownSet:Sprite = new Sprite();
	public var countdownGo:Sprite = new Sprite();

	public var countdownTimer:FlxTimer;
	public var countdownTick:Int = 0;

	public function startCountdown() {
		if(scripts.call("onStartCountdown", [], true) != false) {
            var countdownSounds:Map<String, Sound> = [
                "3"  => Assets.load(SOUND, Paths.sound(countdownProperties.soundPath+"/intro3")),
                "2"  => Assets.load(SOUND, Paths.sound(countdownProperties.soundPath+"/intro2")),
                "1"  => Assets.load(SOUND, Paths.sound(countdownProperties.soundPath+"/intro1")),
                "go" => Assets.load(SOUND, Paths.sound(countdownProperties.soundPath+"/introGo")),
            ];
            var countdownTextures:Map<String, FlxGraphic> = [
                "ready" => Assets.load(IMAGE, Paths.image(countdownProperties.imagePath+"/ready")),
                "set"   => Assets.load(IMAGE, Paths.image(countdownProperties.imagePath+"/set")),
                "go"    => Assets.load(IMAGE, Paths.image(countdownProperties.imagePath+"/go")),
            ];
			countdownTimer = new FlxTimer().start((Conductor.crochet / 1000.0) / FlxG.sound.music.pitch, function(tmr:FlxTimer) {
				for(c in dads) {
					if(c != null && c.animation.curAnim != null && !c.animation.curAnim.name.startsWith("sing") && !c.stunned)
						c.dance();
				}
				if(gf != null && tmr.loopsLeft % gfSpeed == 0 && !gf.stunned) gf.dance();
				for(c in bfs) {
					if(c != null && c.animation.curAnim != null && !c.animation.curAnim.name.startsWith("sing") && !c.stunned)
						c.dance();
				}
				scripts.call("onCountdownTick", [countdownTick]);
				switch(countdownTick) {
					case 0:
						Conductor.position = Conductor.crochet * -4;
                        FlxG.sound.play(countdownSounds["3"]);
					case 1:
						Conductor.position = Conductor.crochet * -3;
						FlxG.sound.play(countdownSounds["2"]);
						countdownReady.loadGraphic(countdownTextures["ready"]);
						countdownReady.scale.set(countdownProperties.scale, countdownProperties.scale);
						countdownReady.updateHitbox();
						countdownReady.screenCenter();
						countdownReady.alpha = 1;
						FlxTween.tween(countdownReady, { alpha: 0 }, (Conductor.crochet / 1000.0) / FlxG.sound.music.pitch, { ease: FlxEase.cubeInOut });
					case 2:
						Conductor.position = Conductor.crochet * -2;
						FlxG.sound.play(countdownSounds["1"]);
						countdownSet.loadGraphic(countdownTextures["set"]);
						countdownSet.scale.set(countdownProperties.scale, countdownProperties.scale);
						countdownSet.updateHitbox();
						countdownSet.screenCenter();
						countdownSet.alpha = 1;
						FlxTween.tween(countdownSet, { alpha: 0 }, (Conductor.crochet / 1000.0) / FlxG.sound.music.pitch, { ease: FlxEase.cubeInOut });
					case 3:
						Conductor.position = Conductor.crochet * -1;
						FlxG.sound.play(countdownSounds["go"]);
						countdownGo.loadGraphic(countdownTextures["go"]);
						countdownGo.scale.set(countdownProperties.scale, countdownProperties.scale);
						countdownGo.updateHitbox();
						countdownGo.screenCenter();
						countdownGo.alpha = 1;
						FlxTween.tween(countdownGo, { alpha: 0 }, (Conductor.crochet / 1000.0) / FlxG.sound.music.pitch, { ease: FlxEase.cubeInOut });
				}
				scripts.call("onCountdownTickPost", [countdownTick]);
				countdownTick++;
			}, 5);
		}
	}

    override function update(elapsed:Float) {
        super.update(elapsed);

        var curSection:Int = Std.int(FlxMath.bound(curStep / 16, 0, songData.notes.length-1));
        FlxG.camera.followLerp = 0.04;
        moveCamera(songData.notes[curSection].mustHitSection);

        if(!endingSong) Conductor.position += (elapsed * 1000.0) * FlxG.sound.music.pitch;
        if(Conductor.position >= 0 && !startedSong)
            startSong();

        if(!(Conductor.isAudioSynced(FlxG.sound.music) && Conductor.isAudioSynced(vocals)))
            resyncSong();

        for (c in bfs) {
			if (c != null && c.animation.curAnim != null && c.holdTimer > Conductor.stepCrochet * c.singDuration * 0.001
				&& !UI.playerStrums.pressed.contains(true)) {
				if (c.animation.curAnim.name.startsWith('sing') && !c.animation.curAnim.name.endsWith('miss')) {
					c.holdTimer = 0;
					c.dance();
				}
			}
		}
        for(note in unspawnNotes) {
			var parent:StrumLine = note.mustPress ? UI.playerStrums : UI.enemyStrums;
			var spawnMult:Float = (2500 / Math.abs(parent.noteSpeed)) * FlxG.sound.music.pitch;
			if(note.strumTime + (Settings.get("Note Offset") * FlxG.sound.music.pitch) > Conductor.position + spawnMult)
				break;

			var noteSkin:String = currentSkin.replace("Default", Settings.get("Note Skin"));

			var dunceNote:Note = new Note(-9999, -9999, parent, note.noteData, false, false, noteSkin);
			dunceNote.stepCrochet = Conductor.stepCrochet;
			dunceNote.rawStrumTime = note.strumTime;
			dunceNote.strumTime = note.strumTime + (Settings.get("Note Offset") * FlxG.sound.music.pitch);
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
                    susNote.alpha = 0.6;
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
            persistentUpdate = false;
			persistentDraw = true;
            endingSong = true;
            rpcTimer.cancel();
            FlxG.sound.music.stop();
            FlxG.sound.music.time = 0;
            vocals.stop();
            FlxG.sound.playMusic(cachedSounds["titleScreen"]);
            Main.switchState(new FreeplayMenu());
        }
    }

    public function finishSong(?ignoreNoteOffset:Bool = false) {
		endingSong = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.time = 0;

		if((Settings.get("Note Offset") * FlxG.sound.music.pitch) <= 0 || ignoreNoteOffset) {
			endSong();
		} else {
			new FlxTimer().start((Settings.get("Note Offset") * FlxG.sound.music.pitch) / 1000, function(tmr:FlxTimer) {
				endSong();
			});
		}
	}

    public function endSong() {
		if(inCutscene) return;
        persistentUpdate = false;
        persistentDraw = true;
        
        endingSong = true;
        
        if(!usedPractice && score > Highscore.getScore(songData.song+"-"+currentDifficulty))
            Highscore.setScore(songData.song+"-"+currentDifficulty, score);

        if(scripts.call("onEndSong", [songData.song], true) != false) {
            if(vocals != null)
                vocals.stop();

            FlxG.sound.playMusic(cachedSounds["titleScreen"]);
            FlxG.sound.music.time = 0;

            unspawnNotes = [];
            for(note in UI.enemyStrums.notes.members) {
                UI.enemyStrums.notes.remove(note, true);
                note.destroy();
                note = null;
            }
            for(note in UI.playerStrums.notes.members) {
                UI.playerStrums.notes.remove(note, true);
                note.destroy();
                note = null;
            }
            if(isStoryMode) {
                storyPlaylist.shift();
                storyScore += score;

                prevCamFollow = camFollow;

                if(storyPlaylist.length > 0) {
                    songData = SongLoader.returnSong(storyPlaylist[0], currentDifficulty);
                    Main.switchState(new funkin.states.PlayState());
                } else {
                    if(storyScore > Highscore.getScore(weekName+"-"+currentDifficulty))
                        Highscore.setScore(weekName+"-"+currentDifficulty, storyScore);
                    
                    Main.switchState(new funkin.states.MainMenu()); //REPLACE WITH STORY MENU!!!
                }
            }
            else
                Main.switchState(new funkin.states.FreeplayMenu());
        }

        scripts.call("onEndSongPost", [songData.song]);
        scripts.call("endSongPost", [songData.song]);
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

    public var gfSpeed:Int = 1;
    
    override function beatHit(curBeat:Int) {
        if(endingSong) return;
        scripts.call("onBeatHit", [curBeat]);
		var curSection:Int = Std.int(FlxMath.bound(curStep / 16, 0, songData.notes.length-1));
		if (songData.notes[curSection].changeBPM)
			Conductor.changeBPM(songData.notes[curSection].bpm);

		for(c in dads) {
			if(c != null && c.animation.curAnim != null && !c.animation.curAnim.name.startsWith("sing") && !c.stunned)
				c.dance();
		}
		if(gf != null && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("hair") && curBeat % gfSpeed == 0 && !gf.stunned) gf.dance();
		for(c in bfs) {
			if(c != null && c.animation.curAnim != null && !c.animation.curAnim.name.startsWith("sing") && !c.stunned)
				c.dance();
		}
        UI.beatHit(curBeat);
        super.beatHit(curBeat);
        scripts.call("onBeatHitPost", [curBeat]);
    }

    override function stepHit(curStep:Int) {
        if(endingSong) return;
        scripts.call("onStepHit", [curStep]);
        super.stepHit(curStep);
        scripts.call("onStepHitPost", [curStep]);
    }

    public var rpcTimer:FlxTimer;

    function startSong() {
        startedSong = true;
        Conductor.position = 0;
        FlxG.sound.playMusic(cachedSounds["inst"], 1, false);
        if(cachedSounds.exists("voices"))
            vocals.play();

        FlxG.sound.music.onComplete = finishSong.bind();
        FlxG.sound.music.pause();
        vocals.pause();
        FlxG.sound.music.time = 0;
        vocals.time = 0;
        FlxG.sound.music.pitch = Conductor.rate;
        vocals.pitch = Conductor.rate;
        FlxG.sound.music.play();
        vocals.play();

        DiscordRPC.changePresence(
            "Playing "+songData.song,
            'Time remaining: ${FlxStringUtil.formatTime(FlxG.sound.music.length/1000.0)} / ${FlxStringUtil.formatTime(FlxG.sound.music.length/1000.0)}'
        );
        rpcTimer = new FlxTimer().start(1, function(tmr:FlxTimer) {
            if(startedSong && !endingSong) {
                DiscordRPC.changePresence(
                    "Playing "+songData.song,
                    'Time remaining: ${FlxStringUtil.formatTime((FlxG.sound.music.length-FlxG.sound.music.time)/1000.0)} / ${FlxStringUtil.formatTime(FlxG.sound.music.length/1000.0)}'
                );
            }
        }, 0);
    }

    override public function destroy() {
        current = null;
        super.destroy();
    }
}
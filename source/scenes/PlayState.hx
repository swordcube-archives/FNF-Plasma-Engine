package scenes;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import funkin.Ranking;
import funkin.Song;
import funkin.gameplay.Boyfriend;
import funkin.gameplay.Character;
import funkin.gameplay.Note;
import funkin.gameplay.StageGroup;
import funkin.gameplay.StrumLine;
import funkin.gameplay.UI;
import modding.HScript;
import modding.Script;
import openfl.media.Sound;
import scenes.subscenes.ScriptedSubscene;

using StringTools;

typedef UnspawnNote = {
	var strumTime:Float; // 0 = strum tie m
	var noteData:Int; // 1 = ntpeo data
	var susLength:Float; // 2 = sussy amongle sus length! (sustain length)
	var mustPress:Bool; // 3 = must press
	var stepCrochet:Float; // 4 = sustain bullshit
	var altAnim:Bool; // 5 = alt anim
}

class PlayState extends Scene {
    public static var current:PlayState;
    public static var SONG:Song = SongLoader.returnSong("tutorial", "hard");
	public static var songName:String = "Tutorial";
    public static var paused:Bool = false;
	public static var currentDifficulty:String = "hard";
	public static var availableDifficulties:Array<String> = ["easy", "normal", "hard"];
	public static var isStoryMode:Bool = false;
	public static var weekName:String = "";
	public static var storyScore:Int = 0;
	public static var storyPlaylist:Array<String> = [];

	public var unspawnNotes:Array<UnspawnNote> = [];

    public static var songMultiplier:Float = 1.0;

    public var health:Float = 1.0;
    public var minHealth:Float = 0.0;
    public var maxHealth:Float = 2.0;

    public var healthGain:Float = 0.023;
	public var healthLoss:Float = 0.0475;

    public var botPlay:Bool = Settings.get("Botplay");

    public var combo:Int = 0;
    public var totalNotes:Int = 0;
    public var totalHit:Float = 0;

    public var songScore:Int = 0;
    public var songMisses:Int = 0;
    public var customHealth:Bool = false;

    public var songAccuracy:Float = 0;

    public var vocals:FlxSound = new FlxSound();

	public var stage:StageGroup;

	public var dad:Character;
	public var gf:Character;
	public var bf:Boyfriend;

	public var dads:Array<Character> = [];
	public var bfs:Array<Boyfriend> = [];

	public var script:Script;
    public var scripts:ScriptGroup = new ScriptGroup([]);

	public var loadedSong:Map<String, Sound> = [];

	public var currentSkin:String = "default";

	public var ratingAssetPath:String = "ui/judgements/ratings/default";
	public var comboAssetPath:String = "ui/judgements/combo/default";

	public var countdownImageLocation = "ui/countdown/default";
	public var countdownSoundLocation = "ui/countdown/default";

	public var countdownGraphics:Map<String, FlxGraphic> = [];
	public var countdownSounds:Map<String, Sound> = [];

	public var ratingScale:Float = 0.7;
	public var comboScale:Float = 0.5;
	public var countdownScale:Float = 1.0;

	public var ratingAntialiasing:Bool = true;
	public var comboAntialiasing:Bool = true;

	public var usedPractice:Bool = false;
	public var practiceMode:Bool = false;

	public var cachedRatings:Map<String, FlxGraphic> = [];
	public var cachedCombo:Map<String, Map<String, FlxGraphic>> = [];

    public var UI:UI;

	public var camZooming:Bool = true;
	public var camBumping:Bool = true;

	public var defaultCamZoom:Float = 1.0;
	public var cameraSpeed:Float = 1.0;

	public var camFollow:FlxObject;
	public static var prevCamFollow:FlxObject;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	public var inCutscene:Bool = false;
	public var startedSong:Bool = false;
	public var endingSong:Bool = false;

	public var luaVars:Map<String, Dynamic> = [];
	public var luaTweens:Map<String, Tween> = [];
	public var luaTimers:Map<String, FlxTimer> = [];
	public var luaSounds:Map<String, FlxSound> = [];

	public var freakyMenu:Sound = Assets.get(SOUND, Paths.music("freakyMenu"));

	// This is basically static variables but only for PlayState and they get reset when going to any other scene.
	// Static variables do not get reset and remain at their current value until the game closes.
	public var global:Map<String, Dynamic> = [];

	public function calculateAccuracy() {
		if(totalNotes != 0 && totalHit != 0)
			songAccuracy = totalHit / totalNotes;
		else
			songAccuracy = 0;
	}

	public function new() {
		super();
		current = this;
	}

    override function start() {
        current = this;

		Ranking.judgements = Ranking.defaultJudgements.copy();

		persistentUpdate = true;
		persistentDraw = true;

		// Initialize the cameras
		camGame = FlxG.camera;
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor = 0x0;
		camOther.bgColor = 0x0;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 1);
        
		// Initialize music
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		FlxG.sound.list.add(vocals);

		// Initialize song data
		if(SONG == null)
			SONG = SongLoader.returnSong("tutorial", "hard");

		if(SONG.keyCount == null)
			SONG.keyCount = 4;

		if(SONG.keyNumber != null)
			SONG.keyCount = SONG.keyNumber;

		if(SONG.mania != null) {
			switch(SONG.mania) {
				case 1: SONG.keyCount = 6;
				case 2: SONG.keyCount = 7;
				case 3: SONG.keyCount = 9;
				default: SONG.keyCount = 4;
			}
		}

		// Initialize the conductor
		Conductor.changeBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);
		Conductor.position = Conductor.crochet * -5;

		// Load the notes
		for(section in SONG.notes) {
			if(section != null) {
				for(note in section.sectionNotes) {
					var strumTime:Float = note[0];
					var gottaHitNote:Bool = section.mustHitSection;
					if (note[1] > (SONG.keyCount - 1))
						gottaHitNote = !section.mustHitSection;

					var susLength:Float = note[2] / Conductor.stepCrochet;

					var altAnim:Bool = section.altAnim;
					if(note[3])
						altAnim = note[3];

					unspawnNotes.push({
						strumTime: strumTime, // 0 = strum tie m
						noteData: Std.int(note[1] % SONG.keyCount), // 1 = ntpeo data
						susLength: susLength, // 2 = sussy amongle sus length! (sustain length)
						mustPress: gottaHitNote, // 3 = must press
						stepCrochet: Conductor.stepCrochet, // 4 = sustain bullshit
						altAnim: altAnim // 5 = alt anim
					});
				}
			}
		}

		unspawnNotes.sort(sortByShit);

		// Preload the song
		loadedSong["inst"] = Assets.get(SOUND, Paths.songInst(SONG.song.toLowerCase()));
		if(FileSystem.exists(Paths.songVoices(SONG.song.toLowerCase()))) {
			loadedSong["vocals"] = Assets.get(SOUND, Paths.songVoices(SONG.song.toLowerCase()));
			vocals.loadEmbedded(loadedSong["vocals"]);
		}

		// Initialize the gfVersion used for creating Girlfriend.
		var gfVersion:String = "gf";

		if(SONG.player3 != null)
			gfVersion = SONG.player3;
		
		if(SONG.gfVersion != null)
			gfVersion = SONG.gfVersion;

		if(SONG.gf != null)
			gfVersion = SONG.gf;

		// Load song's script
		script = Script.createScript('songs/${SONG.song.toLowerCase()}/script');
		if(script.type == "hscript")
			cast(script, HScript).setScriptObject(this);
		script.start();
		scripts.addScript(script);

		// Load song's list of scripts
		if(SONG.scripts != null && SONG.scripts.length > 0) {
			for(item in SONG.scripts) {
				var ext:String = Path.extension(item);
				var script = Script.createScript(item.split("."+ext)[0]);
				if(script.type == "hscript")
					cast(script, HScript).setScriptObject(this);
				script.start();
				scripts.addScript(script);
			}
		}

		// Load global scripts
		for(item in CoolUtil.readDirectory("global_scripts")) {
			var ext:String = Path.extension(item);
			var path:String = 'global_scripts/${item.split("."+ext)[0]}';
			var script = Script.createScript(path);
			if(script.type == "hscript")
				cast(script, HScript).setScriptObject(this);
			script.start();
			scripts.addScript(script);
		}

		// Preload judgement graphics
		cachedRatings = PlasmaAssets.getRatingCache(ratingAssetPath);
		cachedCombo = PlasmaAssets.getComboCache(comboAssetPath);

		// Preload countdown graphics
		countdownGraphics = [
			"preready"   => Assets.get(IMAGE, Paths.image(countdownImageLocation+"/preready")),
			"ready"      => Assets.get(IMAGE, Paths.image(countdownImageLocation+"/ready")),
			"set"        => Assets.get(IMAGE, Paths.image(countdownImageLocation+"/set")),
			"go"         => Assets.get(IMAGE, Paths.image(countdownImageLocation+"/go")),
		];

		countdownSounds = [
			"preready"   => Assets.get(SOUND, Paths.sound(countdownSoundLocation+"/intro3")),
			"ready"      => Assets.get(SOUND, Paths.sound(countdownSoundLocation+"/intro2")),
			"set"        => Assets.get(SOUND, Paths.sound(countdownSoundLocation+"/intro1")),
			"go"         => Assets.get(SOUND, Paths.sound(countdownSoundLocation+"/introGo")),
		];

		countdownPreReady.antialiasing = Settings.get("Antialiasing");
		countdownPreReady.cameras = [camHUD];
		countdownPreReady.alpha = 0;
		add(countdownPreReady);

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

		if(!inCutscene)
			startCountdown();

		// Load stage
		if(!Settings.get("Ultra Performance")) {
			stage = new StageGroup().load(SONG.stage != null ? SONG.stage : "stage");
			add(stage);
			FlxG.camera.zoom = defaultCamZoom;
			scripts.call("onCreateAfterStage");
			scripts.call("createAfterStage");
			scripts.call("onStartAfterStage");
			scripts.call("startAfterStage");

			// Load characters
			var pos:FlxPoint = stage.dadPosition;
			dad = new Character(pos.x, pos.y);
			dad.loadCharacter(SONG.player2);
			dad.isPlayer = false;
			dads.push(dad);
			add(stage.layeredSprites[0]);

			var pos:FlxPoint = stage.gfPosition;
			if(SONG.player2 != gfVersion) {
				gf = new Character(pos.x, pos.y);
				gf.loadCharacter(gfVersion);
				add(gf);
				add(stage.layeredSprites[1]);
				add(dad);
			} else {
				dad.setPosition(pos.x, pos.y);
				add(dad);
				add(stage.layeredSprites[1]);
			}
			
			var pos:FlxPoint = stage.bfPosition;
			bf = new Boyfriend(pos.x, pos.y);
			bf.loadCharacter(SONG.player1);
			bf.flipX = !bf.flipX;
			add(bf);
			bfs.push(bf);
			add(stage.layeredSprites[2]);
		} else {
			scripts.call("onCreateAfterStage");
			scripts.call("createAfterStage");
			scripts.call("onStartAfterStage");
			scripts.call("startAfterStage");
		}

		moveCamera(!SONG.notes[0].mustHitSection);
		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		scripts.call("onCreateAfterChars");
		scripts.call("createAfterChars");
		scripts.call("onStartAfterChars");
		scripts.call("startAfterChars");

		// Load UI
        UI = new UI();
        UI.cameras = [camHUD];
        add(UI);

		scripts.call("onCreateAfterUI");
		scripts.call("createAfterUI");
		scripts.call("onStartAfterUI");
		scripts.call("startAfterUI");

		scripts.call("onCreatePost");
		scripts.call("createPost");
		scripts.call("onStartPost");
		scripts.call("startPost");
    }

	function sortByShit(Obj1:UnspawnNote, Obj2:UnspawnNote):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	override function process(delta:Float) {
		if(Controls.BACK_P) {
			persistentUpdate = false;
			persistentDraw = true;
			endingSong = true;
			FlxG.sound.music.stop();
			vocals.stop();
			scripts.destroy();
			FlxG.sound.playMusic(freakyMenu);
			if(isStoryMode)
				Main.switchScene(new ScriptedScene("StoryMenu"));
			else
				Main.switchScene(new ScriptedScene("FreeplayMenu"));
		}

		if(camZooming) {
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, 0.05 * 60 * delta);
			camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, 0.05 * 60 * delta);
		}

		scripts.call("onUpdate", [delta]);
		scripts.call("update", [delta]);
		scripts.call("onProcess", [delta]);
		scripts.call("process", [delta]);

		if(!inCutscene) {
			if(!startedSong)
				Conductor.position += delta*1000;
			else
				Conductor.position += (delta*1000)*songMultiplier;

			if(Conductor.position >= 0 && !startedSong)
				startSong();
		}

		for (c in bfs) {
			if (c != null && c.animation.curAnim != null && c.holdTimer > Conductor.stepCrochet * c.singDuration * 0.001
				&& !UI.playerStrums.pressed.contains(true))
			{
				if (c.animation.curAnim.name.startsWith('sing') && !c.animation.curAnim.name.endsWith('miss')) {
					c.holdTimer = 0;
					c.dance();
				}
			}
		}

		for(note in unspawnNotes) {
			var parent:StrumLine = note.mustPress ? UI.playerStrums : UI.enemyStrums;
			var spawnMult:Float = (2500 / Math.abs(parent.noteSpeed)) * songMultiplier;
			if(note.strumTime + (Settings.get("Note Offset") * songMultiplier) > Conductor.position + spawnMult)
				break;

			var noteSkin:String = currentSkin.replace("default", Settings.get("Note Skin").toLowerCase());

			var dunceNote:Note = new Note(-9999, -9999, note.noteData, false);
			dunceNote.stepCrochet = Conductor.stepCrochet;
			dunceNote.rawStrumTime = note.strumTime;
			dunceNote.strumTime = note.strumTime + (Settings.get("Note Offset") * songMultiplier);
			dunceNote.altAnim = note.altAnim;
			dunceNote.parent = note.mustPress ? UI.playerStrums : UI.enemyStrums;
			dunceNote.keyAmount = dunceNote.parent.keyAmount;
			dunceNote.loadSkin(noteSkin);

			var cum:Int = Math.floor(note.susLength);
			for(i in 0...cum) {
				var susNote:Note = new Note(-9999, -9999, note.noteData, true);
				susNote.stepCrochet = Conductor.stepCrochet;
				susNote.rawStrumTime = note.strumTime;
				susNote.strumTime = dunceNote.strumTime + (Conductor.stepCrochet * i) + Conductor.stepCrochet;
				susNote.altAnim = note.altAnim;
				susNote.parent = note.mustPress ? UI.playerStrums : UI.enemyStrums;
				susNote.keyAmount = susNote.parent.keyAmount;
				susNote.loadSkin(noteSkin);
				if(i >= cum-1)
					susNote.playAnim("tail");

				susNote.parent.notes.add(susNote);
			}

			dunceNote.parent.notes.add(dunceNote);
			unspawnNotes.remove(note);
		}

		FlxG.camera.followLerp = 0.04*cameraSpeed;
		var curSection:Int = Std.int(FlxMath.bound(Conductor.curStep/16, 0, SONG.notes.length-1));
		moveCamera(SONG.notes[curSection].mustHitSection);

		if(!customHealth && health <= minHealth) {
			health = minHealth;
			gameOver();
		}

		for(s in scripts.scripts) {
			if(s.type == "lua") {
				s.set("curBpm", Conductor.bpm);
				s.set("songPosition", Conductor.position);
				s.set("curBeat", Conductor.curBeat);
				s.set("curBeatFloat", Conductor.curBeatFloat);
				s.set("curStep", Conductor.curStep);
				s.set("curStepFloat", Conductor.curStepFloat);
				s.set("crochet", Conductor.crochet);
				s.set("stepCrochet", Conductor.stepCrochet);
				s.set('currentFPS', Main.fpsCounter.currentFPS);
			} else continue;
		}

		scripts.call("onUpdatePost", [delta]);
		scripts.call("updatePost", [delta]);
		scripts.call("onProcessPost", [delta]);
		scripts.call("processPost", [delta]);
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

	public var countdownPreReady:Sprite = new Sprite();
	public var countdownReady:Sprite = new Sprite();
	public var countdownSet:Sprite = new Sprite();
	public var countdownGo:Sprite = new Sprite();

	public var countdownTimer:FlxTimer;

	public var countdownTick:Int = 0;

	public var countdownAttempts:Int = 0;

	public function startCountdown() {
		// onStartCountdown only because startCountdown is a function
		if(scripts.call("onStartCountdown", [], true) != false) {
			for(s in scripts.scripts) {
				if(s.type == "lua") {
					s.set("startedCountdown", true);
				} else continue;
			}

			countdownTimer = new FlxTimer().start(Conductor.crochet / 1000.0, function(tmr:FlxTimer) {
				for(c in dads) {
					if(c != null && c.animation.curAnim != null && !c.animation.curAnim.name.startsWith("sing") && !c.stunned)
						c.dance();
				}
		
				if(gf != null && tmr.loopsLeft % gfSpeed == 0 && !gf.stunned)
					gf.dance();
		
				for(c in bfs) {
					if(c != null && c.animation.curAnim != null && !c.animation.curAnim.name.startsWith("sing") && !c.stunned)
						c.dance();
				}

				scripts.call("onCountdownTick", [countdownTick]);
				scripts.call("countdownTick", [countdownTick]);
				switch(countdownTick) {
					case 0:
						Conductor.position = Conductor.crochet * -4;
						FlxG.sound.play(countdownSounds["preready"]);
						countdownPreReady.loadGraphic(countdownGraphics["preready"]);
						countdownPreReady.scale.set(countdownScale, countdownScale);
						countdownPreReady.updateHitbox();
						countdownPreReady.screenCenter();
						countdownPreReady.alpha = 1;
						Tween.tween(countdownPreReady, { alpha: 0 }, Conductor.crochet / 1000.0, { ease: Ease.cubeInOut });
					case 1:
						Conductor.position = Conductor.crochet * -3;
						FlxG.sound.play(countdownSounds["ready"]);
						countdownReady.loadGraphic(countdownGraphics["ready"]);
						countdownReady.scale.set(countdownScale, countdownScale);
						countdownReady.updateHitbox();
						countdownReady.screenCenter();
						countdownReady.alpha = 1;
						Tween.tween(countdownReady, { alpha: 0 }, Conductor.crochet / 1000.0, { ease: Ease.cubeInOut });
					case 2:
						Conductor.position = Conductor.crochet * -2;
						FlxG.sound.play(countdownSounds["set"]);
						countdownSet.loadGraphic(countdownGraphics["set"]);
						countdownSet.scale.set(countdownScale, countdownScale);
						countdownSet.updateHitbox();
						countdownSet.screenCenter();
						countdownSet.alpha = 1;
						Tween.tween(countdownSet, { alpha: 0 }, Conductor.crochet / 1000.0, { ease: Ease.cubeInOut });
					case 3:
						Conductor.position = Conductor.crochet * -1;
						FlxG.sound.play(countdownSounds["go"]);
						countdownGo.loadGraphic(countdownGraphics["go"]);
						countdownGo.scale.set(countdownScale, countdownScale);
						countdownGo.updateHitbox();
						countdownGo.screenCenter();
						countdownGo.alpha = 1;
						Tween.tween(countdownGo, { alpha: 0 }, Conductor.crochet / 1000.0, { ease: Ease.cubeInOut });
				}
				scripts.call("onCountdownTickPost", [countdownTick]);
				scripts.call("countdownTickPost", [countdownTick]);

				countdownTick++;
			}, 5);
		}
	}

	public function startSong() {
		startedSong = true;
		scripts.call("onStartSong");
		scripts.call("startSong");

		FlxG.sound.playMusic(loadedSong["inst"], 1, false);
		FlxG.sound.music.pitch = songMultiplier;
		if(loadedSong.exists("vocals")) {
			vocals.pitch = songMultiplier;
			vocals.volume = 1;
			vocals.play();
		}

		FlxG.sound.music.onComplete = finishSong.bind();

		Conductor.position = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		vocals.time = 0;
		FlxG.sound.music.time = 0;

		FlxG.sound.music.play();
		vocals.play();

		scripts.call("onStartSongPost");
		scripts.call("startSongPost");
	}

	public function finishSong(?ignoreNoteOffset:Bool = false) {
		endingSong = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.time = 0;

		if((Settings.get("Note Offset") * songMultiplier) <= 0 || ignoreNoteOffset) {
			endSong();
		} else {
			new FlxTimer().start((Settings.get("Note Offset") * songMultiplier) / 1000, function(tmr:FlxTimer) {
				endSong();
			});
		}
	}

	public function endSong() {
		if(!inCutscene) {
			persistentUpdate = false;
			persistentDraw = true;
			
			endingSong = true;
			
			if(!usedPractice && songScore > Highscore.getScore(songName+"-"+currentDifficulty))
				Highscore.setScore(songName+"-"+currentDifficulty, songScore);

			if(scripts.call("onEndSong", [songName], true) != false) {
				if(vocals != null)
					vocals.stop();

				FlxG.sound.playMusic(freakyMenu);
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
					storyScore += songScore;

					prevCamFollow = camFollow;

					if(storyPlaylist.length > 0) {
						SONG = SongLoader.returnSong(storyPlaylist[0], currentDifficulty);
						Main.switchScene(new scenes.PlayState());
					} else {
						if(storyScore > Highscore.getScore(weekName+"-"+currentDifficulty))
							Highscore.setScore(weekName+"-"+currentDifficulty, storyScore);
						
						Main.switchScene(new ScriptedScene("StoryMenu"));
					}
				}
				else
					Main.switchScene(new ScriptedScene("FreeplayMenu"));
			}

			scripts.call("onEndSongPost", [songName]);
			scripts.call("endSongPost", [songName]);
		}
	}

	public function gameOver() {
		if(scripts.call("onGameOver", [], true) != false) {
			if(!practiceMode) {
				persistentUpdate = false;
				persistentDraw = false;

				var deathInfo = {
					x: 700.0,
					y: 360.0,
					camX: camFollow.x,
					camY: camFollow.y,
					deathChar: "bf-dead"
				};
				if(bf != null)
					deathInfo = {
						x: bf.x,
						y: bf.y,
						camX: camFollow.x,
						camY: camFollow.y,
						deathChar: bf.deathCharacter
					};
				
				openSubState(new ScriptedSubscene('GameOver', [deathInfo.x, deathInfo.y, deathInfo.camX, deathInfo.camY, deathInfo.deathChar]));
			}
		}
	}

	public static function playVideo(path:String, callback:Void->Void) {
		#if VIDEOS_ALLOWED
		var video:VideoHandler = new VideoHandler();
		video.finishCallback = callback;
		video.playVideo(Paths.video(path));
		#else
		callback();
		#end
	}

	public static function playVideoSprite(path:String, callback:Void->Void) {
		#if VIDEOS_ALLOWED
		var video:VideoSprite = new VideoSprite();
		video.finishCallback = callback;
		video.playVideo(Paths.video(path));
		return video;
		#else
		callback();
		#end
	}

	public var gfSpeed:Int = 1;

	override function beatHit(curBeat:Int) {
		if(endingSong) return;

		var curSection:Int = Std.int(FlxMath.bound(Conductor.curStep / 16, 0, SONG.notes.length-1));
		if (SONG.notes[curSection].changeBPM)
			Conductor.changeBPM(SONG.notes[curSection].bpm);

		for(c in dads) {
			if(c != null && c.animation.curAnim != null && !c.animation.curAnim.name.startsWith("sing") && !c.stunned)
				c.dance();
		}

		if(gf != null && curBeat % gfSpeed == 0 && !gf.stunned)
			gf.dance();

		for(c in bfs) {
			if(c != null && c.animation.curAnim != null && !c.animation.curAnim.name.startsWith("sing") && !c.stunned)
				c.dance();
		}

		scripts.call("onBeatHit", [curBeat]);
		scripts.call("beatHit", [curBeat]);

		if(camZooming && camBumping && Conductor.curBeat % 4 == 0) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if(startedSong) resyncSong();

		scripts.call("onBeatHitPost", [curBeat]);
		scripts.call("beatHitPost", [curBeat]);
	}

	override function stepHit(curBeat:Int) {
		if(endingSong) return;

		scripts.call("onStepHit", [curBeat]);
		scripts.call("stepHit", [curBeat]);

		scripts.call("onStepHitPost", [curBeat]);
		scripts.call("stepHitPost", [curBeat]);
	}

	public function clearNotesBefore(time:Float) {
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:UnspawnNote = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
				unspawnNotes.remove(daNote);
			--i;
		}

		i = UI.enemyStrums.notes.length - 1;
		while (i >= 0) {
			var daNote:Note = UI.enemyStrums.notes.members[i];
			if(daNote.strumTime - 350 < time) {
				daNote.kill();
				UI.enemyStrums.notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}

		i = UI.playerStrums.notes.length - 1;
		while (i >= 0) {
			var daNote:Note = UI.playerStrums.notes.members[i];
			if(daNote.strumTime - 350 < time) {
				daNote.kill();
				UI.playerStrums.notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function resyncSong() {
		if(loadedSong.exists("vocals")) {
			if(!(Conductor.isAudioSynced(FlxG.sound.music) && Conductor.isAudioSynced(vocals))) {
				vocals.pause();

				FlxG.sound.music.play();
				Conductor.position = FlxG.sound.music.time;
				vocals.time = FlxG.sound.music.time;
				if(vocals.time < vocals.length)
					vocals.play();
			}
		} else {
			if(!Conductor.isAudioSynced(FlxG.sound.music))
				Conductor.position = FlxG.sound.music.time;
		}
	}

    override function destroy() {
		scripts.destroy();
		current = null;
		super.destroy();
	}
}
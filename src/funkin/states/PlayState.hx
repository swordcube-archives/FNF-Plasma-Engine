package funkin.states;

import flixel.addons.transition.FlxTransitionableState;
import funkin.states.menus.StoryMenuState.StorySong;
import funkin.substates.GameOverSubstate;
import funkin.game.Ranking;
import flixel.FlxObject;
import haxe.io.Path;
import funkin.scripting.events.SimpleNoteEvent;
import flixel.util.FlxStringUtil;
import funkin.game.Note;
import funkin.game.StrumLine;
import flixel.util.FlxSort;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import funkin.game.UILayer;
import funkin.system.FNFTools;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import funkin.game.Character;
import funkin.scripting.Script;
import funkin.game.Stage;
import openfl.media.Sound;
import funkin.system.ChartParser;
import flixel.system.FlxSound;
import funkin.system.FNFSprite;

using StringTools;

/**
	The class that handles gameplay.
**/
class PlayState extends FNFState {
	public static var paused:Bool = false;
	public static var SONG:Song = ChartParser.loadSong(BASE, "tutorial");
	public static var curDifficulty:String = "normal";
	public static var weekName:String = "tutorial";
	public static var storyScore:Int = 0;
	public static var isStoryMode:Bool = false;
	public static var storyPlaylist:Array<StorySong> = [];
	public static var current:PlayState;

	public var script:ScriptModule;
	public var scripts:ScriptGroup = new ScriptGroup();
	public var stage:Stage;

	public var gfSpeed:Int = 1;

	public var startingSong:Bool = true;
	public var endingSong:Bool = false;

	public var camBumping:Bool = true;
	public var camZooming:Bool = true;

	public var dad:Character;
	public var gf:Character;
	public var bf:Character;

	public var health:Float = 1;
	public var minHealth:Float = 0;
	public var maxHealth:Float = 2;

	public var opponentHealth(get, null):Float;

	function get_opponentHealth() {
		return maxHealth - health;
	}

	public var healthGain:Float = 0.023;
	public var healthLoss:Float = 0.0475;

	public var dads:Array<Character> = [];
	public var bfs:Array<Character> = [];

	public var UI:UILayer;

    public var camFollow:FlxObject;
	public static var prevCamFollow:FlxObject;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	public var cachedSounds:Map<String, Sound> = [
		"menuMusic"  => Assets.load(SOUND, Paths.music("menuMusic")),
		"inst"       => Assets.load(SOUND, Paths.inst(SONG.name)),
		"voices"     => Assets.load(SOUND, Paths.voices(SONG.name))
	];
	public var vocals:FlxSound = new FlxSound();

	public function new() {
		super();
		current = this;
	}

	public var score:Int = 0;
	public var misses:Int = 0;
	public var rank(get, null):String;

	function get_rank() {
		return Ranking.getRank(accuracy * 100.0);
	}

	public var totalNotes:Int = 0;
	public var totalHit:Float = 0.0;
	public var combo:Int = 0;
	public var accuracy(get, null):Float = 0.0;

	function get_accuracy():Float {
		if(totalNotes == 0 || totalHit == 0) return 0.0;
		return totalHit / (totalNotes+misses);
	}

	public var inCutscene:Bool = false;

	public var defaultCamZoom:Float = 1.05;

	public var noteSkin:String = "Default";
	public var countdownSkin:String = "default";

	public var ratingSkin:String = "default";
	public var comboSkin:String = "default";

	public var countdownTextures:Map<String, FlxGraphic> = [];
	public var countdownSounds:Map<String, Sound> = [];

	public var countdownTimer:FlxTimer;

	public var ratingAntialiasing:Bool = true;
	public var comboAntialiasing:Bool = true;

	public var showRating:Bool = true;
	public var showCombo:Bool = true;

	public var ratingScale:Float = 0.7;
	public var comboScale:Float = 0.5;

	public var canSkipIntro:Bool = true;

	public var unsortedNotes:Array<Note> = [];

	public var global:Map<String, Dynamic> = [];
	public var luaVars:Map<String, Dynamic> = [];

	override function create() {
		super.create();
		current = this;

		enableTransitions();

		GameOverSubstate.reset();

		paused = false;
		allowSwitchingMods = false;

		Ranking.judgements = Ranking.defaultJudgements.copy();
		Ranking.ranks = Ranking.defaultRanks.copy();

		FlxG.sound.music.stop();

		#if discord_rpc
		DiscordRPC.changePresence(
			'Playing ${SONG.name}',
			'Starting song...'
		);
		#end

		// Setup song
		Conductor.bpm = SONG.bpm;
		Conductor.mapBPMChanges(SONG); // i deadass forgot to add this what 💀️

		Conductor.position = Conductor.crochet * -5;

		// Setup cameras
		camGame = FlxG.camera;
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor = 0x0;
		camOther.bgColor = 0x0;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		// Initialize and add UI
		UI = new UILayer();
		UI.cameras = [camHUD];
		add(UI);
		
		// Load the notes
		for(section in SONG.sections) {
			if(section != null) {
				for(note in section.notes) {
					var gottaHitNote:Bool = section.playerSection;
					if (note.direction > (SONG.keyAmount - 1)) gottaHitNote = !section.playerSection;

					if((prefs.get("Play As Opponent") && !PlayState.isStoryMode))
						gottaHitNote = !gottaHitNote;

					var parent:StrumLine = gottaHitNote ? UI.playerStrums : UI.opponentStrums;
					var fixedStrumTime:Float = note.strumTime + (prefs.get("Note Offset") * FlxG.sound.music.pitch);
		
					var dunceNote = new Note(fixedStrumTime, parent.keyAmount, note.direction % SONG.keyAmount, null, false, note.type);
					dunceNote.setPosition(-9999, -9999);
					dunceNote.mustPress = gottaHitNote;
					dunceNote.altAnim = note.altAnim;
					dunceNote.parent = parent;
					var event = dunceNote.script.event("onNoteCreation", new SimpleNoteEvent(dunceNote));
		
					var length:Int = Math.floor(note.sustainLength / Conductor.stepCrochet);
					if(length > 0) {
						for(sus in 0...length) {
							var susTime:Float = fixedStrumTime + (Conductor.stepCrochet * sus) + (Conductor.stepCrochet / Math.abs(parent.noteSpeed / Conductor.rate));
							var susNote = new Note(susTime, parent.keyAmount, note.direction % SONG.keyAmount, dunceNote, true, note.type);
							susNote.setPosition(-9999, -9999);
							susNote.mustPress = dunceNote.mustPress;
							susNote.altAnim = note.altAnim;
							susNote.parent = parent;
							susNote.stepCrochet = Conductor.stepCrochet;
							susNote.alpha = 0.6;
							if(sus >= length-1) {
								susNote.isSustainTail = true;
								susNote.playAnim("tail");
							}
							var susEvent = susNote.script.event("onNoteCreation", new SimpleNoteEvent(susNote));
							if(!susEvent.cancelled) {
								dunceNote.sustainPieces.push(susNote);
								parent.notes.add(susNote);
								parent.sustainGroup.add(susNote);
							} else {
								susNote.destroy();
								susNote = null;
								susEvent = null;
							}
						}
					}
		
					if(!event.cancelled) {
						unsortedNotes.push(dunceNote);
						parent.notes.add(dunceNote);
						parent.noteGroup.add(dunceNote);
					} else {
						dunceNote.destroy();
						dunceNote = null;
						event = null;
					}
				}
			}
		}
		for(line in [UI.opponentStrums, UI.playerStrums]) {
			line.notes.sortNotes();
			line.noteGroup.sortNotes();
			line.sustainGroup.sortNotes();
		}

		// Initialize and add stage
		stage = new Stage().load(SONG.stage);
		add(stage);
		FlxG.camera.zoom = defaultCamZoom;

		// Initialize and start song script
		script = Script.load(Paths.script('songs/${SONG.name.toLowerCase()}/script'));
		script.setParent(this);
		script.run();
		scripts.addScript(script);

		// Initialize and start global scripts
		for(item in CoolUtil.readDirectory('data/scripts/global')) {
            var script = Script.load(Paths.script("data/scripts/global/"+item.split("."+Path.extension(item))[0]));
            script.setParent(this);
            script.run();
            scripts.addScript(script);
        }

		// Start the countdown
		if(!inCutscene) startCountdown();
		
		// Initialize dad
		var point:FlxPoint = stage.characterPositions["dad"];
		dad = new Character(point.x, point.y).loadCharacter(SONG.dad);

		// Turns the dad character into the gf character if SONG.dad and SONG.gf are the same value.
        if(SONG.dad == SONG.gf) {
            var point:FlxPoint = stage.characterPositions["gf"];
            dad.setPosition(point.x, point.y);
            add(stage.gfLayer);
        } else {
            var point:FlxPoint = stage.characterPositions["gf"];
            gf = new Character(point.x, point.y).loadCharacter(SONG.gf);
            add(gf);
			add(stage.gfLayer);
        }

		// Add dad
		add(dad);
		add(stage.dadLayer);
		dads.push(dad);

		// Initialize and add bf
		var point:FlxPoint = stage.characterPositions["bf"];
		bf = new Character(point.x, point.y, true).loadCharacter(SONG.bf);
		add(bf);
		add(stage.bfLayer);
		bfs.push(bf);

		UI.initHealthBar();

		scripts.call("onCreateAfterChars");
		scripts.call("createAfterChars");

		// Make the camera follow the opponent or player
		camFollow = new FlxObject(0, 0, 1, 1);
		var posCamera:Bool = SONG.sections[0] != null ? SONG.sections[0].playerSection : false;
		moveCamera(!posCamera);
		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		moveCamera(posCamera);

		countdownTextures = FNFTools.getCountdownTextures(countdownSkin);
		countdownSounds = FNFTools.getCountdownSounds(countdownSkin);

		// Make the beatHit and stepHit actually work
		Conductor.onBeat.add(beatHit);
		Conductor.onStep.add(stepHit);

		// Call createPost on scripts
		scripts.createPostCall();
	}

	/**
	 * A function to pan the camera to the opponent or player.
	 * @param panToPlayer Whether or not to pan to the player. 
	 */
	public function moveCamera(panToPlayer:Bool = false) {
		if(panToPlayer) {
			if(bf == null) return;
			var pos = bf.getCameraPosition();
			camFollow.setPosition(pos.x, pos.y);
		} else {
			if(dad == null) return;
			var pos = dad.getCameraPosition();
			camFollow.setPosition(pos.x, pos.y);
		}
	}

	public function clearNotesBefore(time:Float) {
		var i:Int = UI.opponentStrums.notes.length - 1;
		while (i >= 0) {
			var daNote:Note = UI.opponentStrums.notes.members[i];
			if(daNote.strumTime - 350 < time) {
				daNote.active = false;
				daNote.visible = false;

				daNote.kill();
				UI.opponentStrums.notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}

		i = UI.playerStrums.notes.length - 1;
		while (i >= 0) {
			var daNote:Note = UI.playerStrums.notes.members[i];
			if(daNote.strumTime - 350 < time) {
				daNote.active = false;
				daNote.visible = false;

				daNote.kill();
				UI.playerStrums.notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	override function update(elapsed:Float) {
		scripts.updateCall(elapsed);

		super.update(elapsed);

		if(!startingSong) {
			var curSection:Int = Std.int(FlxMath.bound(Conductor.curStep / 16, 0, SONG.sections.length-1));
			moveCamera(SONG.sections[curSection] != null ? SONG.sections[curSection].playerSection : false);
		}

		if(health <= minHealth) {
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			FlxG.sound.music.stop();
			vocals.stop();

			openSubState(new GameOverSubstate(
				bf != null ? bf.getScreenPosition().x : 700, 
				bf != null ? bf.getScreenPosition().y : 360,
				bf != null ? bf.deathCharacter : "bf-dead"
			));
		}

		if(controls.getP("PAUSE")) {
			//stop all tweens and timers
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {
				if (!tmr.finished)
					tmr.active = false;
			});
			FlxTween.globalManager.forEach(function(twn:FlxTween) {
				if (!twn.finished)
					twn.active = false;
			});
			paused = true;
			persistentUpdate = false;
			persistentDraw = true;
			FlxG.sound.music.pause();
			vocals.pause();
			openSubState(new funkin.substates.PauseSubState());
		}

		if(FlxG.keys.justPressed.SEVEN) {
			endingSong = true;
			FlxG.sound.music.stop();
			vocals.stop();
			if(rpcTimer != null) rpcTimer.cancel();
			FlxG.switchState(new funkin.states.editors.charter.ChartingState());
		}

		if(!endingSong && !paused && !inCutscene) Conductor.position += (elapsed * 1000) * FlxG.sound.music.pitch;
		if(Conductor.position >= 0 && startingSong) startSong();
		var bruj = cachedSounds.exists("voices") ? Conductor.isAudioSynced(vocals) : Conductor.isAudioSynced(FlxG.sound.music);
		if(!paused && !bruj) 
			resyncSong();

		for (c in bfs) {
			if (c != null && c.animation.curAnim != null && c.holdTimer > Conductor.stepCrochet * c.singDuration * 0.0011
				&& !c.specialAnim && !UI.playerStrums.input.pressed.contains(true)) {
				if (c.animation.curAnim.name.startsWith('sing') && !c.animation.curAnim.name.endsWith('miss')) {
					c.holdTimer = 0;
					c.dance();
				}
			}
		}

		if(camZooming) {
			camGame.zoom = CoolUtil.fixedLerp(camGame.zoom, defaultCamZoom, 0.05);
			camHUD.zoom = CoolUtil.fixedLerp(camHUD.zoom, 1, 0.05);
		}

		if(controls.getP("BACK")) {
			persistentUpdate = false;
			persistentDraw = true;
			endingSong = true;
			vocals.stop();
			if(rpcTimer != null) rpcTimer.cancel();
			FlxG.sound.playMusic(cachedSounds["menuMusic"]);
			FlxG.switchState(new funkin.states.menus.FreeplayState());
		}

		scripts.updatePostCall(elapsed);
	}

	public function resyncSong() {
        if(paused || startingSong || endingSong) return;
		if(cachedSounds.exists("vocals") && SONG.needsVoices) {
            FlxG.sound.music.pause();
            vocals.pause();
            Conductor.position = FlxG.sound.music.time;
            vocals.time = FlxG.sound.music.time;
            if(vocals.time < vocals.length)
                vocals.play();
            FlxG.sound.music.play();
		} else Conductor.position = FlxG.sound.music.time;
	}

	public var countdownReady:FNFSprite = new FNFSprite();
	public var countdownSet:FNFSprite = new FNFSprite();
	public var countdownGo:FNFSprite = new FNFSprite();

	function startCountdown() {
		// Put the countdown sprites on the HUD
		for(sprite in [countdownReady, countdownSet, countdownGo]) sprite.cameras = [camHUD];
		var waitDelay:Float = (Conductor.crochet / 1000.0) / FlxG.sound.music.pitch;
		scripts.call("onCountdownStart");
		countdownTimer = new FlxTimer().start(waitDelay, function(tmr:FlxTimer) {
			scripts.call("onCountdownTick", [tmr.loopsLeft]);
			scripts.call("countdownTick", [tmr.loopsLeft]);
			characterBop(tmr.loopsLeft);
			switch(tmr.loopsLeft) {
				case 4:
					FlxG.sound.play(countdownSounds["3"]);
				case 3:
					FlxG.sound.play(countdownSounds["2"]);
					countdownReady.loadGraphic(countdownTextures["ready"]);
					countdownReady.screenCenter();
					FlxTween.tween(countdownReady, {alpha: 0}, waitDelay, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
						remove(countdownReady);
						countdownReady.kill();
						countdownReady.destroy();
					}});
					add(countdownReady);
				case 2:
					FlxG.sound.play(countdownSounds["1"]);
					countdownSet.loadGraphic(countdownTextures["set"]);
					countdownSet.screenCenter();
					FlxTween.tween(countdownSet, {alpha: 0}, waitDelay, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
						remove(countdownSet);
						countdownSet.kill();
						countdownSet.destroy();
					}});
					add(countdownSet);
				case 1:
					FlxG.sound.play(countdownSounds["go"]);
					countdownGo.loadGraphic(countdownTextures["go"]);
					countdownGo.screenCenter();
					FlxTween.tween(countdownGo, {alpha: 0}, waitDelay, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
						remove(countdownGo);
						countdownGo.kill();
						countdownGo.destroy();
					}});
					add(countdownGo);
			}
			scripts.call("onCountdownTickPost", [tmr.loopsLeft]);
			scripts.call("countdownTickPost", [tmr.loopsLeft]);
		}, 5);
		scripts.call("onCountdownStartPost");
	}
	
	public var rpcTimer:FlxTimer;

	public function startSong() {
		UI.onStartSong();
		scripts.call("onStartSong");
		
		startingSong = false;
		Conductor.position = 0;

        FlxG.sound.playMusic(cachedSounds["inst"], 1, false);
		if(cachedSounds.exists("voices")) {
			vocals.loadEmbedded(cachedSounds["voices"]);
        	vocals.play();
		}

        FlxG.sound.music.onComplete = finishSong.bind();
        FlxG.sound.music.pause();
        vocals.pause();
        FlxG.sound.music.time = 0;
        vocals.time = 0;
        FlxG.sound.music.pitch = Conductor.rate;
        vocals.pitch = Conductor.rate;
        FlxG.sound.music.play();
        vocals.play();

		FlxG.sound.list.add(vocals);

		#if discord_rpc
        DiscordRPC.changePresence(
            "Playing "+SONG.name,
            'Time remaining: ${FlxStringUtil.formatTime(FlxG.sound.music.length/1000.0)} / ${FlxStringUtil.formatTime(FlxG.sound.music.length/1000.0)}'
        );
        rpcTimer = new FlxTimer().start(1, function(tmr:FlxTimer) {
            if(!startingSong && !endingSong) {
                DiscordRPC.changePresence(
                    "Playing "+SONG.name,
                    'Time remaining: ${FlxStringUtil.formatTime((FlxG.sound.music.length-FlxG.sound.music.time)/1000.0)} / ${FlxStringUtil.formatTime(FlxG.sound.music.length/1000.0)}'
                );
            }
        }, 0);
		#end
		scripts.call("onStartSongPost");
	}

	public function finishSong(?ignoreNoteOffset:Bool = false) {
        persistentUpdate = false;
        persistentDraw = true;

		if((prefs.get("Note Offset") * FlxG.sound.music.pitch) <= 0 || ignoreNoteOffset) {
			endSong();
		} else {
			new FlxTimer().start((prefs.get("Note Offset") * FlxG.sound.music.pitch) / 1000, function(tmr:FlxTimer) {
				endSong();
			});
		}
	}

	public function endSong() {
		if(inCutscene) return;

		if(rpcTimer != null) rpcTimer.cancel();

        persistentUpdate = false;
        persistentDraw = true;
        
        endingSong = true;

		// lazy but probably works
		if(PlayerSettings.prefs.get("Botplay"))
			score = 0;
        
		var highscoreSong:String = SONG.name.toLowerCase();
		if(prefs.get("Play As Opponent") && !isStoryMode) highscoreSong += "-OPPONENT";
		highscoreSong += '-${Paths.currentMod}';
		
        if(score > Highscore.getScore(highscoreSong, curDifficulty))
            Highscore.saveScore(highscoreSong, score, curDifficulty);

		var ret:Dynamic = scripts.call("onEndSong", [SONG.name], true);
        if(ret != false) {
            if(vocals != null)
                vocals.stop();

            for(note in UI.opponentStrums.notes.members) {
				note.kill();
                UI.opponentStrums.notes.remove(note, true);
                note.destroy();
                note = null;
            }
            for(note in UI.playerStrums.notes.members) {
				note.kill();
                UI.playerStrums.notes.remove(note, true);
                note.destroy();
                note = null;
            }

            if(isStoryMode) {
                storyPlaylist.shift();
                storyScore += score;

                if(storyPlaylist.length > 0) {
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;
                    SONG = ChartParser.loadSong(storyPlaylist[0].chartType, storyPlaylist[0].name, curDifficulty);
                    FlxG.switchState(new PlayState());
                } else {
                    if(storyScore > Highscore.getScore(weekName, curDifficulty))
                        Highscore.saveScore(weekName, storyScore, curDifficulty);
                    
					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;
					FlxG.sound.playMusic(cachedSounds["menuMusic"]);
					FlxG.sound.music.time = 0;
                    FlxG.switchState(new funkin.states.menus.StoryMenuState());
                }
            } else {
				FlxG.sound.playMusic(cachedSounds["menuMusic"]);
				FlxG.sound.music.time = 0;
                FlxG.switchState(new funkin.states.menus.FreeplayState());
			}
        }

        scripts.call("onEndSongPost", [SONG.name]);
	}

	function beatHit(curBeat:Int) {
		if(endingSong || paused) return;

		scripts.call("onBeatHit", [curBeat]);
		scripts.call("beatHit", [curBeat]);

		var curSection:Int = Std.int(FlxMath.bound(Conductor.curStep / 16, 0, SONG.sections.length-1));
		if (SONG.sections[curSection] != null && SONG.sections[curSection].changeBPM)
			Conductor.bpm = SONG.sections[curSection].bpm;
		characterBop(curBeat);

		if(curBeat % 4 == 0 && camBumping) {
			camGame.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		UI.beatHit(curBeat);

		scripts.call("onBeatHitPost", [curBeat]);
        scripts.call("beatHitPost", [curBeat]);
	}

	function stepHit(curStep:Int) {
		if(endingSong || paused) return;
        scripts.call("onStepHit", [curStep]);
        scripts.call("stepHit", [curStep]);
        scripts.call("onStepHitPost", [curStep]);
        scripts.call("stepHitPost", [curStep]);
	}

	function characterBop(curBeat:Int) {
		for(c in dads) {
			if(c != null && c.animation.curAnim != null && !c.animation.curAnim.name.startsWith("sing") && !c.stunned)
				c.dance();
		}
		if(gf != null && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("hair") && curBeat % gfSpeed == 0 && !gf.stunned) gf.dance();
		for(c in bfs) {
			if(c != null && c.animation.curAnim != null && !c.animation.curAnim.name.startsWith("sing") && !c.stunned)
				c.dance();
		}
	}

	override function destroy() {
		current = null;
		super.destroy();
	}
}
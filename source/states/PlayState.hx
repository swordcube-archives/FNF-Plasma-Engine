package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import gameplay.Boyfriend;
import gameplay.Character;
import gameplay.GameplayUI;
import gameplay.Note;
import gameplay.Section;
import gameplay.Song;
import gameplay.Stage;
import gameplay.StrumLine;
import hscript.HScript;
import openfl.media.Sound;
import sys.FileSystem;
import systems.Conductor;
import systems.MusicBeat;
import systems.UIControls;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var logs:String = "";
	public static var current:PlayState;

	// Song
	public static var isStoryMode:Bool = false;
	public static var SONG:Song = SongLoader.getJSON("m.i.l.f", "hard");
	public static var currentDifficulty:String = "hard";

	public var notes:Array<Section> = SONG.notes.copy();

	// Characters
	public var dad:Character;
	public var gf:Character;
	public var bf:Boyfriend;

	// Camera
	public static var camZooming:Bool = true;
	public static var defaultCamZoom:Float = 1.0;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;

	public var cameraSpeed:Float = 1;

	// Music & Sounds
	public var freakyMenu:Sound = FNFAssets.returnAsset(SOUND, AssetPaths.music("freakyMenu"));
	public var loadedSong:Map<String, Sound> = [];
	public var vocals:FlxSound = new FlxSound();

	public var hasVocals:Bool = true;

	// Song Stats
	public var songScore:Int = 0;
	public var songMisses:Int = 0;

	public var songAccuracy:Float = 0;

	public var totalNotes:Int = 0;
	public var totalHit:Float = 0.0;

	public var combo:Int = 0;

	// Misc
	public var health:Float = 1.0;
	public var minHealth:Float = 0.0;
	public var maxHealth:Float = 2.0;

	public var healthGain:Float = 0.023;
	public var healthLoss:Float = 0.0475;

	public var stage:Stage;
	public var inCutscene:Bool = false;
	
	public var botPlay:Bool = Init.trueSettings.get("Botplay");

	public var script:HScript;
	public var scripts:Array<HScript> = [];

	public var UI:GameplayUI;

	public var startedSong:Bool = false;
	public var endingSong:Bool = false;

	public var scrollSpeed:Float = 1.0;

	public function calculateAccuracy()
	{
		if(totalNotes != 0 && totalHit != 0)
			songAccuracy = totalHit / totalNotes;
		else
			songAccuracy = 0;
	}

	public var currentSkin:String = "default";

	public var ratingAssetPath:String = "ratings/default";
	public var comboAssetPath:String = "combo/default";

	public var countdownImageLocation = "countdown";
	public var countdownSoundLocation = "countdown/default";

	public var countdownGraphics:Map<String, FlxGraphic> = [];
	public var countdownSounds:Map<String, Sound> = [];

	public var cachedRatings:Map<String, FlxGraphic> = [];

	public var cachedCombo:Map<String, Map<String, FlxGraphic>> = [];
	
	override function create()
	{
		current = this;
		super.create();

		persistentUpdate = true;
		persistentDraw = true;

		FlxG.sound.music.stop();
		FlxG.sound.list.add(vocals);

		if(SONG == null)
			SONG = SongLoader.getJSON("tutorial", "hard");

		if(SONG.keyCount == null)
			SONG.keyCount = 4;

		scrollSpeed = (Init.trueSettings.get("Scroll Speed") > 0) ? Init.trueSettings.get("Scroll Speed") : SONG.speed;

		loadedSong.set("inst", FNFAssets.returnAsset(SOUND, AssetPaths.songInst(SONG.song)));
		
		hasVocals = FileSystem.exists(AssetPaths.songVoices(SONG.song));
		if(hasVocals)
		{
			loadedSong.set("voices", FNFAssets.returnAsset(SOUND, AssetPaths.songVoices(SONG.song)));
			vocals.loadEmbedded(loadedSong.get("voices"), false);
		}

		setupCameras();

		callOnHScripts("create");

		stage = new Stage(SONG.stage != null ? SONG.stage : "stage");
		add(stage);

		var gfVersion:String = "gf";

		if(SONG.player3 != null)
			gfVersion = SONG.player3;

		if(SONG.gfVersion != null)
			gfVersion = SONG.gfVersion;

		if(SONG.gf != null)
			gfVersion = SONG.gf;

		gf = new Character(stage.gfPosition.x, stage.gfPosition.y, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		add(gf);
		add(stage.inFrontOfGFSprites);

		dad = new Character(stage.dadPosition.x, stage.dadPosition.y, SONG.player2);
		add(dad);

		bf = new Boyfriend(stage.bfPosition.x, stage.bfPosition.y, SONG.player1);
		bf.flipX = !bf.flipX;
		add(bf);
		add(stage.foregroundSprites);

		var path:String = 'songs/${SONG.song.toLowerCase()}/script';
		script = new HScript(path);
		script.setVariable("add", this.add);
		script.setVariable("remove", this.remove);
		scripts.push(script);
		script.start();

		Conductor.changeBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);

		Conductor.position = Conductor.crochet * -5.0;

		// precache the countdown bullshit
		countdownGraphics = [
			"preready"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(countdownImageLocation+"/"+"preready")),
			"ready"      => FNFAssets.returnAsset(IMAGE, AssetPaths.image(countdownImageLocation+"/"+"ready")),
			"set"        => FNFAssets.returnAsset(IMAGE, AssetPaths.image(countdownImageLocation+"/"+"set")),
			"go"         => FNFAssets.returnAsset(IMAGE, AssetPaths.image(countdownImageLocation+"/"+"go")),
		];

		countdownSounds = [
			"preready"   => FNFAssets.returnAsset(SOUND, AssetPaths.sound(countdownSoundLocation+"/"+"intro3")),
			"ready"      => FNFAssets.returnAsset(SOUND, AssetPaths.sound(countdownSoundLocation+"/"+"intro2")),
			"set"        => FNFAssets.returnAsset(SOUND, AssetPaths.sound(countdownSoundLocation+"/"+"intro1")),
			"go"         => FNFAssets.returnAsset(SOUND, AssetPaths.sound(countdownSoundLocation+"/"+"introGo")),
		];

		countdownPreReady.cameras = [camHUD];
		countdownPreReady.alpha = 0;
		add(countdownPreReady);

		countdownReady.cameras = [camHUD];
		countdownReady.alpha = 0;
		add(countdownReady);

		countdownSet.cameras = [camHUD];
		countdownSet.alpha = 0;
		add(countdownSet);

		countdownGo.cameras = [camHUD];
		countdownGo.alpha = 0;
		add(countdownGo);

		if(!inCutscene)
			startCountdown();

		FlxG.camera.zoom = defaultCamZoom;

		UI = new GameplayUI();
		UI.cameras = [camHUD];
		add(UI);

		cachedRatings = getRatingCache(ratingAssetPath);
		cachedCombo = getComboCache(comboAssetPath);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollowPos);
		
		FlxG.camera.follow(camFollowPos, LOCKON, 1);

		if(gf != null)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollowPos.setPosition(camFollow.x, camFollow.y);
		}

		focusCamera(SONG.notes[0].mustHitSection ? "bf" : "dad");

		callOnHScripts("createPost");
	}

	function getRatingCache(ratingPath:String = "ratings/default")
	{
		return [
			"marvelous"  => FNFAssets.returnAsset(IMAGE, AssetPaths.image(ratingPath+"/"+"marvelous")),
			"sick"       => FNFAssets.returnAsset(IMAGE, AssetPaths.image(ratingPath+"/"+"sick")),
			"good"       => FNFAssets.returnAsset(IMAGE, AssetPaths.image(ratingPath+"/"+"good")),
			"bad"        => FNFAssets.returnAsset(IMAGE, AssetPaths.image(ratingPath+"/"+"bad")),
			"shit"       => FNFAssets.returnAsset(IMAGE, AssetPaths.image(ratingPath+"/"+"shit")),
		];
	}

	function getComboCache(comboPath:String = "combo/default")
	{
		return [
			"marvelous"  => [
				"combo"  => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"combo")),
				"num0"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"num0")),
				"num1"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"num1")),
				"num2"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"num2")),
				"num3"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"num3")),
				"num4"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"num4")),
				"num5"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"num5")),
				"num6"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"num6")),
				"num7"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"num7")),
				"num8"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"num8")),
				"num9"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/marvelous/"+"num9")),
			],
			"default"    => [
				"combo"  => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"combo")),
				"num0"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"num0")),
				"num1"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"num1")),
				"num2"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"num2")),
				"num3"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"num3")),
				"num4"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"num4")),
				"num5"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"num5")),
				"num6"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"num6")),
				"num7"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"num7")),
				"num8"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"num8")),
				"num9"   => FNFAssets.returnAsset(IMAGE, AssetPaths.image(comboPath+"/"+"num9")),
			],
		];
	}

	function getMenuToSwitchTo()
	{
		if(isStoryMode)
			return new FreeplayMenu(); // will be changed soon
		else
			return new FreeplayMenu();
	}

	public var countdownPreReady:FlxSprite = new FlxSprite();
	public var countdownReady:FlxSprite = new FlxSprite();
	public var countdownSet:FlxSprite = new FlxSprite();
	public var countdownGo:FlxSprite = new FlxSprite();

	var countdownTimer:Int = 0;
	function startCountdown()
	{		
		new FlxTimer().start(Conductor.crochet / 1000.0, function(tmr:FlxTimer) {
			if(dad != null)
				dad.dance();

			if(gf != null)
				gf.dance();

			if(bf != null)
				bf.dance();

			switch(countdownTimer)
			{
				case 0:
					callOnHScripts("countdownTick", [countdownTimer]);
					FlxG.sound.play(countdownSounds["preready"]);
					countdownPreReady.loadGraphic(countdownGraphics["preready"]);
					countdownPreReady.screenCenter();
					countdownPreReady.alpha = 1;
					FlxTween.tween(countdownPreReady, { alpha: 0 }, Conductor.crochet / 1000.0, { ease: FlxEase.cubeInOut });
				case 1:
					callOnHScripts("countdownTick", [countdownTimer]);
					FlxG.sound.play(countdownSounds["ready"]);
					countdownReady.loadGraphic(countdownGraphics["ready"]);
					countdownReady.screenCenter();
					countdownReady.alpha = 1;
					FlxTween.tween(countdownReady, { alpha: 0 }, Conductor.crochet / 1000.0, { ease: FlxEase.cubeInOut });
				case 2:
					callOnHScripts("countdownTick", [countdownTimer]);
					FlxG.sound.play(countdownSounds["set"]);
					countdownSet.loadGraphic(countdownGraphics["set"]);
					countdownSet.screenCenter();
					countdownSet.alpha = 1;
					FlxTween.tween(countdownSet, { alpha: 0 }, Conductor.crochet / 1000.0, { ease: FlxEase.cubeInOut });
				case 3:
					callOnHScripts("countdownTick", [countdownTimer]);
					FlxG.sound.play(countdownSounds["go"]);
					countdownGo.loadGraphic(countdownGraphics["go"]);
					countdownGo.screenCenter();
					countdownGo.alpha = 1;
					FlxTween.tween(countdownGo, { alpha: 0 }, Conductor.crochet / 1000.0, { ease: FlxEase.cubeInOut });
				case 4:
					callOnHScripts("countdownTick", [countdownTimer]);
			}

			countdownTimer++;
		}, 5);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(!inCutscene)
		{
			var lerpVal:Float = FlxMath.bound(Main.deltaTime * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		callOnHScripts("update", [elapsed]);

		if(UIControls.justPressed("BACK") || (Conductor.position >= FlxG.sound.music.length))
		{
			endingSong = true;

			FlxG.sound.music.stop();
			vocals.stop();
			FlxG.sound.playMusic(freakyMenu);
			Main.switchState(getMenuToSwitchTo());
		}

		Conductor.position += elapsed * 1000.0;
		if(Conductor.position >= 0.0 && !startedSong)
			startSong();

		spawnNotes();

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, Main.deltaTime * 9);
		camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, Main.deltaTime * 9);

		callOnHScripts("updatePost", [elapsed]);
	}

	override function resetState()
	{
		SONG = SongLoader.getJSON(SONG.song, currentDifficulty);
		Main.resetState();
	}

	function spawnNotes()
	{
		for(section in notes)
		{
			if(section.sectionNotes.length > 0)
			{
				for(note in section.sectionNotes)
				{
					var strumTime:Float = note[0] + Init.trueSettings.get("Note Offset");
					if((strumTime - Conductor.position) < 2500)
					{
						var gottaHitNote:Bool = section.mustHitSection;
						if (note[1] > (SONG.keyCount - 1))
							gottaHitNote = !section.mustHitSection;

						var arrowSkin:String = currentSkin != "default" ? currentSkin : Init.trueSettings.get("Arrow Skin").toLowerCase();

						var newNote:Note = new Note(-9999, -9999, Std.int(note[1]) % SONG.keyCount);

						// sustain
						var susLength:Float = note[2] / Conductor.stepCrochet;

						if(susLength > 0)
						{
							var susNote:Int = 0;
							for(i in 0...Math.floor(susLength))
							{
								var newSusNote:Note = new Note(-9999, -9999, Std.int(note[1]) % SONG.keyCount, true);
								newSusNote.strumTime = strumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet;
								newSusNote.mustPress = gottaHitNote;

								var strumLine:StrumLine = gottaHitNote ? UI.playerStrums : UI.opponentStrums;
								strumLine.notes.add(newSusNote);
		
								newSusNote.parent = strumLine;
								newSusNote.sustainParent = newNote;
								newSusNote.loadSkin(arrowSkin);
								susNote++;
							}

							// end piece
							var newSusNote:Note = new Note(-9999, -9999, Std.int(note[1]) % SONG.keyCount, true);
							newSusNote.strumTime = strumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet;
							newSusNote.mustPress = gottaHitNote;

							var strumLine:StrumLine = gottaHitNote ? UI.playerStrums : UI.opponentStrums;
							strumLine.notes.add(newSusNote);

							newSusNote.parent = strumLine;
							newSusNote.sustainParent = newNote;
							newSusNote.loadSkin(arrowSkin);

							newSusNote.playAnim("tail");
						}

						newNote.strumTime = strumTime;
						newNote.mustPress = gottaHitNote;
						
						var strumLine:StrumLine = gottaHitNote ? UI.playerStrums : UI.opponentStrums;
						strumLine.notes.add(newNote);

						newNote.parent = strumLine;
						newNote.loadSkin(arrowSkin);

						section.sectionNotes.remove(note);
					}
				}
			}
		}
	}

	function startSong()
	{
		startedSong = true;

		FlxG.sound.playMusic(loadedSong.get("inst"), 1, false);
		if(hasVocals)
			vocals.play();

		Conductor.position = 0.0;
		callOnHScripts("startSong");
	}

	function focusCamera(onWho:String = "dad")
	{
		switch(onWho.toLowerCase())
		{
			case "dad":
				if(dad == null) return trace("dad is null!!");
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition.x;
				camFollow.y += dad.cameraPosition.y;
			case "bf":
				if(bf == null) return trace("bf is null!!");
				camFollow.set(bf.getMidpoint().x - 100, bf.getMidpoint().y - 100);
				camFollow.x -= bf.cameraPosition.x;
				camFollow.y += bf.cameraPosition.y;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		// Stop the function from running if the song is ending
		if(endingSong) return;

		var curSection:Int = Std.int(FlxMath.bound(Conductor.currentStep / 16, 0, SONG.notes.length-1));
		focusCamera(SONG.notes[curSection].mustHitSection ? "bf" : "dad");

		if(!dad.animation.curAnim.name.startsWith("sing"))
			dad.dance();

		if(!gf.animation.curAnim.name.startsWith("sing"))
			gf.dance();

		if(!bf.animation.curAnim.name.startsWith("sing"))
			bf.dance();

		callOnHScripts("beatHit", [Conductor.currentBeat]);

		if(Conductor.currentBeat % 4 == 0)
		{
			FlxG.camera.zoom = defaultCamZoom + 0.015;
			camHUD.zoom = 1.05;
		}

		callOnHScripts("beatHitPost", [Conductor.currentBeat]);
	}

	override function stepHit()
	{
		super.stepHit();

		callOnHScripts("stepHit", [Conductor.currentStep]);

		// Resync song if it gets out of sync with song position
		if(hasVocals)
		{
			if(!(Conductor.isAudioSynced(FlxG.sound.music) && Conductor.isAudioSynced(vocals)))
			{
				FlxG.sound.music.pause();
				if(vocals.time < vocals.length)
					vocals.pause();

				FlxG.sound.music.time = Conductor.position;
				if(vocals.time < vocals.length)
					vocals.time = Conductor.position;

				FlxG.sound.music.play();
				if(vocals.time < vocals.length)
					vocals.play();
			}
		}
		else
		{
			if(!Conductor.isAudioSynced(FlxG.sound.music))
			{
				FlxG.sound.music.pause();
				FlxG.sound.music.time = Conductor.position;
				FlxG.sound.music.play();
			}
		}

		callOnHScripts("stepHitPost", [Conductor.currentStep]);
	}

	function setupCameras()
	{
		FlxG.cameras.reset();
		camGame = FlxG.camera;
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor = 0x0;
		camOther.bgColor = 0x0;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
	}

	public function callOnHScripts(func:String, ?args:Null<Array<Dynamic>>)
	{
		for(script in scripts)
			script.callFunction(func, args);
	}
}

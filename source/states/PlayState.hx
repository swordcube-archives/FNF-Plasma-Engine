package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
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

class PlayState extends MusicBeatState
{
	public static var logs:String = "";
	public static var current:PlayState;

	// Song
	public static var isStoryMode:Bool = false;
	public static var SONG:Song = SongLoader.getJSON("m.i.l.f", "hard");
	public static var currentDifficulty:String = "hard";

	// Characters
	public var dad:Character;
	public var gf:Character;
	public var bf:Character;

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

	// Misc
	public var inCutscene:Bool = false;
	
	public var botPlay:Bool = Init.trueSettings.get("Botplay");

	public var script:HScript;
	public var scripts:Array<HScript> = [];

	public var UI:GameplayUI;

	public var startedSong:Bool = false;
	public var endingSong:Bool = false;

	public var scrollSpeed:Float = 1.0;
	
	override function create()
	{
		current = this;
		super.create();

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

		callOnHScripts("create");

		var path:String = 'songs/${SONG.song.toLowerCase()}/script';
		script = new HScript(path);
		script.setVariable("add", this.add);
		script.setVariable("remove", this.remove);
		scripts.push(script);
		script.start();

		Conductor.changeBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);

		Conductor.position = Conductor.crochet * -5.0;

		setupCameras();
		FlxG.camera.zoom = defaultCamZoom;

		UI = new GameplayUI();
		UI.cameras = [camHUD];
		add(UI);

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

	function getMenuToSwitchTo()
	{
		if(isStoryMode)
			return new FreeplayMenu(); // will be changed soon
		else
			return new FreeplayMenu();
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

		if(UIControls.justPressed("BACK"))
		{
			endingSong = true;

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

	function spawnNotes()
	{
		for(section in SONG.notes)
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

						var arrowSkin:String = "arrows";

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
				if(dad == null) return;
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition.x;
				camFollow.y += dad.cameraPosition.y;
			case "bf":
				if(bf == null) return;
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

		var curSection:Int = Math.round(FlxMath.bound(Conductor.currentStep / 16, 0, SONG.notes.length));
		focusCamera(SONG.notes[curSection].mustHitSection ? "bf" : "dad");

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
				vocals.pause();

				FlxG.sound.music.time = Conductor.position;
				vocals.time = Conductor.position;

				FlxG.sound.music.play();
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

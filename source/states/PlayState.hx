package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import gameplay.GameplayUI;
import gameplay.Note;
import gameplay.Section;
import gameplay.Song;
import gameplay.StrumLine;
import hscript.HScript;
import openfl.media.Sound;
import sys.FileSystem;
import systems.Conductor;
import systems.MusicBeat;

class PlayState extends MusicBeatState
{
	public static var logs:String = "";
	public static var current:PlayState;

	// Song
	public static var SONG:Song = SongLoader.getJSON("m.i.l.f", "hard");
	public static var currentDifficulty:String = "hard";

	// Camera
	public static var camZooming:Bool = true;
	public static var defaultCamZoom:Float = 1.0;

	// Camera
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	public var curSection:Int = 0;
	public var camFollow:FlxObject;
	public var camFollowPos:FlxObject;

	public var followLerp:Float = 0.45;

	// Misc
	public var scripts:Array<HScript> = [];
	public var UI:GameplayUI;

	public var startedSong:Bool = false;

	public var loadedSong:Map<String, Sound> = [];
	public var vocals:FlxSound = new FlxSound();

	public var hasVocals:Bool = true;

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

		Conductor.changeBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);

		Conductor.position = Conductor.crochet * -5.0;

		setupCameras();
		FlxG.camera.zoom = defaultCamZoom;

		UI = new GameplayUI();
		UI.cameras = [camHUD];
		add(UI);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		Conductor.position += elapsed * 1000.0;
		if(Conductor.position >= 0.0 && !startedSong)
			startSong();

		spawnNotes();

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, Main.deltaTime * 9);
		camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, Main.deltaTime * 9); 
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
					if((strumTime - Conductor.position) < 1000)
					{
						var gottaHitNote:Bool = section.mustHitSection;
						if (note[1] > (SONG.keyCount - 1))
							gottaHitNote = !section.mustHitSection;

						var newNote:Note = new Note(-9999, -9999, Std.int(note[1]) % SONG.keyCount);
						newNote.strumTime = strumTime;
						newNote.mustPress = gottaHitNote;
						
						var strumLine:StrumLine = gottaHitNote ? UI.playerStrums : UI.opponentStrums;
						strumLine.notes.add(newNote);

						newNote.parent = strumLine;
						newNote.loadSkin("arrows");

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
	}

	override function beatHit()
	{
		super.beatHit();

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

		if(Conductor.currentBeat % 4 == 0)
		{
			FlxG.camera.zoom = defaultCamZoom + 0.015;
			camHUD.zoom = 1.05;
		}
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
}

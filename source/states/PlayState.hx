package states;

import base.Conductor;
import base.Controls;
import base.Highscore;
import base.MusicBeat.MusicBeatState;
import base.Song;
import base.SongLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.Boyfriend;
import funkin.Character;
import funkin.playState.Stage;
import haxe.Json;
import hscript.HScript;
import ui.playState.Note;
import ui.playState.StrumNote;
import ui.playState.UI;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class PlayState extends MusicBeatState
{
	// Instance
	public static var instance:PlayState;

	// Song Shit
	public static var isStoryMode:Bool = false;

	public static var SONG:Dynamic;
	public static var songData:Song;

	public static var storyWeek:String = "tutorial";
	public static var curDifficulty:String = "normal";

	// Camera Shit
	public var camZooming:Bool = true;
	public var defaultCamZoom:Float = 1.0;
	
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	public var curSection:Int = 0;
	public var camFollow:FlxObject;
	public var camFollowPos:FlxObject;

	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0;
	public static var cameraSpeed:Float = 1;

	// Stage
	public var stage:Stage;

	// Characters
	public var dad:Character;
	public var gf:Character;
	public var bf:Boyfriend;

	// Scripts
	public var script:HScript;
	
	public var scripts:Array<HScript> = [];

	// UI
	public var UI:UI;
	public var scrollSpeed:Float = 1;

	public var uiSkin:String = 'arrows';

	public static var daPixelZoom:Float = 6;

	// Health
	public var health:Float = 1;
	public var minHealth:Float = 0;
	public var maxHealth:Float = 2;

	// Music
	public var freakyMenu:Dynamic;

	// Song
	public var cachedSong:Map<String, Dynamic> = [];
	public var voices:FlxSound = new FlxSound();

	// Stats
	public var songScore:Int = 0;
	public var songMisses:Int = 0;
	public var songAccuracy:Float = 0;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;

	public static var storyPlaylist:Array<String> = [];

	public var marvelous:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	public var combo:Int = 0;

	public var totalNotes:Int = 0;
	public var totalHit:Float = 0.0;

	// Extra Variables
	public var endingSong:Bool = false;
	public var inCutscene:Bool = false;

	// Logs
	public static var logs:Array<String> = [];

	public function new()
	{
		super();
		instance = this;
	}

	function getVocals():Dynamic
	{
		if(songData.needsVoices)
			return GenesisAssets.getAsset('${songData.song.toLowerCase()}/Voices', GenesisAssets.AssetType.SONG);

		return null;
	}

	override public function create()
	{
		super.create();

		logs = [];

		freakyMenu = GenesisAssets.getAsset('freakyMenu', MUSIC);

		persistentUpdate = true;
		persistentDraw = true;

		if(SONG == null)
			SONG = SongLoader.loadJSON("test", "normal");

		songData = SONG.song;
		
		if(songData.uiSkin != null)
			uiSkin = songData.uiSkin;

		scrollSpeed = songData.speed;

		cachedSong = [
			"inst" => GenesisAssets.getAsset('${songData.song.toLowerCase()}/Inst', GenesisAssets.AssetType.SONG),
			"voices" => getVocals(),
		];

		FlxG.sound.music.stop();

		if(GenesisAssets.exists('songs/${songData.song.toLowerCase()}/script.hx', HSCRIPT))
		{
			trace("TRYING TO RUN SCRIPT! " + 'songs/${songData.song.toLowerCase()}/script.hx');
			script = new HScript('songs/${songData.song.toLowerCase()}/script.hx');
			script.start();

			scripts.push(script);
		}
		else
			trace("SCRIPT DON'T EXIST IN SONG DIRECTORY!");

		#if sys
		if(FileSystem.exists('${GenesisAssets.cwd}assets/scripts'))
		{
			var pissAss:Array<String> = FileSystem.readDirectory('${GenesisAssets.cwd}assets/scripts');
			for(file in pissAss)
			{
				if(file.endsWith(".hx"))
				{
					var swagScript:HScript = new HScript(File.getContent('${GenesisAssets.cwd}assets/scripts/$file'));
					swagScript.start();

					scripts.push(swagScript);
				}
			}
		}
		#end

		#if MODS_ALLOWED
		for(mod in GenesisAssets.mods)
		{
			if(GenesisAssets.activeMods.get(mod) == true)
			{
				if(FileSystem.exists('${GenesisAssets.cwd}mods/$mod/scripts'))
				{
					var pissAss:Array<String> = FileSystem.readDirectory('${GenesisAssets.cwd}mods/$mod/scripts');
					for(file in pissAss)
					{
						if(file.endsWith(".hx"))
						{
							var swagScript:HScript = new HScript(GenesisAssets.getAsset('scripts/$file', HSCRIPT, mod));
							swagScript.start();
			
							scripts.push(swagScript);
						}
					}
				}
			}
		}
		#end

		setupCameras();

		// Add back layer of stage
		stage = new Stage('stage');
		add(stage);

		// Make Dad and GF real
		dad = new Character(100, 100, songData.player2);

		var gfVersion:String = "gf";

		if(songData.player3 != null)
			gfVersion = songData.player3;

		if(songData.gfVersion != null)
			gfVersion = songData.gfVersion;

		if(songData.gf != null)
			gfVersion = songData.gf;

		gf = new Character(400, 130, gfVersion);

		// Add GF and the objects in the stage that go in front of GF
		add(gf);
		add(stage.inFrontOfGFSprites);

		// Make BF real
		bf = new Boyfriend(770, 450, songData.player1);
		bf.flipX = !bf.flipX;

		// Actually add the guys
		add(dad);
		add(bf);

		// Make tutorial work correctly and not show 2 gfs
		if(dad.curCharacter == gf.curCharacter)
		{
			dad.setPosition(gf.x, gf.y);
			
			remove(gf);
			gf.kill();
			gf.destroy();
			
			gf = null;
		}

		// Add front layer of stage
		add(stage.foregroundSprites);

		// set the camera position to the center of the stage
		var camPos:FlxPoint = new FlxPoint(0, 0);
		if(gf != null)
			camPos.set(gf.x + (gf.frameWidth / 2), gf.y + (gf.frameHeight / 2));
		else
			camPos.set(dad.x + (dad.frameWidth / 2), dad.y + (dad.frameHeight / 2));

		// create the shit that makes the camera work
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(camPos.x, camPos.y);
		
		add(camFollow);
		add(camFollowPos);

		// actually set the camera up
		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		// add the UI
		UI = new UI();
		UI.cameras = [camHUD];
		add(UI);

		// start the song
		Conductor.changeBPM(songData.bpm);
		Conductor.mapBPMChanges(songData);
		Conductor.songPosition = Conductor.crochet * -5;

		if(!inCutscene)
			startCountdown();

		// do createPost function for any running scripts
		callOnHScripts("createPost");
	}

	var physicsUpdateTimer:Float = 0;

	override public function update(elapsed:Float)
	{
		if(health < minHealth)
			health = minHealth;

		if(health > maxHealth)
			health = maxHealth;
		
		super.update(elapsed);

		callOnHScripts("update", [elapsed]);

		physicsUpdateTimer += elapsed;
		if(physicsUpdateTimer > 1 / 60)
		{
			physicsUpdate();
			callOnHScripts("physicsUpdate");
			physicsUpdateTimer = 0;
		}

		Conductor.songPosition += FlxG.elapsed * 1000;

		if(Controls.isPressed("BACK", JUST_PRESSED))
		{			
			goBackToMenu();
		}

		callOnHScripts("updatePost", [elapsed]);
	}

	var lastSection:Int = 0;

	public function physicsUpdate()
	{
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

		if(!endingSong)
		{
			for(section in songData.notes)
			{
				for(songNotes in section.sectionNotes)
				{
					var daStrumTime:Float = songNotes[0] + Init.getOption('note-offset');
					
					// Spawn the notes as the song goes on
					if((daStrumTime - Conductor.songPosition) < 2500)
					{
						var daNoteData:Int = Std.int(songNotes[1] % songData.keyCount);

						var gottaHitNote:Bool = section.mustHitSection;

						if (songNotes[1] > (songData.keyCount - 1))
							gottaHitNote = !section.mustHitSection;

						var oldNote:Note;
						if (UI.notes.length > 0)
							oldNote = UI.notes.members[Std.int(UI.notes.length - 1)];
						else
							oldNote = null;

						var swagNote:Note = new Note(daStrumTime, daNoteData, uiSkin, false);
						swagNote.prevNote = oldNote;
						swagNote.mustPress = gottaHitNote;
						swagNote.sustainLength = songNotes[2];
						swagNote.downscrollNote = Init.getOption("downscroll");
						
						swagNote.x = -1000;
						swagNote.y = -1000;

						var susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;
						var floorSus:Int = Math.floor(susLength);
						
						if(floorSus > 0)
						{
							for (susNote in 0...floorSus)
							{
								var isEnd:Bool = false;
								
								if(susNote == floorSus - 1)
									isEnd = true;

								oldNote = UI.notes.members[Std.int(UI.notes.length - 1)];

								var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(scrollSpeed, 2)), daNoteData, uiSkin, true, isEnd);
								sustainNote.prevNote = oldNote;
								sustainNote.mustPress = gottaHitNote;
								sustainNote.downscrollNote = Init.getOption("downscroll");

								sustainNote.x = -1000;
								sustainNote.y = -1000;

								UI.notes.add(sustainNote);
							}
						}

						UI.notes.add(swagNote);

						section.sectionNotes.remove(songNotes);
					}
					else
						break; // Performance is always nice isn't it?
				}
			}
		}

		var bruj:Int = Std.int(curStep / 16);
		if(bruj < 0)
			bruj = 0;
		if(bruj > songData.notes.length - 1)
			bruj = songData.notes.length - 1;

		if(songData.notes[bruj] != null)
		{
			var curSection = bruj;
			if (curSection != lastSection) {
				// section reset stuff
				var lastMustHit:Bool = songData.notes[lastSection].mustHitSection;
				if (songData.notes[curSection].mustHitSection != lastMustHit) {
					camDisplaceX = 0;
					camDisplaceY = 0;
				}
				lastSection = bruj;
			}

			if (!songData.notes[bruj].mustHitSection)
			{
				var char = dad;

				var getCenterX = char.getMidpoint().x + 100;
				var getCenterY = char.getMidpoint().y - 100;

				camFollow.setPosition(getCenterX + camDisplaceX + char.cameraPosition[0],
					getCenterY + camDisplaceY + char.cameraPosition[1]);
			}
			else
			{
				var char = bf;

				var getCenterX = char.getMidpoint().x - 100;
				var getCenterY = char.getMidpoint().y - 100;

				camFollow.setPosition(getCenterX + camDisplaceX - char.cameraPosition[0],
					getCenterY + camDisplaceY + char.cameraPosition[1]);
			}
		}

		var lerpVal = cameraSpeed * 0.1;
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
	}

	public var countdownActive:Bool = false;

	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;

	public function startCountdown()
	{
		countdownActive = true;
		
		var countdownGraphics:Map<String, Dynamic> = [
			"ready" => GenesisAssets.getAsset('ui/skins/${UI.opponentStrums.skin}/countdown/ready', IMAGE),
			"set" => GenesisAssets.getAsset('ui/skins/${UI.opponentStrums.skin}/countdown/set', IMAGE),
			"go" => GenesisAssets.getAsset('ui/skins/${UI.opponentStrums.skin}/countdown/go', IMAGE),
		];

		var countdownSounds:Map<String, Dynamic> = [
			"3" => GenesisAssets.getAsset('ui/skins/countdown/${UI.opponentStrums.skin}/intro3', SOUND),
			"2" => GenesisAssets.getAsset('ui/skins/countdown/${UI.opponentStrums.skin}/intro2', SOUND),
			"1" => GenesisAssets.getAsset('ui/skins/countdown/${UI.opponentStrums.skin}/intro1', SOUND),
			"go" => GenesisAssets.getAsset('ui/skins/countdown/${UI.opponentStrums.skin}/introGo', SOUND),
		];

		var swagCounter:Int = 0;

		var json:ArrowSkin = Json.parse(GenesisAssets.getAsset('images/ui/skins/$uiSkin/config.json', TEXT));

		var textureAntiAliasing:Bool = json.skinType != "pixel";

		callOnHScripts("onStartCountdown");

		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (gf != null && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing"))
				gf.dance();
			
			if (bf.animation.curAnim != null && !bf.animation.curAnim.name.startsWith('sing'))
				bf.dance();
			
			if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing'))
				dad.dance();

			switch(swagCounter)
			{
				case 0:
					Conductor.songPosition = Conductor.crochet * -4;
					FlxG.sound.play(countdownSounds["3"]);
				case 1:
					Conductor.songPosition = Conductor.crochet * -3;
					FlxG.sound.play(countdownSounds["2"]);

					countdownReady = new FlxSprite().loadGraphic(countdownGraphics["ready"]);

					var sprite:FlxSprite = countdownReady;
					sprite.screenCenter();
					sprite.antialiasing = textureAntiAliasing;
					sprite.scrollFactor.set();
					sprite.cameras = [camHUD];
					add(sprite);

					FlxTween.tween(sprite, {alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(sprite);
							sprite.kill();
							sprite.destroy();
						}
					});
				case 2:
					Conductor.songPosition = Conductor.crochet * -2;
					FlxG.sound.play(countdownSounds["1"]);

					countdownSet = new FlxSprite().loadGraphic(countdownGraphics["set"]);

					var sprite:FlxSprite = countdownSet;
					sprite.screenCenter();
					sprite.antialiasing = textureAntiAliasing;
					sprite.scrollFactor.set();
					sprite.cameras = [camHUD];
					add(sprite);

					FlxTween.tween(sprite, {alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(sprite);
							sprite.kill();
							sprite.destroy();
						}
					});
				case 3:
					Conductor.songPosition = Conductor.crochet * -1;
					FlxG.sound.play(countdownSounds["go"]);

					countdownGo = new FlxSprite().loadGraphic(countdownGraphics["go"]);

					var sprite:FlxSprite = countdownGo;
					sprite.screenCenter();
					sprite.antialiasing = textureAntiAliasing;
					sprite.scrollFactor.set();
					sprite.cameras = [camHUD];
					add(sprite);

					FlxTween.tween(sprite, {alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(sprite);
							sprite.kill();
							sprite.destroy();
						}
					});
				case 4:
					Conductor.songPosition = 0;
					
					FlxG.sound.playMusic(cachedSong["inst"], 1, false);
					FlxG.sound.music.onComplete = endSong;

					if(cachedSong["voices"] != null)
						voices = new FlxSound().loadEmbedded(cachedSong["voices"]);

					if(cachedSong["voices"] != null)
					{
						voices.play();
						FlxG.sound.list.add(voices);
					}

					FlxG.sound.music.pause();
					voices.pause();

					FlxG.sound.music.time = 0;
					voices.time = 0;

					FlxG.sound.music.play();
					voices.play();

					countdownActive = false;
			}

			callOnHScripts("countdownTick", [swagCounter]);
			swagCounter++;
		}, 5);
	}

	function endSong()
	{
		endingSong = true;

		Highscore.saveScore(songData.song.toLowerCase(), songScore, curDifficulty);
		
		if(isStoryMode)
		{
			campaignScore += songScore;
			campaignMisses += songMisses;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				Highscore.saveWeekScore(storyWeek, campaignScore, curDifficulty);
				goBackToMenu();
			}
			else
			{
				PlayState.SONG = SongLoader.loadJSON(storyPlaylist[0].toLowerCase(), curDifficulty);
				States.switchState(this, new PlayState(), true);
			}
		}
		else
		{
			goBackToMenu();
		}
	}

	function goBackToMenu()
	{
		endingSong = true;
		
		voices.stop();
		voices.kill();
		voices.destroy();
		
		FlxG.sound.playMusic(freakyMenu);

		persistentUpdate = false;
		persistentDraw = true;

		// Story Mode doesn't exist yet so it just takes you to Freeplay instead
		/*if(isStoryMode)
			States.switchState(this, new StoryMenu());
		else*/
			States.switchState(this, new FreeplayMenu());
	}

	override public function beatHit()
	{
		super.beatHit();
		UI.beatHit();

		if (gf != null && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing"))
			gf.dance();
		
		if (bf.animation.curAnim != null && !bf.animation.curAnim.name.startsWith('sing'))
			bf.dance();
		
		if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing'))
			dad.dance();

		if(camZooming && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.05;
		}

		callOnHScripts("beatHit", [curBeat]);
	}

	override public function stepHit()
	{
		super.stepHit();
		UI.stepHit();

		callOnHScripts("stepHit", [curStep]);

		if (FlxG.sound.music.time >= Conductor.songPosition + 20 || FlxG.sound.music.time <= Conductor.songPosition - 20)
			resyncVocals();
	}

	public function resyncVocals():Void
	{
		trace('resyncing vocal time ${voices.time}');
		FlxG.sound.music.pause();
		voices.pause();
		Conductor.songPosition = FlxG.sound.music.time;
		voices.time = Conductor.songPosition;
		FlxG.sound.music.play();
		voices.play();
		trace('new vocal time ${Conductor.songPosition}');
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

	public function callOnHScripts(func:String, ?args:Array<Dynamic>)
	{
		if(endingSong) return;
		
		for(script in scripts)
		{
			script.callFunction(func, args);
		}
	}
}

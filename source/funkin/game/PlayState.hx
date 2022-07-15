package funkin.game;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.game.Song;
import funkin.systems.Conductor;
import funkin.systems.FunkinAssets;
import funkin.systems.HScript;
import funkin.systems.Paths;
import funkin.systems.UIControls;
import funkin.ui.playstate.StrumLine;
import funkin.ui.playstate.StrumNote;
import funkin.ui.playstate.UI;
import haxe.Json;

using StringTools;

class PlayState extends FunkinState
{	
	// Instance
	public static var instance:PlayState;
	
	// Song
	public static var songJSON:Dynamic = null;
	public static var SONG:Song = null;

	public static var scrollSpeed:Float = 3;

	public static var inst:FlxSound;
	public static var voices:FlxSound;

	public static var inCutscene:Bool = false;

	public static var downScroll:Bool = false;

	// Stage & Characters
	public static var stage:Stage;
	public static var dad:Character;
	public static var gf:Character;
	public static var bf:Boyfriend;

	// UI
	public static var UI:UI;

	#if debug
	var debugText:FlxText;
	#end

	public var uiSkin:String = "default";
	public var uiSkinJson:ArrowSkin;

	// Story Mode / Freeplay Shit
	public static var curDifficulty:String = "normal";
	public static var isStoryMode:Bool = false;

	// Camera
	public static var camZooming:Bool = true;
	public static var defaultCamZoom:Float = 1.0;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	public var curSection:Int = 0;
	public var camFollow:FlxObject;
	public var camFollowPos:FlxObject;

	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0;

	public static var cameraSpeed:Float = 1;

	// Misc
	public var health:Float = 1.0;
	public var minHealth:Float = 0.0;
	public var maxHealth:Float = 2.0;

	public var botPlay:Bool = false;

	// Score & Accuracy
	public var songScore:Int = 0;
	public var songAccuracy:Float = 0.0;

	public var combo:Int = 0;
	
	public var totalNotes:Int = 0;
	public var totalHit:Float = 0.0;

	public var marvelous:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	public var songMisses:Int = 0;

	// HScript Shit
	public static var logs:Array<String> = [];
	public static var scripts:Array<HScript> = [];
	
	override public function create()
	{
		super.create();

		scripts = [];

		instance = this;

		startedSong = false;
		endingSong = false;

		persistentUpdate = true;
		persistentDraw = true;

		camZooming = true;

		FlxG.sound.music.stop();

		if(songJSON == null)
			songJSON = SongLoader.getJSON("tutorial");

		SONG = songJSON.song;

		inst = new FlxSound().loadEmbedded(FunkinAssets.getSound(Paths.inst(SONG.song)));
		voices = new FlxSound().loadEmbedded(FunkinAssets.getSound(Paths.voices(SONG.song)));

		FlxG.sound.list.add(inst);
		FlxG.sound.list.add(voices);
		
		if(SONG.keyCount == null)
			SONG.keyCount = 4;

		if(SONG.uiSkin == null)
			SONG.uiSkin = "default";

		uiSkin = SONG.uiSkin;

		scrollSpeed = SONG.speed;

		Conductor.changeBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);

		Conductor.position = Conductor.crochet * -5;

		setupCameras();

		downScroll = Preferences.getOption("downScroll");

		uiSkinJson = Json.parse(FunkinAssets.getText(Paths.json('images/ui/skins/$uiSkin/config')));

		if(SONG.stage == null)
			SONG.stage = "stage";

		stage = new Stage(SONG.stage);
		add(stage);

		// Make Dad and GF real
		dad = new Character(stage.dadPosition.x, stage.dadPosition.y, SONG.player2);
		dad.isPlayer = false;

		var gfVersion:String = "gf";

		if (SONG.player3 != null)
			gfVersion = SONG.player3;

		if (SONG.gfVersion != null)
			gfVersion = SONG.gfVersion;

		if (SONG.gf != null)
			gfVersion = SONG.gf;

		gf = new Character(stage.gfPosition.x, stage.gfPosition.y, gfVersion);

		// Add GF and the objects in the stage that go in front of GF
		add(gf);
		add(stage.inFrontOfGFSprites);

		// Make BF real
		bf = new Boyfriend(stage.bfPosition.x, stage.bfPosition.y, SONG.player1);
		bf.flipX = !bf.flipX;

		// Actually add the guys
		add(dad);
		add(bf);

		dad.dance();
		gf.dance();
		bf.dance();

		// Make tutorial work correctly and not show 2 gfs
		if (dad.curCharacter == gf.curCharacter)
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
		if (gf != null)
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

		UI = new UI();
		UI.cameras = [camHUD];
		add(UI);

		if(!inCutscene)
			startCountdown();

		#if debug
		debugText = new FlxText(10, 0, 0, "", 16);
		debugText.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, OUTLINE, FlxColor.BLACK);
		debugText.borderSize = 2;
		debugText.cameras = [camOther];
		add(debugText);
		#end
	}

	public static var countdownActive:Bool = false;

	public var countdownPreready:FlxSprite;
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;

	public function startCountdown()
	{
		countdownActive = true;
		
		var countdownGraphics:Map<String, Dynamic> = [
			"3" => FunkinAssets.getImage(Paths.image('ui/skins/${uiSkinJson.countdownSkin}/countdown/preready')),
			"2" => FunkinAssets.getImage(Paths.image('ui/skins/${uiSkinJson.countdownSkin}/countdown/ready')),
			"1" => FunkinAssets.getImage(Paths.image('ui/skins/${uiSkinJson.countdownSkin}/countdown/set')),
			"go" => FunkinAssets.getImage(Paths.image('ui/skins/${uiSkinJson.countdownSkin}/countdown/go')),
		];

		var countdownSounds:Map<String, Dynamic> = [
			"3" => FunkinAssets.getSound(Paths.sound('ui/skins/${uiSkinJson.countdownSkin}/countdown/intro3')),
			"2" => FunkinAssets.getSound(Paths.sound('ui/skins/${uiSkinJson.countdownSkin}/countdown/intro2')),
			"1" => FunkinAssets.getSound(Paths.sound('ui/skins/${uiSkinJson.countdownSkin}/countdown/intro1')),
			"go" => FunkinAssets.getSound(Paths.sound('ui/skins/${uiSkinJson.countdownSkin}/countdown/introGo')),
		];

		var swagCounter:Int = 0;

		var antialiasing:Bool = uiSkinJson.skinType != "pixel";

		callOnHScripts("onStartCountdown");

		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (gf != null && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing"))
				gf.dance();

			if (bf != null && bf.animation.curAnim != null && !bf.animation.curAnim.name.startsWith('sing'))
				bf.dance();

			if (dad != null && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing'))
				dad.dance();

			switch (swagCounter)
			{
				case 0:
					Conductor.position = Conductor.crochet * -4;
					FlxG.sound.play(countdownSounds["3"]);

					countdownPreready = new FlxSprite().loadGraphic(countdownGraphics["3"]);

					var sprite:FlxSprite = countdownPreready;
					sprite.screenCenter();
					sprite.antialiasing = antialiasing;
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
				case 1:
					Conductor.position = Conductor.crochet * -3;
					FlxG.sound.play(countdownSounds["2"]);

					countdownReady = new FlxSprite().loadGraphic(countdownGraphics["2"]);

					var sprite:FlxSprite = countdownReady;
					sprite.screenCenter();
					sprite.antialiasing = antialiasing;
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
					Conductor.position = Conductor.crochet * -2;
					FlxG.sound.play(countdownSounds["1"]);

					countdownSet = new FlxSprite().loadGraphic(countdownGraphics["1"]);

					var sprite:FlxSprite = countdownSet;
					sprite.screenCenter();
					sprite.antialiasing = antialiasing;
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
					Conductor.position = Conductor.crochet * -1;
					FlxG.sound.play(countdownSounds["go"]);

					countdownGo = new FlxSprite().loadGraphic(countdownGraphics["go"]);

					var sprite:FlxSprite = countdownGo;
					sprite.screenCenter();
					sprite.antialiasing = antialiasing;
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
					countdownActive = false;
			}

			callOnHScripts("countdownTick", [swagCounter]);
			swagCounter++;
		}, 5);
	}

	public function calculateAccuracy()
	{
		if(totalHit != 0 && totalNotes != 0)
			songAccuracy = totalHit / totalNotes;
		else
			songAccuracy = 0;
	}

	public static var startedSong:Bool = false;
	public static var endingSong:Bool = false;

	public function startSong()
	{
		startedSong = true;
		
		inst.loadEmbedded(FunkinAssets.getSound(Paths.inst(SONG.song)));
		voices.loadEmbedded(FunkinAssets.getSound(Paths.voices(SONG.song)));

		inst.play();
		voices.play();

		Conductor.position = 0.0;
	}

	public function endSong(saveScore:Bool = true)
	{
		endingSong = true;

		persistentUpdate = false;
		persistentDraw = true;

		// stop the inst and voices
		inst.stop();
		voices.stop();

		// save your score
		#if MODS_ALLOWED
		var songNameForScoreLol:String = SONG.song.toLowerCase().trim()+"-"+softmod.SoftMod.modsList[GlobalVariables.selectedMod];
		#else
		var songNameForScoreLol:String = SONG.song.toLowerCase().trim();
		#end

		if(saveScore)
		{
			if(songScore > Highscore.getScore(songNameForScoreLol, curDifficulty.trim()))
				Highscore.setScore(songNameForScoreLol, curDifficulty.trim(), songScore);
		}
		
		// go back to menu
		FlxG.sound.playMusic(FunkinAssets.getSound(Paths.music("freakyMenu")));
		if(isStoryMode)
			switchState(new funkin.menus.TitleState());
		else
			switchState(new funkin.menus.FreeplayMenu());
	}

	var lastSection:Int = 0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		callOnHScripts("update", [elapsed]);

		if(!inCutscene)
		{
			Conductor.position += elapsed * 1000.0;
			
			if(Conductor.position >= 0 && !startedSong)
				startSong();

			// song ending lol
			if(Conductor.position >= inst.length && startedSong && !endingSong)
				endSong();

			if(UIControls.justPressed("BACK") && !endingSong)
				endSong(true);
		}

		#if debug
		if(FlxG.keys.justPressed.EIGHT)
			switchState(new funkin.menus.CharacterEditor());
		#end

		refreshHealth();

		if(camZooming)
		{
			camGame.zoom = FlxMath.lerp(camGame.zoom, 1, delta * 5);
			camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, delta * 5);
		}
		
		#if debug
		debugText.text = (
			"Song Position: " + Conductor.position + "\n" +
			"Current Beat: " + Conductor.currentBeat + "(" + Conductor.currentBeatFloat + ")" + "\n" +
			"Current Step: " + Conductor.currentStep + "(" + Conductor.currentStepFloat + ")" + "\n" +
			"Current BPM: " + Conductor.bpm + "\n" +
			"Song BPM: " + SONG.bpm
		);
		debugText.y = FlxG.height - (debugText.height + 10);
		#end

		for(section in SONG.notes)
		{
			for(note in section.sectionNotes)
			{
				if(Conductor.position > (note[0] - 2500))
				{
					var daNoteData:Int = Std.int(note[1]) % SONG.keyCount;
					var mustPress:Bool = true;
			
					if(section.mustHitSection && Std.int(note[1]) % (SONG.keyCount * 2) >= SONG.keyCount)
						mustPress = false;
					else if(!section.mustHitSection && Std.int(note[1]) % (SONG.keyCount * 2) <= SONG.keyCount - 1)
						mustPress = false;

					var newNote:Note = new Note(-9999, -9999, false, SONG.keyCount, daNoteData, uiSkin);
					newNote.mustPress = mustPress;
					newNote.strumTime = note[0];
					newNote.downScroll = downScroll;

					var strumLine:StrumLine = mustPress ? UI.playerStrums : UI.opponentStrums;
					
					var susLength:Int = Math.floor(note[2] / Conductor.stepCrochet);
					if(susLength <= 2)
						susLength = 0;
					
					for(susNote in 0...susLength)
					{
						var newSusNote:Note = new Note(-9999, -9999, true, SONG.keyCount, daNoteData, uiSkin);
						newSusNote.mustPress = mustPress;
						newSusNote.strumTime = note[0] + ((Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / scrollSpeed));
						newSusNote.downScroll = downScroll;
						newSusNote.flipY = downScroll;
						
						if(susNote == susLength-1)
							newSusNote.playAnim("tail");
						else
							newSusNote.playAnim("hold");
	
						strumLine.notes.add(newSusNote);
					}
					
					strumLine.notes.add(newNote);

					section.sectionNotes.remove(note);
				}
			}
		}

		var bruj:Int = Std.int(Conductor.currentStep / 16);
		if (bruj < 0)
			bruj = 0;
		if (bruj > SONG.notes.length - 1)
			bruj = SONG.notes.length - 1;

		if (SONG.notes[bruj] != null)
		{
			var curSection = bruj;
			if (curSection != lastSection)
			{
				// section reset stuff
				var lastMustHit:Bool = SONG.notes[lastSection].mustHitSection;
				if (SONG.notes[curSection].mustHitSection != lastMustHit)
				{
					camDisplaceX = 0;
					camDisplaceY = 0;
				}
				lastSection = bruj;
			}

			if (!SONG.notes[bruj].mustHitSection)
			{
				var char = dad;

				var getCenterX = char.getMidpoint().x + 100;
				var getCenterY = char.getMidpoint().y - 100;

				camFollow.setPosition(getCenterX + camDisplaceX + char.cameraOffset[0], getCenterY + camDisplaceY + char.cameraOffset[1]);
			}
			else
			{
				var char = bf;

				var getCenterX = char.getMidpoint().x - 100;
				var getCenterY = char.getMidpoint().y - 100;

				camFollow.setPosition(getCenterX + camDisplaceX - char.cameraOffset[0], getCenterY + camDisplaceY + char.cameraOffset[1]);
			}
		}

		var lerpVal:Float = cameraSpeed * (delta * 2);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		callOnHScripts("updatePost", [elapsed]);
	}

	override public function beatHit()
	{
		super.beatHit();

		callOnHScripts("beatHit", [Conductor.currentBeat]);

		UI.beatHit();

		if (gf != null && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing"))
			gf.dance();

		if (bf != null && bf.animation.curAnim != null && !bf.animation.curAnim.name.startsWith('sing'))
			bf.dance();

		if (dad != null && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing'))
			dad.dance();

		if(camZooming && Conductor.currentBeat % 4 == 0)
		{
			camGame.zoom += 0.015;
			camHUD.zoom += 0.05;
		}

		callOnHScripts("beatHitPost", [Conductor.currentBeat]);
	}

	override public function stepHit()
	{
		super.stepHit();

		callOnHScripts("stepHit", [Conductor.currentStep]);

		UI.stepHit();
		
		if(startedSong && !endingSong)
		{
			if(!(Conductor.isAudioSynced(inst) && Conductor.isAudioSynced(voices)))
				resyncSong();
		}

		callOnHScripts("stepHitPost", [Conductor.currentStep]);
	}

	public static function resyncSong()
	{
		//trace('before sync: inst time ${inst.time} -- voices time ${voices.time} -- song pos ${Conductor.position}');
		inst.pause();
		voices.pause();

		inst.time = Conductor.position;
		voices.time = Conductor.position;

		inst.play();
		voices.play();
		//trace('after sync: inst time ${inst.time} -- voices time ${voices.time} -- song pos ${Conductor.position}');
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

	public function refreshHealth()
	{
		if(health < minHealth)
			health = minHealth;

		if(health > maxHealth)
			health = maxHealth;
	}

	public function callOnHScripts(func:String, ?args:Array<Dynamic>)
	{
		if(endingSong) return;

		for(script in scripts)
			script.callFunction(func, args);
	}
}

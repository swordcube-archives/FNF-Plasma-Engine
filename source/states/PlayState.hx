package states;

import base.Conductor;
import base.Controls;
import base.MusicBeat.MusicBeatState;
import base.Song;
import base.SongLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.playState.StrumLine;
import ui.playState.UI;

class PlayState extends MusicBeatState
{
	// Instance
	public static var instance:PlayState;

	// Song Shit
	public static var SONG:Dynamic;

	public static var isStoryMode:Bool = false;

	public static var songData:Song;

	// Strum Lines
	var opponentStrums:StrumLine;
	var playerStrums:StrumLine;

	// Cameras
	public var camZooming:Bool = true;
	public var defaultCamZoom:Float = 1.0;
	
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	// UI
	public var UI:UI;

	// Health
	public var health:Float = 1;
	public var minHealth:Float = 0;
	public var maxHealth:Float = 2;

	// Music
	var freakyMenu:Dynamic;

	// Song
	var cachedSong:Map<String, Dynamic> = [];
	var voices:FlxSound = new FlxSound();

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

		freakyMenu = GenesisAssets.getAsset('freakyMenu', MUSIC);

		persistentUpdate = true;
		persistentDraw = true;

		if(SONG == null)
			SONG = SongLoader.loadJSON("test", "normal");

		songData = SONG.song;

		cachedSong = [
			"inst" => GenesisAssets.getAsset('${songData.song.toLowerCase()}/Inst', GenesisAssets.AssetType.SONG),
			"voices" => getVocals(),
		];

		FlxG.sound.music.stop();

		setupCameras();

		UI = new UI();
		UI.cameras = [camHUD];
		add(UI);

		Conductor.changeBPM(songData.bpm);
		Conductor.mapBPMChanges(songData);
		Conductor.songPosition = Conductor.crochet * -5;

		startCountdown();
	}

	var physicsUpdateTimer:Float = 0;

	override public function update(elapsed:Float)
	{
		if(health < minHealth)
			health = minHealth;

		if(health > maxHealth)
			health = maxHealth;
		
		super.update(elapsed);

		physicsUpdateTimer += elapsed;
		if(physicsUpdateTimer > 1 / 60)
		{
			physicsUpdate();
			physicsUpdateTimer = 0;
		}

		Conductor.songPosition += FlxG.elapsed * 1000;

		if(Controls.isPressed("BACK", JUST_PRESSED))
		{
			FlxG.sound.playMusic(freakyMenu);
			// Story Mode doesn't exist yet so it just takes you to Freeplay instead
			/*if(isStoryMode)
				States.switchState(this, new StoryMenu());
			else*/
				States.switchState(this, new FreeplayMenu());
		}
	}

	public function physicsUpdate()
	{
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
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
		var textureAntiAliasing:Bool = !(UI.opponentStrums.members[0].json.skinType == "pixel");

		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
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
					Conductor.songPosition = 0;
					
					FlxG.sound.playMusic(cachedSong["inst"], 1, false);
					if(cachedSong["voices"] != null)
						voices = new FlxSound().loadEmbedded(cachedSong["voices"]);
					
					FlxG.sound.music.pause();
					FlxG.sound.music.time = 0;
					FlxG.sound.music.play();
					if(cachedSong["voices"] != null)
						voices.play();
			}

			swagCounter++;
		}, 5);
	}

	override public function beatHit()
	{
		super.beatHit();
		UI.beatHit();

		if(camZooming && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.05;
		}
	}

	override public function stepHit()
	{
		super.stepHit();
		UI.stepHit();

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(voices.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}
	}

	function resyncVocals():Void
	{
		if(countdownActive) return;

		voices.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		voices.time = Conductor.songPosition;
		voices.play();
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

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

	public function new()
	{
		super();
		instance = this;
	}

	override public function create()
	{
		super.create();

		persistentUpdate = true;
		persistentDraw = true;

		if(SONG == null)
			SONG = SongLoader.loadJSON("test", "normal");

		songData = SONG.song;

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
			// Story Mode doesn't exist yet so it just takes you to Freeplay instead
			/*if(isStoryMode)
				States.switchState(this, new StoryMenu());
			else*/
				States.switchState(this, new FreeplayMenu());
		}
	}

	public function physicsUpdate()
	{
		//FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
	}

	public var startedCountdown:Bool = false;

	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;

	public function startCountdown()
	{
		startedCountdown = true;
		
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
					FlxG.sound.play(countdownSounds["3"]);
				case 1:
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
					startedCountdown = false;
					Conductor.songPosition = 0;
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
			//camHUD.zoom += 0.065;
		}
	}

	override public function stepHit()
	{
		super.stepHit();
		UI.stepHit();
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

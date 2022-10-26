package funkin.states;

import flixel.system.FlxSound;
import base.SongLoader;
import openfl.media.Sound;
import flixel.FlxCamera;
import funkin.gameplay.FunkinUI;

class PlayState extends FunkinState {
    public static var songData:Song = SongLoader.returnSong("bopeebo", "hard");
    public static var current:PlayState;
    public static var isStoryMode:Bool = false;

    public var UI:FunkinUI;

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

	public var defaultCamZoom:Float = 1.0;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

    public var songSpeed:Float = 1.0;

    public var startedSong:Bool = false;
    public var endingSong:Bool = false;

    public var cachedSounds:Map<String, Sound> = [
        // Music
        "titleScreen" => Assets.load(SOUND, Paths.music("menus/titleScreen"))
    ];
    public var vocals:FlxSound = new FlxSound();

    public function new(songSpeed:Float = 1.0) {
        super();
        current = this;
        this.songSpeed = songSpeed;
    }

    override function create() {
        super.create();
        current = this;
		
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

        // Setup song
        Conductor.changeBPM(songData.bpm);
        Conductor.mapBPMChanges(songData);
        Conductor.position = Conductor.crochet * -5;

        cachedSounds["inst"] = Assets.load(SOUND, Paths.songInst(songData.song));
        if(FileSystem.exists(Paths.songVoices(songData.song))) {
            cachedSounds["voices"] = Assets.load(SOUND, Paths.songVoices(songData.song));
            vocals.loadEmbedded(cachedSounds["voices"]);
        }

        // Setup UI
        UI = new FunkinUI();
        UI.cameras = [camHUD];
        add(UI);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        Conductor.position += elapsed * 1000.0;
        if(Conductor.position >= 0 && !startedSong)
            startSong();

        if(Controls.getP("back")) {
            endingSong = true;
            FlxG.sound.playMusic(cachedSounds["titleScreen"]);
            Main.switchState(new FreeplayMenu());
        }
    }

    function startSong() {
        startedSong = true;
        Conductor.position = 0;
        FlxG.sound.playMusic(cachedSounds["inst"], 1, false);
        if(cachedSounds.exists("voices"))
            vocals.play();

        FlxG.sound.music.pause();
        vocals.pause();

        FlxG.sound.music.time = 0;
        vocals.time = 0;

        FlxG.sound.music.play();
        vocals.play();
    }

    override function destroy() {
        current = null;
        super.destroy();
    }
}
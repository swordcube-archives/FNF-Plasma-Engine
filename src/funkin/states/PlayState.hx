package funkin.states;

import flixel.FlxCamera;
import funkin.gameplay.FunkinUI;

class PlayState extends FunkinState {
    public static var current:PlayState;

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

    public function new(songSpeed:Float = 1.0) {
        super();
        current = this;
        this.songSpeed = songSpeed;
    }

    override function create() {
        super.create();
        current = this;
		
		FlxG.sound.music.stop();

        camGame = FlxG.camera;
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor = 0x0;
		camOther.bgColor = 0x0;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

        UI = new FunkinUI();
        UI.cameras = [camHUD];
        add(UI);
    }

    override function destroy() {
        current = null;
        super.destroy();
    }
}
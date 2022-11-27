package;

import funkin.ui.LogsOverlay;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite {
	public static var buildNumber:Int = -1; // Doesn't work on release builds because fuck you!
	public static var developerMode:Bool = false; // Doesn't work on release builds because fuck you!

	/**
		A less lengthy way to get `version` from `Project.xml`
	**/
	public static var engineVersion(get, null):String;

	static function get_engineVersion() {
		return lime.app.Application.current.meta.get('version');
	}

	public static var fpsCounter:FPS;
	public static var logsOverlay:LogsOverlay;

	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = Init; // The FlxState the game starts with.
	var framerate:Int = 1000; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	@:dox(hide)
	public static var audioDisconnected:Bool = false;
	public static var changeID:Int = 0;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public function new() {
		super();

		addChild(new FlxGame(gameWidth, gameHeight, initialState, 1, framerate, framerate, skipSplash, startFullscreen));
		addChild(logsOverlay = new LogsOverlay());
		addChild(fpsCounter = new FPS(10, 3, 0xFFFFFF));
	}
}

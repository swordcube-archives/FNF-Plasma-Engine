package;

import flixel.util.FlxColor;
import funkin.ui.GenesisFPS;
import openfl.Lib;

class Main extends openfl.display.Sprite
{
	public static var game:flixel.FlxGame; // The game itself
	public static var fpsCounter:GenesisFPS; // The FPS counter
	
	public var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	public var framerate:Int = 1000; // How many frames per second the game should run at.
	public var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	public var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public var initState:Dynamic = funkin.Init; 

	public function new()
	{
		super();

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		game = new flixel.FlxGame(gameWidth, gameHeight, initState, zoom, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		fpsCounter = new GenesisFPS(10, 3, FlxColor.WHITE);
		addChild(fpsCounter);
	}
}

package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
import openfl.display.Sprite;
import ui.GenesisFPS;

class Main extends Sprite
{
	public static var curState:Class<FlxState> = Init; // The FlxState the game starts with.
	
	public var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	public var framerate:Int = 60; // How many frames per second the game should run at.
	public var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	public var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public var fpsCounter:GenesisFPS; // The thing used to display FPS and Memory usage

	public var game:FlxGame;

	public function new()
	{
		super();
		game = new FlxGame(gameWidth, gameHeight, curState, zoom, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		fpsCounter = new GenesisFPS(10, 3, FlxColor.WHITE);
		addChild(fpsCounter);

		FlxG.fixedTimestep = false; // This ensures that the game is not tied to the FPS
		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = false; // Hide mouse on start
	}
}

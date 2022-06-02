package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.UncaughtErrorEvent;
import states.TitleState;
import ui.GenesisFPS;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

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
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

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
		
		game = new FlxGame(gameWidth, gameHeight, curState, zoom, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		fpsCounter = new GenesisFPS(10, 3, FlxColor.WHITE);
		addChild(fpsCounter);

		FlxG.fixedTimestep = false; // This ensures that the game is not tied to the FPS
		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = false; // Hide mouse on start
	}
	
	// makes the game tell yoiu things when it crashes, i think!!
	function onCrash(e:UncaughtErrorEvent)
	{
		#if sys
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = "./crash/" + "GenesisEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/swordcube/FNF-Genesis-Engine";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		// display a message then die
		Application.current.window.alert(errMsg, "Something went wrong!");
		//DiscordClient.shutdown();
		Sys.exit(1);
		#end
	}
}

package;

import display.PlasmaFPS;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxStringUtil;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;

using StringTools;

class Main extends Sprite {
	public static var engineVersion:String = "0.1.0"; // The version of the engine

	public static var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var framerate:Int = 1000; // How many frames per second the game should run at.
	public static var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	public static var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsCounter:PlasmaFPS;

	public static var deltaTime:Float = 0.0;

	static var startTime:Float = 0.0;
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.

	public static var currentState:Class<flixel.FlxState> = Init; // The FlxState the game starts with.
	
	public function new()
	{
		super();
		startTime = getTime(true);
		
		setupZoom(); // Setup the "zoom" variable

		// Start the game
		addChild(new FlxGame(gameWidth, gameHeight, currentState, zoom, framerate, framerate, skipSplash, startFullscreen));

		// FPS Counter
		fpsCounter = new PlasmaFPS(10, 3, 0xFFFFFFFF);
		addChild(fpsCounter);
	}

	public static function getSizeLabel(num:Int):String
	{
        var size:Float = num;
        var data = 0;
        var dataTexts = ["b", "kb", "mb", "gb", "tb", "pb"];
        while(size > 1024 && data < dataTexts.length - 1) {
          data++;
          size = size / 1024;
        }
        
        size = Math.round(size * 100) / 100;
        return size+dataTexts[data]; // smth like 100mb
    }

	function setupZoom()
	{
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
	}

	/**
		A function to switch to a new state.

		@param newState          The state to switch to (Must be an `FlxState` or a state based off of `FlxState`)
		@param transition        Whether or not to transition to the scene. Change `source/Transition.hx` to change how the transition looks.
	**/
	public static function switchState(newState:flixel.FlxState, transition:Bool = true)
	{
		currentState = Type.getClass(newState);
		FlxTransitionableState.skipNextTransOut = !transition;
		if (transition)
		{
			FlxG.state.openSubState(new Transition(0.45, false));
			Transition.finishCallback = function() {
				FlxG.switchState(newState);
			};
			return trace('changed state to ${Type.getClassName(currentState)} (with transition)');
		}
		FlxG.switchState(newState);
		return trace('changed state to ${Type.getClassName(currentState)} (without transition)');
	}

	/**
		Resets the current state.

		@param transition        Whether or not to transition to the scene. Change `source/Transition.hx` to change how the transition looks.
	**/
	public static function resetState(transition:Bool = true)
	{
		FlxTransitionableState.skipNextTransOut = !transition;
		if (transition)
		{
			FlxG.state.openSubState(new Transition(0.45, false));
			Transition.finishCallback = function() {
				FlxG.resetState();
			};
			return trace('reloaded current state ${Type.getClassName(currentState)} (with transition)');
		}
		FlxG.resetState();
		return trace('reloaded current state ${Type.getClassName(currentState)} (without transition)');
	}

	/**
		A function for tracing/printing text with indicators for errors, warnings, and hscript prints.
	**/
	public static function print(type:String, text:String)
	{
		switch(type.toLowerCase())
		{
			case "error":
				trace('[   ERROR   ] '+text);

			case "warn" | "warning":
				trace('[  WARNING  ] '+text);
				
			case "hxs" | "hscript":
				trace('[  HSCRIPT  ] '+text);
		}
	}

	/**
	 * Get the time in seconds.
	 * @param abs Whether the timestamp is absolute or relative to the start time.
	 */
	public static function getTime(abs:Bool = false):Float
	{
		#if sys
		// Use this one on CPP and Neko since it's more accurate.
		return abs ? Sys.time() : (Sys.time() - startTime);
		#else
		// This one is more accurate on non-CPP platforms.
		return abs ? Date.now().getTime() : (Date.now().getTime() - startTime);
		#end
	}
}
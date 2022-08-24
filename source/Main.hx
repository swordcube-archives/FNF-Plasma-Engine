package;

import lime.app.Application;
import states.ScriptedState;
import display.PlasmaFPS;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxStringUtil;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import ui.Notification;

using StringTools;

class Main extends Sprite
{
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

		Application.current.onExit.add(function(exitCode) {
			#if discord_rpc
			DiscordRPC.shutdown();
			#end
			Init.saveSettings();
		});
	}

	public static function getOS()
	{
		#if windows
		return "Windows";
		#end
		#if html5
		return "HTML5";
		#end
		#if mac
		return "Mac";
		#end
		#if linux
		return "Linux";
		#end
		#if android
		return "Android";
		#end

		// Fallback if we can't find the OS the user is on
		return "Unknown";
	}

	public static function getSizeLabel(num:Int):String
	{
		// 2147483648 is 2048 mb btw lmao
		var size:Float = Math.abs(num) != num ? Math.abs(num) + 2147483648 : num;
		var data = 0;
		var dataTexts = ["b", "kb", "mb", "gb", "tb", "pb"];

		while (size > 1024 && data < dataTexts.length - 1)
		{
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		return size + dataTexts[data]; // smth like 100mb
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
			Transition.finishCallback = function()
			{
				FlxG.switchState(newState);
			};
			if (Std.isOfType(newState, states.ScriptedState))
				return print('trace', 'Switched state to states.ScriptedState [${cast(newState, ScriptedState).name}] (transition)');
			else
				return print('trace', 'Switched state to ${Type.getClassName(currentState)} (transition)');
		}
		FlxG.switchState(newState);
		if (Std.isOfType(newState, states.ScriptedState))
			return print('trace', 'Switched state to states.ScriptedState [${cast(newState, ScriptedState).name}] (no transition)');
		else
			return print('trace', 'Switched state to ${Type.getClassName(currentState)} (no transition)');
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
			Transition.finishCallback = function()
			{
				if (Std.isOfType(FlxG.state, states.ScriptedState))
					FlxG.switchState(new ScriptedState(cast(FlxG.state, ScriptedState).name, cast(FlxG.state, ScriptedState).args));
				else
					FlxG.resetState();
			};
			if (Std.isOfType(FlxG.state, states.ScriptedState))
				return trace('Reloaded state states.ScriptedState [${cast(FlxG.state, ScriptedState).name}] (transition)');
			else
				return trace('Reloaded state ${Type.getClassName(currentState)} (transition)');
		}
		if (Std.isOfType(FlxG.state, states.ScriptedState)) {
			FlxG.switchState(new ScriptedState(cast(currentState, ScriptedState).name, cast(currentState, ScriptedState).args));
			return trace('Reloaded state states.ScriptedState [${cast(currentState, ScriptedState).name}] (no transition)');
		} else {
			FlxG.resetState();
			return trace('Reloaded state ${Type.getClassName(currentState)} (no transition)');
		}
	}

	/**
		A function for tracing/printing text with indicators for errors, warnings, and hscript prints.
	**/
	public static function print(type:String, text:String)
	{
		switch (type.toLowerCase())
		{
			case "error":
				trace('[   ERROR   ] ' + text);
				Init.log('error', text);
				return;

			case "warn" | "warning":
				trace('[  WARNING  ] ' + text);
				Init.log('warning', text);
				return;

			case "hxs" | "hscript":
				trace('[  HSCRIPT  ] ' + text);
				Init.log('hscript', text);
				return;
		}
		trace(text);
		Init.log('trace', text);
		return;
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

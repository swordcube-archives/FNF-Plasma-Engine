package;

import display.PlasmaFPS;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxStringUtil;
import lime.app.Application;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import states.ScriptedState;
import ui.Notification;

using StringTools;

class Main extends Sprite
{
	public static var engineVersion:String = "0.1.0";
	public static var gameWidth:Int = 1280;
	public static var gameHeight:Int = 720;

	public static var framerate:Int = 1000;
	
	/**
		Whether to skip the flixel splash screen that appears in release mode.
	**/
	public static var skipSplash:Bool = true;
	public static var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsCounter:PlasmaFPS;

	/**
		A better version of FlxG.elapsed.
	**/
	public static var deltaTime:Float = 0.0;

	static var startTime:Float = 0.0;

	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.

	/**
		The FlxState the game starts with.
	**/
	public static var currentState:Class<flixel.FlxState> = Init;

	public static var ansiColors:Map<String,String> = new Map();

	public function new()
	{
		super();
		startTime = getTime(true);

		setupZoom(); // Setup the "zoom" variable
		initAnsiColors();

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

	public static function initAnsiColors()
	{
		ansiColors['black'] = '\033[0;30m';
		ansiColors['red'] = '\033[31m';
		ansiColors['green'] = '\033[32m';
		ansiColors['yellow'] = '\033[33m';
		ansiColors['blue'] = '\033[1;34m';
		ansiColors['magenta'] = '\033[1;35m';
		ansiColors['cyan'] = '\033[0;36m';
		ansiColors['grey'] = '\033[0;37m';
		ansiColors['white'] = '\033[1;37m';
		ansiColors['orange'] = '\033[38;5;214m';

		// reuse it for quick lookups of colors to log levels
		ansiColors['default'] = ansiColors['grey'];
	}

	public static function getOS()
	{
		#if sys return Sys.systemName(); #end
		#if html5 return "HTML5"; #end
		#if android return "Android"; #end

		// Fallback if we can't find the OS the user is on (or is unsupported)
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
				return #if DEBUG_PRINTING print('debug', 'Switched state to states.ScriptedState [${cast(newState, ScriptedState).name}] (transition)') #end;
			else
				return #if DEBUG_PRINTING print('debug', 'Switched state to ${Type.getClassName(currentState)} (transition)') #end;
		}
		FlxG.switchState(newState);
		if (Std.isOfType(newState, states.ScriptedState))
			return #if DEBUG_PRINTING print('debug', 'Switched state to states.ScriptedState [${cast(newState, ScriptedState).name}] (no transition)') #end;
		else
			return #if DEBUG_PRINTING print('debug', 'Switched state to ${Type.getClassName(currentState)} (no transition)') #end;
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
				return #if DEBUG_PRINTING print('debug', 'Reloaded state states.ScriptedState [${cast(FlxG.state, ScriptedState).name}] (transition)') #end;
			else
				return #if DEBUG_PRINTING print('debug', 'Reloaded state ${Type.getClassName(currentState)} (transition)') #end;
		}
		if (Std.isOfType(FlxG.state, states.ScriptedState)) {
			FlxG.switchState(new ScriptedState(cast(currentState, ScriptedState).name, cast(currentState, ScriptedState).args));
			return #if DEBUG_PRINTING print('debug', 'Reloaded state states.ScriptedState [${cast(currentState, ScriptedState).name}] (no transition)') #end;
		} else {
			FlxG.resetState();
			return #if DEBUG_PRINTING print('debug', 'Reloaded state ${Type.getClassName(currentState)} (no transition)') #end;
		}
	}

	/**
		A function for tracing/printing text with indicators for errors, warnings, and hscript prints.
	**/
	public static function print(type:String, text:String)
	{
		switch (type.toLowerCase())
		{
			case "debug":
				trace('${ansiColors["cyan"]}[   DEBUG   ] ${ansiColors["default"]}' + text);
				Init.log('debug', text);
				return;

			case "error":
				trace('${ansiColors["red"]}[   ERROR   ] ${ansiColors["default"]}' + text);
				Init.log('error', text);
				return;

			case "warn" | "warning":
				trace('${ansiColors["yellow"]}[  WARNING  ] ${ansiColors["default"]}' + text);
				Init.log('warning', text);
				return;

			case "hxs" | "hscript":
				trace('${ansiColors["orange"]}[  HSCRIPT  ] ${ansiColors["default"]}' + text);
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

package;

import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import funkin.Transition;
import lime.app.Application;
import misc.FPSCounter;
import openfl.display.Sprite;
import scenes.ScriptedScene;

using StringTools;

class Main extends Sprite {
	// Edit game settings here!
	public static var gameInfo = {
		width: 1280,
		height: 720,
		framerate: 1000,
		appTitle: "FNF: Plasma Engine",
		startingScene: scenes.ScriptedScene,
		startingSceneArgs: ["TitleScene"],
		skipFlixelSplash: true
	};

	public static var engineVersion:String = "1.0.0";

	/**
		The frames per second (FPS) of the game. Change this variable to instantly change the FPS.
	**/
	public static var framerate(default, set):Int = 1000;
	static function set_framerate(value:Int):Int {
		var modified_value = Std.int(FlxMath.bound(value, 10, 1000));
		if(modified_value > FlxG.drawFramerate) {
			FlxG.updateFramerate = modified_value;
			FlxG.drawFramerate = modified_value;
		} else {
			FlxG.drawFramerate = modified_value;
			FlxG.updateFramerate = modified_value;
		}
		return framerate = modified_value;
	}

	public static var fpsCounter:FPSCounter;

	public static var currentState:Class<Scene> = Init;
	
	public static var ansiColors:Map<String,String> = new Map();

	/**
		Supported file types for scripts.
	**/
	public static var supportedFileTypes:Array<String> = [
		".lua",
		".hxs",
		".hsc",
		".hscript",
		".hx"
	];
	
	public static function fixWorkingDirectory() {
		var curDir = Sys.getCwd();
		var execPath = Sys.programPath();
		var p = execPath.replace("\\", "/").split("/");
		var execName = p.pop(); // interesting
		Sys.setCwd(p.join("\\") + "\\");
	}

	public function new() {
		super();
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

		ansiColors['default'] = ansiColors['grey'];

		Application.current.window.title = gameInfo.appTitle;
		addChild(new FlxGame(
			gameInfo.width, 
			gameInfo.height, 
			Init, 
			1, // The default zoom used for cameras
			gameInfo.framerate, 
			gameInfo.framerate, 
			gameInfo.skipFlixelSplash
		));
		#if !mobile
		fpsCounter = new FPSCounter(10, 3, FlxColor.WHITE);
		addChild(fpsCounter);
		#end
	}

	/**
		Generates a more human-readable version of `num` (must be in bytes)
		@param num        The bytes to convert.
	**/
	public static function getSizeLabel(num:UInt):String {
		var size:Float = Math.abs(num) != num ? Math.abs(num) + 2147483648 : num;
		var data = 0;
		var dataTexts = ["b", "kb", "mb", "gb", "tb", "pb"];

		while (size > 1024 && data < dataTexts.length - 1) {
			data++;
			size = size / 1024;
		}

		return FlxMath.roundDecimal(size, 2) + dataTexts[data];
	}

	public static function print(type:String, text:String) {
		switch (type.toLowerCase()) {
			case "debug":
				Sys.println('${ansiColors["cyan"]}[   DEBUG   ] ${ansiColors["default"]}' + text);

			case "error":
				Sys.println('${ansiColors["red"]}[   ERROR   ] ${ansiColors["default"]}' + text);

			case "warn" | "warning":
				Sys.println('${ansiColors["yellow"]}[  WARNING  ] ${ansiColors["default"]}' + text);

			case "hscript":
				Sys.println('${ansiColors["magenta"]}[  HSCRIPT  ] ${ansiColors["default"]}' + text);

			case "lua":
				Sys.println('${ansiColors["cyan"]}[    LUA    ] ${ansiColors["default"]}' + text);

			default:
				Sys.println('${ansiColors["blue"]}[   TRACE   ] ${ansiColors["default"]}' + text);
		}
	}

	/**
		A function to switch to a new scene.
		@param newState          The scene to switch to (Must be an `FlxState` or a scene based off of `FlxState`)
		@param transition        Whether or not to transition to the scene. Change `source/Transition.hx` to change how the transition looks.
	**/
	public static function switchScene(newState:Scene, transition:Bool = true) {
		currentState = Type.getClass(newState);
		FlxTransitionableState.skipNextTransOut = !transition;
		if (transition) {
			FlxG.state.openSubState(new Transition(0.45, false));
			Transition.finishCallback = function() {
				FlxG.switchState(newState);
			};
			if (Std.isOfType(newState, ScriptedScene))
				return #if DEBUG_PRINTING print('debug', 'Switched state to scenes.ScriptedScene [${cast(newState, ScriptedScene).name}] (transition)') #end;
			else
				return #if DEBUG_PRINTING print('debug', 'Switched state to ${Type.getClassName(currentState)} (transition)') #end;
		}
		FlxG.switchState(newState);
		if (Std.isOfType(newState, ScriptedScene))
			return #if DEBUG_PRINTING print('debug', 'Switched state to scenes.ScriptedScene [${cast(newState, ScriptedScene).name}] (no transition)') #end;
		else
			return #if DEBUG_PRINTING print('debug', 'Switched state to ${Type.getClassName(currentState)} (no transition)') #end;
	}

	/**
		Resets the current scene.
		@param transition        Whether or not to transition to the scene. Change `source/Transition.hx` to change how the transition looks.
	**/
	public static function resetScene(transition:Bool = true) {
		FlxTransitionableState.skipNextTransOut = !transition;
		if (transition) {
			FlxG.state.openSubState(new Transition(0.45, false));
			Transition.finishCallback = function() {
				if (Std.isOfType(FlxG.state, scenes.ScriptedScene))
					FlxG.switchState(new ScriptedScene(cast(FlxG.state, ScriptedScene).name, cast(FlxG.state, ScriptedScene).args));
				else
					FlxG.resetState();
			};
			if (Std.isOfType(FlxG.state, scenes.ScriptedScene))
				return #if DEBUG_PRINTING print('debug', 'Reloaded state scenes.ScriptedScene [${cast(FlxG.state, ScriptedScene).name}] (transition)') #end;
			else
				return #if DEBUG_PRINTING print('debug', 'Reloaded state ${Type.getClassName(currentState)} (transition)') #end;
		}
		if (Std.isOfType(FlxG.state, scenes.ScriptedScene)) {
			FlxG.switchState(new ScriptedScene(cast(currentState, ScriptedScene).name, cast(currentState, ScriptedScene).args));
			return #if DEBUG_PRINTING print('debug', 'Reloaded state scenes.ScriptedScene [${cast(currentState, ScriptedScene).name}] (no transition)') #end;
		} else {
			FlxG.resetState();
			return #if DEBUG_PRINTING print('debug', 'Reloaded state ${Type.getClassName(currentState)} (no transition)') #end;
		}
	}
}

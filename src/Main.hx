package;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import base.FPSCounter;
import funkin.Transition;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public static var engineVersion:String = "1.0.0";
	public static var currentState:Class<FlxState> = funkin.states.TitleScreen;

	public static var fpsCounter:FPSCounter;

	public function new() {
		super();
		Console.init();
		FlxTransitionableState.skipNextTransOut = true;
		addChild(new FlxGame(1280, 720, currentState, 1, 1000, 1000, true));
		addChild(fpsCounter = new FPSCounter(10, 3, 0xFFFFFFFF));
		FlxG.fixedTimestep = false;
		FlxG.mouse.visible = false;
		addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
			switch(e.keyCode) {
				case Keyboard.F11:
					FlxG.fullscreen = !FlxG.fullscreen;
			}
		});
	}

	/**
		A function to switch to a new state.

		@param newState          The state to switch to (Must be an `FlxState` or a state based off of `FlxState`)
		@param transition        Whether or not to transition to the scene. Change `source/Transition.hx` to change how the transition looks.
	**/
	public static function switchState(newState:flixel.FlxState, transition:Bool = true) {
		currentState = Type.getClass(newState);
		FlxTransitionableState.skipNextTransOut = !transition;
		if (transition) {
			FlxG.state.openSubState(new Transition(0.45, false));
			Transition.finishCallback = function() {
				FlxG.switchState(newState);
			};
			return #if debug Console.debug('Switched state to ${Type.getClassName(currentState)} (transition)') #end;
		}
		FlxG.switchState(newState);
		return #if debug Console.debug('Switched state to ${Type.getClassName(currentState)} (no transition)') #end;
	}

	/**
		Resets the current state.

		@param transition        Whether or not to transition to the scene. Change `source/Transition.hx` to change how the transition looks.
	**/
	public static function resetState(transition:Bool = true) {
		FlxTransitionableState.skipNextTransOut = !transition;
		if (transition) {
			FlxG.state.openSubState(new Transition(0.45, false));
			Transition.finishCallback = function() {
				FlxG.resetState();
			};
			return #if debug Console.debug('Reloaded state ${Type.getClassName(currentState)} (transition)') #end;
		}
		FlxG.resetState();
		return #if debug Console.debug('Reloaded state ${Type.getClassName(currentState)} (no transition)') #end;
	}
}

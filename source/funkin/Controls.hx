package funkin;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;

typedef ControlData = {
    var key1:FlxKey;
    var key2:FlxKey;
};

class Controls {
    // just pressed
    public static var UI_UP_P(get, null):Bool;

	static function get_UI_UP_P():Bool {
		var key:ControlData = {key1: W, key2: UP};
        return checkStatus(key.key1, JUST_PRESSED) || checkStatus(key.key2, JUST_PRESSED);
	}

    public static var UI_DOWN_P(get, null):Bool;

	static function get_UI_DOWN_P():Bool {
		var key:ControlData = {key1: S, key2: DOWN};
        return checkStatus(key.key1, JUST_PRESSED) || checkStatus(key.key2, JUST_PRESSED);
	}

    public static var UI_LEFT_P(get, null):Bool;

	static function get_UI_LEFT_P():Bool {
		var key:ControlData = {key1: A, key2: LEFT};
        return checkStatus(key.key1, JUST_PRESSED) || checkStatus(key.key2, JUST_PRESSED);
	}

    public static var UI_RIGHT_P(get, null):Bool;

	static function get_UI_RIGHT_P():Bool {
		var key:ControlData = {key1: D, key2: RIGHT};
        return checkStatus(key.key1, JUST_PRESSED) || checkStatus(key.key2, JUST_PRESSED);
	}

    public static var BACK_P(get, null):Bool;

	static function get_BACK_P():Bool {
		var key:ControlData = {key1: BACKSPACE, key2: ESCAPE};
        return checkStatus(key.key1, JUST_PRESSED) || checkStatus(key.key2, JUST_PRESSED);
	}

    public static var ACCEPT_P(get, null):Bool;

	static function get_ACCEPT_P():Bool {
		var key:ControlData = {key1: ENTER, key2: SPACE};
        return checkStatus(key.key1, JUST_PRESSED) || checkStatus(key.key2, JUST_PRESSED);
	}

    public static var PAUSE_P(get, null):Bool;

	static function get_PAUSE_P():Bool {
		var key:ControlData = {key1: ENTER, key2: NONE};
        return checkStatus(key.key1, JUST_PRESSED) || checkStatus(key.key2, JUST_PRESSED);
	}

    // pressed
    public static var UI_UP(get, null):Bool;

	static function get_UI_UP():Bool {
		var key:ControlData = {key1: W, key2: UP};
        return checkStatus(key.key1, PRESSED) || checkStatus(key.key2, PRESSED);
	}

    public static var UI_DOWN(get, null):Bool;

	static function get_UI_DOWN():Bool {
		var key:ControlData = {key1: S, key2: DOWN};
        return checkStatus(key.key1, PRESSED) || checkStatus(key.key2, PRESSED);
	}

    public static var UI_LEFT(get, null):Bool;

	static function get_UI_LEFT():Bool {
		var key:ControlData = {key1: A, key2: LEFT};
        return checkStatus(key.key1, PRESSED) || checkStatus(key.key2, PRESSED);
	}

    public static var UI_RIGHT(get, null):Bool;

	static function get_UI_RIGHT():Bool {
		var key:ControlData = {key1: D, key2: RIGHT};
        return checkStatus(key.key1, PRESSED) || checkStatus(key.key2, PRESSED);
	}

    public static var BACK(get, null):Bool;

	static function get_BACK():Bool {
		var key:ControlData = {key1: BACKSPACE, key2: ESCAPE};
        return checkStatus(key.key1, PRESSED) || checkStatus(key.key2, PRESSED);
	}

    public static var ACCEPT(get, null):Bool;

	static function get_ACCEPT():Bool {
		var key:ControlData = {key1: ENTER, key2: SPACE};
        return checkStatus(key.key1, PRESSED) || checkStatus(key.key2, PRESSED);
	}

    public static var PAUSE(get, null):Bool;

	static function get_PAUSE():Bool {
		var key:ControlData = {key1: ENTER, key2: NONE};
        return checkStatus(key.key1, PRESSED) || checkStatus(key.key2, PRESSED);
	}
    
    // check status function
    static function checkStatus(key:Null<FlxKey>, state:FlxInputState) {
        if(key == null || key == FlxKey.NONE) return false;
        return FlxG.keys.checkStatus(key, state);
    }
}
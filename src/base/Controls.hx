package base;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;

class Controls {
    public static var list:Map<String, Array<FlxKey>> = [
        "ui_left"  => [A, LEFT],
        "ui_down"  => [S, DOWN],
        "ui_up"    => [W, UP],
        "ui_right" => [D, RIGHT],

        "accept"   => [ENTER, SPACE],
        "pause"    => [ENTER, NONE],
        "back"     => [BACKSPACE, ESCAPE],
    ];

    public static function get(name:String) {
        var state:FlxInputState = PRESSED;
        if(list[name][1] == FlxKey.NONE) return FlxG.keys.checkStatus(list[name][0], state);
        return FlxG.keys.checkStatus(list[name][0], state) || FlxG.keys.checkStatus(list[name][1], state);
    }

    public static function getP(name:String) {
        var state:FlxInputState = JUST_PRESSED;
        if(list[name][1] == FlxKey.NONE) return FlxG.keys.checkStatus(list[name][0], state);
        return FlxG.keys.checkStatus(list[name][0], state) || FlxG.keys.checkStatus(list[name][1], state);
    }

    public static function getR(name:String) {
        var state:FlxInputState = JUST_RELEASED;
        if(list[name][1] == FlxKey.NONE) return FlxG.keys.checkStatus(list[name][0], state);
        return FlxG.keys.checkStatus(list[name][0], state) || FlxG.keys.checkStatus(list[name][1], state);
    }
}
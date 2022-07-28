package systems;

import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;

class UIControls
{
    public static var controls:Map<String, Array<FlxKey>> = [
        "LEFT"        => [A, LEFT],
        "DOWN"        => [S, DOWN],
        "UP"          => [W, UP],
        "RIGHT"       => [D, RIGHT],

        "BACK"        => [ESCAPE, BACKSPACE],
        "ACCEPT"      => [SPACE, ENTER],
        "PAUSE"       => [ESCAPE, ENTER],
        "RESET"       => [R, NONE],
    ];

    public static function justPressed(key:String)
    {
        var state = FlxInputState.JUST_PRESSED;
        if(controls[key][1] != NONE)
            return FlxG.keys.checkStatus(controls[key][0], state) || FlxG.keys.checkStatus(controls[key][1], state);
        else
            return FlxG.keys.checkStatus(controls[key][0], state);
    }

    public static function pressed(key:String)
    {
        var state = FlxInputState.PRESSED;
        if(controls[key][1] != NONE)
            return FlxG.keys.checkStatus(controls[key][0], state) || FlxG.keys.checkStatus(controls[key][1], state);
        else
            return FlxG.keys.checkStatus(controls[key][0], state);
    }

    public static function justReleased(key:String)
    {
        var state = FlxInputState.JUST_RELEASED;
        if(controls[key][1] != NONE)
            return FlxG.keys.checkStatus(controls[key][0], state) || FlxG.keys.checkStatus(controls[key][1], state);
        else
            return FlxG.keys.checkStatus(controls[key][0], state);
    }

    public static function released(key:String)
    {
        var state = FlxInputState.RELEASED;
        if(controls[key][1] != NONE)
            return FlxG.keys.checkStatus(controls[key][0], state) || FlxG.keys.checkStatus(controls[key][1], state);
        else
            return FlxG.keys.checkStatus(controls[key][0], state);
    }
}
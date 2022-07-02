package funkin.systems;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

/**
    A class for checking the state of UI Controls.
**/
class UIControls
{
    static public var controlsList:Map<String, Array<FlxKey>> = [
        "LEFT"       => [A, LEFT],
        "DOWN"       => [S, DOWN],
        "UP"         => [W, UP],
        "RIGHT"      => [D, RIGHT],

        "RESET"      => [R, NONE],
        "ACCEPT"     => [ENTER, SPACE],
        "BACK"       => [BACKSPACE, ESCAPE],
        "PAUSE"      => [ENTER, ESCAPE],

		"MUTE"       => [NUMPADZERO, ZERO],
        "VOL_UP"     => [NUMPADPLUS, PLUS],
        "VOL_DOWN"   => [NUMPADMINUS, MINUS],
    ];

    /**
        Check if a control was just pressed.

        @param key       The control/key to check.
    **/
    static public function justPressed(key:String)
    {
        var result:Bool = false;
        var keys:Array<FlxKey> = controlsList.get(key);

        for(key in keys)
        {
            if(key != NONE && FlxG.keys.checkStatus(key, JUST_PRESSED))
                result = true;
        }

        return result;
    }

    /**
        Check if a control is pressed.

        @param key       The control/key to check.
    **/
    static public function pressed(key:String)
    {
        var result:Bool = false;
        var keys:Array<FlxKey> = controlsList.get(key);

        for(key in keys)
        {
            if(key != NONE && FlxG.keys.checkStatus(key, PRESSED))
                result = true;
        }

        return result;
    }

    /**
        Check if a control was just released.

        @param key       The control/key to check.
    **/
    static public function justReleased(key:String)
    {
        var result:Bool = false;
        var keys:Array<FlxKey> = controlsList.get(key);

        for(key in keys)
        {
            if(key != NONE && FlxG.keys.checkStatus(key, JUST_RELEASED))
                result = true;
        }

        return result;
    }

    /**
        Check if a control is released.

        @param key       The control/key to check.
    **/
    static public function released(key:String)
    {
        var result:Bool = false;
        var keys:Array<FlxKey> = controlsList.get(key);

        for(key in keys)
        {
            if(key != NONE && FlxG.keys.checkStatus(key, RELEASED))
                result = true;
        }

        return result;
    }
}
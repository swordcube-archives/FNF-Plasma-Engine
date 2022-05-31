package;

import flixel.FlxG;
import flixel.FlxState;

class States
{
    public static function switchState(curState:FlxState, newState:FlxState, ?skipTransition:Bool = false)
    {
        Main.curState = Type.getClass(newState);
        FlxG.switchState(newState);
    }
}
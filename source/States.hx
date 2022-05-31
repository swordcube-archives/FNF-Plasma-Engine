package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import substates.FNFTransition;

class States
{
    public static function switchState(curState:FlxState, newState:FlxState, ?skipTransition:Bool = false)
    {
        Main.curState = Type.getClass(newState);
        FlxTransitionableState.skipNextTransOut = skipTransition;
		if(!skipTransition)
        {
            curState.openSubState(new FNFTransition(0.8, false));
            FNFTransition.finishCallback = function() {
                FlxG.switchState(newState);
            };
            return trace('changed state');
        }
        FlxG.switchState(newState);
    }
}
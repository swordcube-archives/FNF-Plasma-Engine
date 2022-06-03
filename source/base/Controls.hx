package base;

import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import haxe.ds.StringMap;

@:enum abstract ControlType(String) to String
{
    var UI = 'ui';
	var GAME = 'game';
}

class Controls
{
    public static var uiControls:StringMap<Array<FlxKey>> = [
        "UI_LEFT"   => [A, LEFT],
        "UI_DOWN"   => [S, DOWN],
        "UI_UP"     => [W, UP],
        "UI_RIGHT"  => [D, RIGHT],
        "RESET"     => [R, NONE],
        "ACCEPT"    => [ENTER, SPACE],
        "BACK"      => [BACKSPACE, ESCAPE],
        "PAUSE"     => [ENTER, ESCAPE],

        "MUTE"      => [NUMPADZERO, ZERO],
        "VOL_UP"    => [NUMPADPLUS, PLUS],
        "VOL_DOWN"  => [NUMPADMINUS, MINUS],
    ];

    public static var gameControls:StringMap<Array<Array<FlxKey>>> = [
        "1_key"     => [[SPACE], [SPACE]],
        "2_key"     => [[A, D], [LEFT, RIGHT]],
        "3_key"     => [[A, SPACE, D], [LEFT, SPACE, RIGHT]],
        "4_key"     => [[A, S, W, D], [LEFT, DOWN, UP, RIGHT]],
        "5_key"     => [[A, S, SPACE, W, D], [LEFT, DOWN, SPACE, UP, RIGHT]],
        "6_key"     => [[S, D, F, J, K, L], [S, D, F, J, K, L]],
        "7_key"     => [[S, D, F, SPACE, J, K, L], [S, D, F, SPACE, J, K, L]],
        "8_key"     => [[A, S, D, F, H, J, K, L], [A, S, D, F, H, J, K, L]],
        "9_key"     => [[A, S, D, F, SPACE, H, J, K, L], [A, S, D, F, SPACE, H, J, K, L]],
    ];

    public static var defaultControls:Array<Dynamic> = [];

    public static function init()
    {
        defaultControls.push(uiControls);
        defaultControls.push(gameControls);

        if(FlxG.save.data.uiControls != null)
        {
            uiControls = FlxG.save.data.uiControls;

            var controls:StringMap<Array<FlxKey>> = defaultControls[0];
            for(key in controls.keys())
            {
                if(uiControls.get(key) == null)
                    uiControls.set(key, controls.get(key));
            }
        }
        else
            saveUIControls(defaultControls[0]);

        if(FlxG.save.data.gameControls != null)
        {
            gameControls = FlxG.save.data.gameControls;

            var controls:StringMap<Array<Array<FlxKey>>> = defaultControls[1];
            for(key in controls.keys())
            {
                if(gameControls.get(key) == null)
                    gameControls.set(key, controls.get(key));
            }
        }
        else
            saveGameControls(defaultControls[1]);
    }

    public static function saveUIControls(param:Dynamic = null)
    {
        if(param != null)
        {
            FlxG.save.data.uiControls = param;
            FlxG.save.flush();
        }
        else
        {
            FlxG.save.data.uiControls = uiControls;
            FlxG.save.flush();
        }
    }

    public static function saveGameControls(param:Dynamic = null)
    {
        if(param != null)
        {
            FlxG.save.data.gameControls = param;
            FlxG.save.flush();
        }
        else
        {
            FlxG.save.data.gameControls = gameControls;
            FlxG.save.flush();
        }
    }
    
    public static function isPressed(key:String, state:FlxInputState = JUST_PRESSED)
    {
        var key0 = uiControls.get(key)[0];
        var key1 = uiControls.get(key)[1];

        var key0Value = false;
        if(key0 != NONE)
            key0Value = FlxG.keys.checkStatus(key0, state);

        var key1Value = false;
        if(key1 != NONE)
            key1Value = FlxG.keys.checkStatus(key1, state);
        
        var pressed:Array<Bool> = [
            key0Value,
            key1Value,
        ];

        if(pressed[0])
            return pressed[0];

        if(pressed[1])
            return pressed[1];

        return false;
    }
}
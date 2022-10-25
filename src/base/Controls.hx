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

    /**
     * The list of keybinds for gameplay.
     */
    public static var gameplayList:Map<Int, Array<String>> = [
        1  => ["A"],
        2  => ["A", "D"],
        3  => ["D", "SPACE", "K"],
        4  => ["D", "F", "J", "K"],
    ];

    /**
     * Loads your controls from save data.
     */
    public static function init() {
        // Initialize miscellaneous keybinds
        for(k=>s in list) {
            var reflectGet = Reflect.getProperty(FlxG.save.data, k);
            if(reflectGet != null)
                list[k] = reflectGet;
            else {
                Reflect.setProperty(FlxG.save.data, k, s);
                FlxG.save.flush();
            }
        }
        // Initialize gameplay keybinds
        for(k=>s in gameplayList) {
            var reflectGet = Reflect.getProperty(FlxG.save.data, "gameplayBinds_"+k);
            if(reflectGet != null)
                gameplayList[k] = reflectGet;
            else {
                Reflect.setProperty(FlxG.save.data, "gameplayBinds_"+k, s);
                FlxG.save.flush();
            }
        }
    }

    /**
     * Saves all controls to the disk to be loaded when opening the game.
     */
     public static function flush() {
        for(k=>s in list)
            Reflect.setProperty(FlxG.save.data, k, s);
        for(k=>s in gameplayList)
            Reflect.setProperty(FlxG.save.data, "gameplayBinds_"+k, s);
        FlxG.save.flush();
    }

    /**
     * Return if a control with the name of `name` is currently pressed.
     * @param name The control to check.
     */
    public static function get(name:String) {
        var state:FlxInputState = PRESSED;
		if(list[name][0] == FlxKey.NONE) return false;
        if(list[name][1] == FlxKey.NONE) return FlxG.keys.checkStatus(list[name][0], state);
        return FlxG.keys.checkStatus(list[name][0], state) || FlxG.keys.checkStatus(list[name][1], state);
    }

    /**
     * Return if a control with the name of `name` was just pressed.
     * @param name The control to check.
     */
    public static function getP(name:String) {
        var state:FlxInputState = JUST_PRESSED;
		if(list[name][0] == FlxKey.NONE) return false;
        if(list[name][1] == FlxKey.NONE) return FlxG.keys.checkStatus(list[name][0], state);
        return FlxG.keys.checkStatus(list[name][0], state) || FlxG.keys.checkStatus(list[name][1], state);
    }

    /**
     * Return if a control with the name of `name` was just released.
     * @param name The control to check.
     */
    public static function getR(name:String) {
        var state:FlxInputState = JUST_RELEASED;
        if(list[name][1] == FlxKey.NONE) return FlxG.keys.checkStatus(list[name][0], state);
        return FlxG.keys.checkStatus(list[name][0], state) || FlxG.keys.checkStatus(list[name][1], state);
    }
}
package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Preferences
{
    public static var binds4k:Array<Array<FlxKey>> = [
        [A, S, W, D],
        [LEFT, DOWN, UP, RIGHT],
    ];

    public static var downScroll:Bool = false;
    public static var centeredNotes:Bool = false;

    public static var antiAliasing:Bool = true;

    public static var opaqueSustains:Bool = false;

    public static function init()
    {
        FlxG.save.bind("swordcube", "genesis-options");

        if(FlxG.save.data.volume != null)
            FlxG.sound.volume = FlxG.save.data.volume;
        
        initOption("binds4k");
        initOption("downScroll");
        initOption("centeredNotes");
        initOption("antiAliasing");
        initOption("opaqueSustains");
    }

    public static function initOption(option:String)
    {
        var saveData:Dynamic = Reflect.getProperty(FlxG.save.data, option);
        if(saveData != null)
            Reflect.setProperty(Preferences, option, saveData);
        else
        {
            Reflect.setProperty(FlxG.save.data, option, Reflect.getProperty(Preferences, option));
            FlxG.save.flush();
        }
    }

    public static function getOption(option:String):Dynamic
        return Reflect.getProperty(Preferences, option);
}
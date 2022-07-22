package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.typeLimit.OneOfTwo;

class Preferences
{
    public static var options:Map<String, Dynamic> = [
        // Keybinds
        "binds4k"        => [
            [A, S, W, D],
            [LEFT, DOWN, UP, RIGHT],
        ],

        // Options
        "downScroll"     => false,
        "centeredNotes"  => false,
        "antiAliasing"   => false,
        "opaqueSustains" => false,
    ];

    // Functions
    public static function init()
    {
        FlxG.save.bind("swordcube", "genesis-options");

        if(FlxG.save.data.volume != null)
            FlxG.sound.volume = FlxG.save.data.volume;
        
        for(option in options.keys())
        {
            if(Reflect.getProperty(FlxG.save.data, option) == null)
            {
                Reflect.setProperty(FlxG.save.data, option, options[option]);
                FlxG.save.flush();
            }
            else
                options[option] = Reflect.getProperty(FlxG.save.data, option);
        }
    }

    public static function getOption(option:String):Dynamic
    {
        if(options.exists(option))
            return options[option];
        
        return null;
    }

    public static function setOption(option:String, value:Dynamic)
    {
        options[option] = value;
        Reflect.setProperty(FlxG.save.data, option, value);
        FlxG.save.flush();
    }
}
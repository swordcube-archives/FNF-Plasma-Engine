package;

import base.MusicBeat.MusicBeatState;
import flixel.FlxG;
import flixel.FlxState;
import haxe.ds.StringMap;

/**
	A class that initializes stuff, runs before the game starts.
    If you need something to get set before the game starts, Try going here first.
**/
class Init extends MusicBeatState
{
    // Key Name = Save Data Key
    // Value = The data used for the Options Menu
	public static var options:StringMap<StringMap<Option>> = [
        "Preferences" => [
            "downscroll" => new Option(
                BOOL,
                "Downscroll",
                "Choose whether to have the strumline vertically flipped in gameplay or not.",
                false
            ),
            "centered-notes" => new Option(
                BOOL,
                "Centered Notes",
                "Centers all notes and hides your opponent's notes.",
                false
            ),
            "ghost-tapping" => new Option(
                BOOL,
                "Ghost Tapping",
                "Allows you to press non-existent notes.",
                true
            ),
            "botplay" => new Option(
                BOOL,
                "Botplay",
                "Let the game play itself! Useful for showcases or for skill issues.",
                false
            ),
            "auto-pause" => new Option(
                BOOL,
                "Auto Pause",
                "Choose whether or not to pause the game automatically if the window is unfocused.",
                true
            ),
        ],

        "Appearance" => [
            "anti-aliasing" => new Option(
                BOOL,
                "Anti-Aliasing",
                "Makes every image on screen smoother except for pixel art images.\nDisable for a small performance boost.",
                true
            ),
            "fps-counter" => new Option(
                BOOL,
                "FPS Counter",
                "Choose whether or not to display your FPS at the top left.",
                true
            ),
            "memory-counter" => new Option(
                BOOL,
                "Memory Counter",
                "Choose whether or not to display your memory usage at the top left.",
                true
            ),
            "disable-note-splashes" => new Option(
                BOOL,
                "Disable Note Splashes",
                "Choose whether or not to disable note splashes during gameplay.\nUseful if you find these to be distracting.",
                true
            ),
            "clip-style" => new Option(
                ARRAY,
                "Clip Style",
                "Chooses a style for hold note clippings\nStepMania: Holds under Receptors - FNF: Holds over receptors.",
                "FNF",
                null,
                null,
                ["FNF", "StepMania"]
            ),
        ]
    ];

    public static function getOption(key:String):Dynamic
    {
        var saveData:Dynamic = Reflect.getProperty(FlxG.save.data, key);
        if(saveData != null)
            return saveData;

        trace("save data: " + key + " couldn't be found, returning null");
        return null;
    }

    public static function setOption(key:String, value:Dynamic)
    {
        Reflect.setProperty(FlxG.save.data, key, value);
        FlxG.save.flush();
    }

    override public function create()
    {
        FlxG.save.bind("genesis-options");

        if(FlxG.save.data.volume != null)
            FlxG.sound.volume = FlxG.save.data.volume;

        // Initialize options
        for(_key in options.keys())
        {
            for(key in options.get(_key).keys())
            {
                trace("KEY DETECTED: " + key);
                
                if(Reflect.getProperty(FlxG.save.data, key) == null)
                    Reflect.setProperty(FlxG.save.data, key, options.get(_key).get(key).defaultValue);
            }
        }

        GenesisAssets.init();
        FlxG.autoPause = Init.getOption("auto-pause");
        States.switchState(this, new states.TitleState(), true);
    }
}

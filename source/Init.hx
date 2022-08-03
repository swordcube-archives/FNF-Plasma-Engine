package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import systems.ExtraKeys;
import systems.Highscore;
import systems.MusicBeat;

enum SettingType {
    Checkbox;
    Selector;
    Number;
    KeybindMenu;
}

typedef OptionData = {
    var page:String;
    var name:String;
    var description:String;
    var type:SettingType;
    var defaultValue:Dynamic;
    var ?values:Null<Array<Dynamic>>;
    var ?valueMult:Float;
    var ?decimals:Int;
};

/**
    This is an initialization class to run things before the game starts.

    If you need to do something before the game reaches TitleState, do it here.
**/
class Init extends MusicBeatState
{
    // I kinda wanna add softcoded options at some point.
    // That would be like
    // Cool
    
    /**
        Add custom settings here!

        Use Init.trueSettings.get("Option Name") to use your option in other states and hx or hxs files.
    **/
    public static var settings:Array<OptionData> = [
        // preferences tab
        {
            page: "Preferences",
            name: "Downscroll",
            description: "Makes your notes scroll downwards instead of upwards.",
            type: Checkbox,
            defaultValue: false
        },
        {
            page: "Preferences",
            name: "Centered Notes",
            description: "Makes your notes centered and hides the opponent's notes.",
            type: Checkbox,
            defaultValue: false
        },
        {
            page: "Preferences",
            name: "Ghost Tapping",
            description: "Allows you to hit notes that don't exist.",
            type: Checkbox,
            defaultValue: true
        },
        {
            page: "Preferences",
            name: "Botplay",
            description: "Makes the game play itself for you.",
            type: Checkbox,
            defaultValue: false
        },
        {
            page: "Preferences",
            name: "Preload Assets",
            description: "Preloads assets like images, music, and sounds to load into songs faster. (Enabling this option uses more memory)",
            type: Checkbox,
            defaultValue: false
        },
        {
            page: "Preferences",
            name: "Note Offset",
            description: "Change how early or late your notes spawn. (Negative = Earlier, Positive = Later)",
            type: Number,
            defaultValue: 0,
            values: [-1000, 1000],
            valueMult: 0.05,
            decimals: 2
        },
        {
            page: "Preferences",
            name: "Scroll Speed",
            description: "Change how fast the notes go on screen. (In seconds)",
            type: Number,
            defaultValue: 0,
            values: [0, 10],
            valueMult: 0.1,
            decimals: 1
        },

        // appearance tab
        {
            page: "Appearance",
            name: "Photosensitive Mode",
            description: "Disables photosensitive content such as flashing lights. (May not work on some mods!)",
            type: Checkbox,
            defaultValue: false
        },
        {
            page: "Appearance",
            name: "Antialiasing",
            description: "Gives the game extra performance at the cost of worse looking graphics.",
            type: Checkbox,
            defaultValue: true
        },
        {
            page: "Appearance",
            name: "Opaque Strums",
            description: "Makes the strums opaque instead of transparent.",
            type: Checkbox,
            defaultValue: false
        },
        {
            page: "Appearance",
            name: "Opaque Sustains",
            description: "Makes sustains opaque instead of transparent.",
            type: Checkbox,
            defaultValue: false
        },
        {
            page: "Appearance",
            name: "Note Splashes",
            description: "Makes a firework effect appear when you hit a \"SiCK!!\" note.",
            type: Checkbox,
            defaultValue: true
        },
        {
            page: "Appearance",
            name: "Arrow Skin",
            description: "Change the skin your arrows use.",
            type: Selector,
            defaultValue: "Arrows",
            values: ["Arrows", "Quant", "Circles", "Quant Circles"]
        },

        // controls menu
        {
            page: "Controls",
            name: "1k Keybinds",
            description: "Change your singular keybind for 1k.",
            type: KeybindMenu,
            defaultValue: null,
        },
        {
            page: "Controls",
            name: "2k Keybinds",
            description: "Change your keybinds for 2k.",
            type: KeybindMenu,
            defaultValue: null,
        },
        {
            page: "Controls",
            name: "3k Keybinds",
            description: "Change your keybinds for 3k.",
            type: KeybindMenu,
            defaultValue: null,
        },
        {
            page: "Controls",
            name: "4k Keybinds",
            description: "Change your keybinds for 4k.",
            type: KeybindMenu,
            defaultValue: null,
        },
        {
            page: "Controls",
            name: "5k Keybinds",
            description: "Change your keybinds for 5k.",
            type: KeybindMenu,
            defaultValue: null,
        },
        {
            page: "Controls",
            name: "6k Keybinds",
            description: "Change your keybinds for 6k.",
            type: KeybindMenu,
            defaultValue: null,
        },
        {
            page: "Controls",
            name: "7k Keybinds",
            description: "Change your keybinds for 7k.",
            type: KeybindMenu,
            defaultValue: null,
        },
        {
            page: "Controls",
            name: "8k Keybinds",
            description: "Change your keybinds for 8k.",
            type: KeybindMenu,
            defaultValue: null,
        },
        {
            page: "Controls",
            name: "9k Keybinds",
            description: "Change your keybinds for 9k.",
            type: KeybindMenu,
            defaultValue: null,
        },
    ];

    public static var trueSettings:Map<String, Dynamic> = [];

    /**
        Put keybinds for extra keys here!
        Go to systems/ExtraKeys.hx to make info for your extra keys.
    **/
    public static var keyBinds:Array<Array<FlxKey>> = [
        [SPACE], // 1k
        [LEFT, RIGHT], // 2k
        [LEFT, SPACE, RIGHT], // 3k
        [LEFT, DOWN, UP, RIGHT], // 4k
        [LEFT, DOWN, SPACE, UP, RIGHT], // 5k
        [S, D, F, J, K, L], // 6k
        [S, D, F, SPACE, J, K, L], // 7k
        [A, S, D, F, H, J, K, L], // 8k
        [A, S, D, F, SPACE, H, J, K, L], // 9k
    ];

    /**
        Go to systems/ExtraKeys.hx to change the default arrow colors for each keycount.
    **/
    public static var arrowColors:Map<Int, Array<Array<Int>>> = [];

    override function create()
    {
        super.create();

        // Bind save data to something apart from flixel.sol
        FlxG.save.bind("plasma-engine", "plasma-options");

        // Set the volume to the one from save data
        if(FlxG.save.data.volume != null)
            FlxG.sound.volume = FlxG.save.data.volume;

        // Initialize highscore
        Highscore.init();

        initializeSettings();

		FlxG.mouse.useSystemCursor = true; // Makes the game use the system cursor because it looks nicer.
		FlxG.mouse.visible = false;        // Hide the mouse cursor by default.
		FlxG.fixedTimestep = false;        // Makes the game not run dependent of FPS.

        FlxG.keys.preventDefaultKeys = [TAB]; // Prevents tab from unfocusing the game.

        // Start the game
        if(trueSettings.get("Preload Assets"))
            Main.switchState(new states.PreloadState(), false);
        else
            Main.switchState(new states.TitleState(), false);
    }

    /**
        Initialize all settings.
    **/
    function initializeSettings()
    {
        for(setting in settings)
        {
            if(Reflect.getProperty(FlxG.save.data, setting.name) != null)
            {
                trueSettings.set(setting.name, Reflect.getProperty(FlxG.save.data, setting.name));
                trace('INITIALIZED ${setting.name}!');
            }
            else
            {
                Reflect.setProperty(FlxG.save.data, setting.name, setting.defaultValue);
                FlxG.save.flush();

                trueSettings.set(setting.name, setting.defaultValue);
                trace('${setting.name} has been added to save data!');
            }
        }
        
        for(i in 0...ExtraKeys.arrowInfo.length)
        {
            if(Reflect.getProperty(FlxG.save.data, "arrowColors"+(i+1)+"k") != null)
            {
                arrowColors.set(i, Reflect.getProperty(FlxG.save.data, "arrowColors"+(i+1)+"k"));
                trace('INITIALIZED ARROW COLORS FOR ${i+1}k!');
            }
            else
            {
                Reflect.setProperty(FlxG.save.data, "arrowColors"+(i+1)+"k", ExtraKeys.arrowInfo[i][1]);
                FlxG.save.flush();

                arrowColors.set(i, ExtraKeys.arrowInfo[i][1]);
                trace('${i}k arrow colors have been added to save data!');
            }
        }

        if(FlxG.save.data.keyBinds != null)
            keyBinds = FlxG.save.data.keyBinds;
        else
        {
            FlxG.save.data.keyBinds = keyBinds;
            FlxG.save.flush();
        }
    }

    /**
        Saves all settings. (Don't call this function if you want to change an option temporarily.)
    **/
    public static function saveSettings()
    {
        for(setting in trueSettings.keys())
        {
            Reflect.setProperty(FlxG.save.data, setting, trueSettings.get(setting));
            FlxG.save.flush();
            trace('$setting SAVED!');
        }
        FlxG.save.data.keyBinds = keyBinds;
        trace('SAVED KEYBINDS!');

        for(i in 0...ExtraKeys.arrowInfo.length)
        {
            Reflect.setProperty(FlxG.save.data, "arrowColors"+(i+1)+"k", arrowColors.get(i));
            FlxG.save.flush();
        }
        trace('SAVED ARROW COLORS!');

        trace('ALL SETTINGS SAVED!');
    }
}
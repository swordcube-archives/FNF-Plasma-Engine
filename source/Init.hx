package;

import gameplay.StrumNote.ArrowSkin;
import sys.io.File;
import haxe.Json;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import states.ScriptedState;
import systems.ExtraKeys;
import systems.Highscore;
import systems.MusicBeat;
import sys.FileSystem;

using StringTools;

// rip SettingType 2022-2022, you will be missed :(((
// enum SettingType {
//     Checkbox;
//     Selector;
//     Number;
//     KeybindMenu;
// }

typedef DiscordRPCConfig = {
    var clientID:String;
    var largeImageKey:String;
    var largeImageText:String;
};

typedef OptionData = {
    var page:String;
    var name:String;
    var ?saveData:Null<String>;
    var description:String;
    var type:String;
    var defaultValue:Dynamic;
    var ?values:Null<Array<Dynamic>>;
    var ?valueMult:Null<Float>;
    var ?decimals:Null<Int>;
};

/**
    This is an initialization class to run things before the game starts.

    If you need to do something before the game reaches TitleState, do it here.
**/
class Init extends MusicBeatState {
    // I kinda wanna add softcoded options at some point.
    // That would be like
    // Cool
    
    /**
        Add custom settings here!

        Use Settings.get("Option Name") to use your options.
    **/
    public static var settings:Array<OptionData> = [];
    public static var settingPages:Array<Array<String>> = [];

    public static var trueSettings:Map<String, Dynamic> = [];

    public static var startedGame:Bool = false;

    public static var arrowSkins:Map<String, ArrowSkin> = [];

    public static var logs:Array<Dynamic> = [];

    /**
        Put keybinds for extra keys here!
        Go to systems/ExtraKeys.hx to make info for your extra keys.
    **/
    public static var keyBinds:Array<Array<FlxKey>> = [
        [SPACE], // 1k
        [LEFT, RIGHT], // 2k
        [D, SPACE, K], // 3k
        [LEFT, DOWN, UP, RIGHT], // 4k
        [D, F, SPACE, J, K], // 5k
        [S, D, F, J, K, L], // 6k
        [S, D, F, SPACE, J, K, L], // 7k
        [A, S, D, F, H, J, K, L], // 8k
        [A, S, D, F, SPACE, H, J, K, L], // 9k
    ];

    /**
        Go to systems/ExtraKeys.hx to change the default arrow colors for each keycount.
    **/
    public static var arrowColors:Map<Int, Array<Array<Int>>> = [];

    public static function getArrowSkins():Map<String, ArrowSkin>
    {
        var a:Map<String, ArrowSkin> = [];
        for(folder in FileSystem.readDirectory('${AssetPaths.cwd}assets'))
        {
            if(!folder.contains("."))
            {
                var p:String = '${AssetPaths.cwd}assets/$folder/images/skins';
                if(FileSystem.exists(p))
                {
                    for(item in FileSystem.readDirectory(p))
                    {
                        if(item.endsWith(".json"))
                            a.set(item.split(".json")[0], Json.parse(FNFAssets.returnAsset(TEXT, '$p/$item')));
                    }
                }
            }
        }
        return a;
    }

    public static function reloadSettings()
    {
        settings = [];
        settingPages = [];

        for(pack in FileSystem.readDirectory('${Sys.getCwd()}assets'))
        {
            if(!pack.contains("."))
            {
                var path:String = '${Sys.getCwd()}assets/${pack}/options.json';
                if(FileSystem.exists(path))
                {
                    var rawJson:Dynamic = Json.parse(File.getContent(path));
                    
                    var json:Array<OptionData> = rawJson.options;
                    for(setting in json)
                        settings.push(setting);

                    if(rawJson.pages != null) {
                        var txt:Array<Array<String>> = rawJson.pages;
                        for(page in txt)
                            settingPages.push(page);
                    }
                }
            }
        }
    }

    override function create()
    {
        super.create();

        reloadSettings();

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
            Main.switchState(new states.ScriptedState('TitleState'), false);

        #if discord_rpc
        var rpcConfig:DiscordRPCConfig = Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json("discordRPC")));
        DiscordRPC.data = rpcConfig;
        DiscordRPC.initialize(rpcConfig.clientID);
        #end
    }

    /**
        Initialize all settings.
    **/
    public static function initializeSettings()
    {
        for(setting in settings)
        {
            var saveDataShit = setting.saveData != null ? setting.saveData : setting.name;
            if(Reflect.getProperty(FlxG.save.data, saveDataShit) != null)
            {
                trueSettings.set(saveDataShit, Reflect.getProperty(FlxG.save.data, saveDataShit));
            }
            else
            {
                Reflect.setProperty(FlxG.save.data, saveDataShit, setting.defaultValue);
                FlxG.save.flush();

                trueSettings.set(saveDataShit, setting.defaultValue);
            }
        }
        
        for(i in 0...ExtraKeys.arrowInfo.length)
        {
            if(Reflect.getProperty(FlxG.save.data, "arrowColors"+(i+1)+"k") != null)
                arrowColors.set(i, Reflect.getProperty(FlxG.save.data, "arrowColors"+(i+1)+"k"));
            else
            {
                Reflect.setProperty(FlxG.save.data, "arrowColors"+(i+1)+"k", ExtraKeys.arrowInfo[i][1]);
                FlxG.save.flush();

                arrowColors.set(i, ExtraKeys.arrowInfo[i][1]);
            }
        }

        if(FlxG.save.data.keyBinds != null)
            keyBinds = FlxG.save.data.keyBinds;
        else
        {
            FlxG.save.data.keyBinds = keyBinds;
            FlxG.save.flush();
        }

        if(FlxG.save.data.currentPack != null)
            AssetPaths.currentPack = FlxG.save.data.currentPack;
        else
        {
            FlxG.save.data.currentPack = AssetPaths.currentPack;
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
            //trace('$setting SAVED!');
        }
        FlxG.save.data.keyBinds = keyBinds;
        //trace('SAVED KEYBINDS!');

        for(i in 0...ExtraKeys.arrowInfo.length)
        {
            Reflect.setProperty(FlxG.save.data, "arrowColors"+(i+1)+"k", arrowColors.get(i));
            FlxG.save.flush();
        }
        //trace('SAVED ARROW COLORS!');

        FlxG.save.data.currentPack = AssetPaths.currentPack;
        FlxG.save.flush();
        //trace('SAVED CURRENTLY SELECTED PACK');

        trace('ALL SETTINGS SAVED!');
    }

    public static function log(type, text) {
        if (logs[logs.length-1] != null && logs[logs.length-1][0] == [type, text]) {
            logs[logs.length-1][1] += 1;
        } else {
            logs.push([[type, text], 1]);
        }
    }
}
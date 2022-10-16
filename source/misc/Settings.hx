package misc;

import funkin.gameplay.Note;

typedef PageData = {
    var title:String;
    var desc:String;
};

typedef SettingData = {
    var page:String;
    var name:String;
    @:optional var saveData:String;
    var desc:String;
    var defaultValue:Dynamic;
    @:optional var values:Array<Dynamic>;
    @:optional var valueMult:Float;
    @:optional var decimals:Int;
    var type:String;
};

class Settings {
    public static var defaultSettings:Array<SettingData> = [];
    public static var defaultPages:Array<PageData> = [];

    public static var noteColors:Map<Int, Array<Array<Int>>> = [];

    public static var settingsMap:Map<String, Dynamic> = [];

    public static function init() {
        var basePath:String = '${Sys.getCwd()}assets/';
        for(folder in FileSystem.readDirectory(basePath)) {
            if(FileSystem.isDirectory(basePath+folder)) {
                if(FileSystem.exists(basePath+folder+"/settings.json")) {
                    var json = Assets.get(JSON, basePath+folder+"/settings.json");
                    var pages:Array<PageData> = json.pages;
                    for(page in pages) {
                        defaultPages.push(page);
                    }
                    var settings:Array<SettingData> = json.settings;
                    for(setting in settings) {
                        defaultSettings.push(setting);
                        var saveData:String = setting.saveData != null ? setting.saveData : setting.name;
                        if(Reflect.getProperty(FlxG.save.data, saveData) != null) {
                            settingsMap.set(saveData, Reflect.getProperty(FlxG.save.data, saveData));
                        } else {
                            settingsMap.set(saveData, setting.defaultValue);
                            Reflect.setProperty(FlxG.save.data, saveData, setting.defaultValue);
                            FlxG.save.flush();
                        }
                    }
                }
            }
        }

        for(i in 0...Note.noteColors.length) {
            if(Reflect.getProperty(FlxG.save.data, "noteColors"+(i+1)+"k") != null)
                noteColors.set(i, Reflect.getProperty(FlxG.save.data, "noteColors"+(i+1)+"k"));
            else {
                Reflect.setProperty(FlxG.save.data, "noteColors"+(i+1)+"k", Note.noteColors[i]);
                FlxG.save.flush();

                noteColors.set(i, Note.noteColors[i]);
            }
        }
    }

    public static function get(setting:String) {
        return settingsMap.get(setting);
    }

    public static function set(setting:String, value:Dynamic) {
        settingsMap.set(setting, value);
    }

    public static function save() {
        for(key in settingsMap.keys()) {
            Reflect.setProperty(FlxG.save.data, key, settingsMap[key]);
        }
        for(i in 0...Note.noteColors.length) {
            Reflect.setProperty(FlxG.save.data, "noteColors"+(i+1)+"k", noteColors[i]);
        }
        FlxG.save.flush();
    }
}
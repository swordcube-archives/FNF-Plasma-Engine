package misc;

import flixel.FlxG;

class Keybinds {
    public static var binds:Map<Int, Array<String>> = [];

    public static function init() {
        var jsonBinds:Array<Array<String>> = Assets.get(JSON, Paths.json("keybinds")).binds;
        for(i in 0...jsonBinds.length) {
            var dumbBinds:Array<String> = jsonBinds[i];
            
            var savedShit = Reflect.getProperty(FlxG.save.data, "keybinds_"+(i+1));
            if(savedShit != null)
                binds[i+1] = savedShit;
            else {
                Reflect.setProperty(FlxG.save.data, "keybinds_"+(i+1), dumbBinds);
                binds[i+1] = dumbBinds;
                FlxG.save.flush();
            }
        }
    }
}
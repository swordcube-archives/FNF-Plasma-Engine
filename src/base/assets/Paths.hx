package base.assets;

class Paths {
    public static var fallbackMod:String = "Friday Night Funkin'";
    public static var currentMod:String = fallbackMod;

    public static var IMAGE_EXT:String = ".png";
    public static var SOUND_EXT:String = ".ogg";

    public static function path(p:String) {
        return '${Sys.getCwd()}$p';
    }
    public static function asset(p:String, ?mod:Null<String>) {
        if(mod == null) mod = currentMod;
        var fart:String = Main.developerMode ? "../../../../" : "";
        var mmm:String = path('${fart}mods/$mod/$p');
        if(!FileSystem.exists(mmm)) mmm = path('${fart}mods/$fallbackMod/$p');
        if(!FileSystem.exists(mmm)) mmm = path('${fart}assets/$p');
        return mmm;
    }

    // Functions for getting paths to code for scripting.
    public static function script(p:String, ?mod:Null<String>) {
        var pathsToCheck:Array<String> = [
            asset('$p.hx', mod),
            asset('$p.hxs', mod),
            asset('$p.hsc', mod),
            asset('$p.hscript', mod),
            asset('$p.lua', mod)
        ];
        for(path in pathsToCheck) {
            if(FileSystem.exists(path)) return path;
        }
        return asset('$p.hxs', mod);
    }
    // Functions for getting paths to Images, Sounds, or Text.
    public static function image(p:String, useRoot:Bool = true, ?mod:Null<String>) {
        var root:String = useRoot ? "images/" : "";
        return asset('$root$p$IMAGE_EXT', mod);
    }
    public static function sound(p:String, ?mod:Null<String>) {
        return asset('sounds/$p$SOUND_EXT', mod);
    }
    public static function songInst(p:String, ?mod:Null<String>) {
        return asset('songs/${p.toLowerCase()}/Inst$SOUND_EXT', mod);
    }
    public static function songVoices(p:String, ?mod:Null<String>) {
        return asset('songs/${p.toLowerCase()}/Voices$SOUND_EXT', mod);
    }
    public static function music(p:String, ?mod:Null<String>) {
        return asset('music/$p$SOUND_EXT', mod);
    }
    public static function json(p:String, ?mod:Null<String>) {
        return asset('$p.json', mod);
    }
    public static function txt(p:String, ?mod:Null<String>) {
        return asset('$p.txt', mod);
    }
    public static function xml(p:String, ?mod:Null<String>) {
        return asset('$p.xml', mod);
    }
    public static function font(p:String, ?mod:Null<String>) {
        return asset('fonts/$p', mod);
    }
    public static function video(p:String, ?mod:Null<String>) {
        if(mod == null) mod = currentMod;
        var mmm:String = 'mods/$mod/videos/$p';
        if(!FileSystem.exists(path(mmm))) mmm = 'mods/$fallbackMod/videos/$p';
        if(!FileSystem.exists(path(mmm))) mmm = 'assets/videos/$p';
        return mmm;
    }
    public static function frag(p:String, ?mod:Null<String>) {
        return asset('data/shaders/$p.frag', mod);
    }
    public static function vert(p:String, ?mod:Null<String>) {
        return asset('data/shaders/$p.vert', mod);
    }
}
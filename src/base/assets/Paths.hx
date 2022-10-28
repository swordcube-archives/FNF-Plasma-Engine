package base.assets;

class Paths {
    public static var IMAGE_EXT:String = ".png";
    public static var SOUND_EXT:String = ".ogg";

    public static function path(p:String) {
        return '${Sys.getCwd()}$p';
    }
    public static function asset(p:String) {
        return path('assets/$p');
    }

    // Functions for getting paths to code for scripting.
    public static function hxs(p:String) {
        var pathsToCheck:Array<String> = [
            asset('$p.hx'),
            asset('$p.hxs'),
            asset('$p.hsc'),
            asset('$p.hscript')
        ];
        for(path in pathsToCheck) {
            if(FileSystem.exists(path)) return path;
        }
        return asset('$p.hxs');
    }
    public static function lua(p:String) {
        return asset('$p.lua');
    }
    // Functions for getting paths to Images, Sounds, or Text.
    public static function image(p:String, useRoot:Bool = true) {
        var root:String = useRoot ? "images/" : "";
        return asset('$root$p$IMAGE_EXT');
    }
    public static function sound(p:String) {
        return asset('sounds/$p$SOUND_EXT');
    }
    public static function songInst(p:String) {
        return asset('songs/${p.toLowerCase()}/Inst$SOUND_EXT');
    }
    public static function songVoices(p:String) {
        return asset('songs/${p.toLowerCase()}/Voices$SOUND_EXT');
    }
    public static function music(p:String) {
        return asset('music/$p$SOUND_EXT');
    }
    public static function json(p:String) {
        return asset('$p.json');
    }
    public static function txt(p:String) {
        return asset('$p.txt');
    }
    public static function xml(p:String) {
        return asset('$p.xml');
    }
    public static function font(p:String) {
        return asset('fonts/$p');
    }
}
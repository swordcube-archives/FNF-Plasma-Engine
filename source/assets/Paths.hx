package assets;

class Paths {
    public static var currentMod:String = "funkin";

    public static var imageExts:Array<String> = [
        ".png",
        ".jpg",
        ".jpeg",
        ".bmp"
    ];

    public static var soundExts:Array<String> = [
        ".ogg",
        ".mp3",
        ".wav"
    ];

    public static function path(p:String, ?mod:Null<String>) {
        if(mod == null) mod = currentMod;
        var pp:String = '${Sys.getCwd()}assets/$mod/$p';
        if(!FileSystem.exists(pp)) pp = '${Sys.getCwd()}assets/funkin/$p';
        return pp;
    }

    public static function json(p:String, ?mod:Null<String>) {
        return path('$p.json', mod);
    }

    public static function frag(p:String, ?mod:Null<String>) {
        return path('$p.frag', mod);
    }

    public static function vert(p:String, ?mod:Null<String>) {
        return path('$p.vert', mod);
    }

    public static function txt(p:String, ?mod:Null<String>) {
        return path('$p.txt', mod);
    }

    public static function xml(p:String, ?mod:Null<String>) {
        return path('$p.xml', mod);
    }

    public static function image(p:String, ?mod:Null<String>, useRootFolder:Bool = true) {
        var basePath:String = useRootFolder ? 'images/' : '';
        for(ext in Paths.imageExts) {
            if(FileSystem.exists(path('$basePath$p$ext')))
                return path('$basePath$p$ext');
        }
        return path('$basePath$p.png', mod);
    }

    public static function sound(p:String, ?mod:Null<String>, useRootFolder:Bool = true) {
        var basePath:String = useRootFolder ? 'sounds/' : '';
        for(ext in Paths.soundExts) {
            if(FileSystem.exists(path('$basePath$p$ext')))
                return path('$basePath$p$ext');
        }
        return path('$basePath$p.ogg', mod);
    }

    public static function music(p:String, ?mod:Null<String>) {
        return sound('music/$p', mod, false);
    }

    public static function songInst(p:String, ?mod:Null<String>) {
        return sound('songs/${p.toLowerCase()}/Inst', mod, false);
    }

    public static function songVoices(p:String, ?mod:Null<String>) {
        return sound('songs/${p.toLowerCase()}/Voices', mod, false);
    }

    public static function video(path:String, ?mod:Null<String>) {
        if(mod == null) mod = currentMod;
        return 'assets/$mod/videos/$path';
    }

    public static function font(p:String, ext:String = ".ttf", ?mod:Null<String>) {
        return path('fonts/$p$ext');
    }
}
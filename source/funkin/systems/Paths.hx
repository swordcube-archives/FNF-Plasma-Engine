package funkin.systems;

import lime.utils.Assets;

using StringTools;

/**
    A class for getting file paths.
**/
class Paths
{
    /**
        A function for returning `path` as `assets/path`.
    **/
    public static function asset(path:String)
        return 'assets/$path';

    /**
        A function for returning `path` as `assets/path.hx`.
    **/
    public static function hx(path:String)
        return asset('$path.hx');

    /**
        A function for returning `character` as `assets/characters/character.png`.
    **/
    public static function characterHX(character:String)
        return hx('characters/$character/script');

    /**
        A function for returning `path` as `assets/images/path.png`.
    **/
    public static function image(path:String)
        return asset('images/$path.png');

    /**
        A function for returning `path` as `assets/music/path.ogg`.
    **/
    public static function music(path:String)
        return asset('music/$path.ogg');

    /**
        A function for returning `path` as `assets/songs/song`.
    **/
    public static function song(song:String)
        return asset('songs/${song.toLowerCase()}');

    /**
        A function for returning `path` as `assets/songs/song/Inst.ogg`.
    **/
    public static function inst(song:String)
        return asset('songs/${song.toLowerCase()}/Inst.ogg');

    /**
        A function for returning `path` as `assets/songs/song/Voices.ogg`.
    **/
    public static function voices(song:String)
        return asset('songs/${song.toLowerCase()}/Voices.ogg');

    /**
        A function for returning `path` as `assets/sounds/path.ogg`.
    **/
    public static function sound(path:String)
        return asset('sounds/$path.ogg');

    /**
        A function for returning `path` as `assets/path.xml`.
    **/
    public static function xml(path:String)
        return asset('$path.xml');

    /**
        A function for returning `path` as `assets/data/path`.
    **/
    public static function data(path:String)
        return asset('data/$path');

    /**
        A function for returning `path` as `assets/path.txt`.
    **/
    public static function txt(path:String)
        return asset('$path.txt');

    /**
        A function for returning `path` as `assets/path.json`.
    **/
    public static function json(path:String)
        return asset('$path.json');

    /**
        A function for returning `font` as `assets/path.ttf` or `assets/path.otf`.
    **/
    public static function font(path:String)
    {
        var ttf:String = asset('fonts/$path.ttf');
        var otf:String = asset('fonts/$path.otf');
        if(exists(otf))
            #if html5
            return openfl.utils.Assets.getFont(otf).fontName;
            #else
            return otf;
            #end

        #if html5
        return openfl.utils.Assets.getFont(ttf).fontName;
        #else
        return ttf;
        #end
    }

    /**
        A function for returning if a file exists or not.
    **/
    public static function exists(path:String)
    {
        #if sys
        return sys.FileSystem.exists('${Sys.getCwd()}$path');
        #else
        return Assets.exists('$path');
        #end
    }
}
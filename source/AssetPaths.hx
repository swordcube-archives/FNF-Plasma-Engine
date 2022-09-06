import FNFAssets;
import flixel.FlxG;
import sys.FileSystem;

using StringTools;

class AssetPaths {
    /**
        The current working directory of the game.
    **/
    public static var cwd:String = Sys.getCwd();

    /**
        The currently loaded mod pack.
    **/
    public static var currentPack:String = "funkin";
    
    /**
        Basically currentPack but it can get overridden by functions with `packOverride` in it.
    **/
    public static var packToUse:String = currentPack;

    /**
        Turns `path` into `assets/somePack/path`

        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function asset(path:String, packOverride:Null<String> = null):String
    {
        if(packOverride != null)
            packToUse = packOverride;
        else
            packToUse = currentPack;

        return '${cwd}assets/${packToUse}/$path';
    }

    /**
        Turns `path` into `replays/path`

        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function replay(path:String):String
        return '${cwd}replays/$path.json';

    /**
        Turns `path` into `assets/somePack/fonts/path.ext` (.ext can be: .ttf or .otf)
        Change `imageExt` to TTF or OTF to change file extension.

        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function font(path:String, fontExt:FontExt = TTF, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('fonts/$path$fontExt', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }

    /**
        Turns `path` into `assets/somePack/path.txt`

        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function txt(path:String, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('$path.txt', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }

    /**
        Turns `path` into `assets/somePack/path.json`
        
        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function json(path:String, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('$path.json', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }

    /**
        Turns `path` into `assets/somePack/path.xml`
        
        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function xml(path:String, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('$path.xml', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }

    /**
        Turns `path` into `assets/somePack/path.hxs`
        
        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function hxs(path:String, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('$path.hxs', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }
    public static function frag(path:String, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('shaders/$path.frag', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }
    public static function vert(path:String, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('shaders/$path.vert', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }

    /**
        Turns `path` into `assets/somePack/images/path.ext` (.ext can be: .png, .jpg, & .bmp)
        Change `imageExt` to PNG, JPG, or BMP to change file extension.

        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function image(path:String, imageExt:ImageExt = PNG, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('images/$path$imageExt', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');
            
        return goodPath;
    }

    /**
        Turns `path` into `assets/somePack/story_characters/char/spritesheet.ext` (.ext can be: .png, .jpg, & .bmp)
        Change `imageExt` to PNG, JPG, or BMP to change file extension.

        @param char                    The character to get the spritesheet path for.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function storyCharacterSpriteSheet(char:String, imageExt:ImageExt = PNG, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('story_characters/$char/spritesheet$imageExt', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }

    /**
        Turns `path` into `assets/somePack/characters/char/spritesheet.ext` (.ext can be: .png, .jpg, & .bmp)
        Change `imageExt` to PNG, JPG, or BMP to change file extension.

        @param char                    The character to get the spritesheet path for.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function characterSpriteSheet(char:String, imageExt:ImageExt = PNG, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('characters/$char/spritesheet$imageExt', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }

    /**
        Turns `path` into `assets/somePack/sound/path.ext` (.ext can be: .ogg, .mp3, & .wav)
        Change `soundExt` to OGG, MP3, or WAV to change file extension.

        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function sound(path:String, soundExt:SoundExt = OGG, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('sounds/$path$soundExt', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }

    /**
        Basically `AssetPaths.sound` but with a random number from `min` to `max` at the end of the `path`.

        @param min                    The minimum number for the random number.
        @param max                    The maximum number for the random number.
    **/
    public static function soundRandom(path:String, min:Int, max:Int, soundExt:SoundExt = OGG, packOverride:Null<String> = null)
	{
		return sound(path + FlxG.random.int(min, max), soundExt, packOverride);
	}

    /**
        Turns `path` into `assets/somePack/music/path.ext` (.ext can be: .ogg, .mp3, & .wav)
        Change `soundExt` to OGG, MP3, or WAV to change file extension.

        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function music(path:String, soundExt:SoundExt = OGG, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('music/$path$soundExt', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }

    /**
        Turns `song` into `assets/somePack/songs/song/Inst.ext` (.ext can be: .ogg, .mp3, & .wav)
        Change `soundExt` to OGG, MP3, or WAV to change file extension.

        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function songInst(song:String, soundExt:SoundExt = OGG, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('songs/${song.toLowerCase()}/Inst$soundExt', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }

    /**
        Turns `song` into `assets/somePack/songs/song/Voices.ext` (.ext can be: .ogg, .mp3, & .wav)
        Change `soundExt` to OGG, MP3, or WAV to change file extension.

        @param path                    The path to convert.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function songVoices(song:String, soundExt:SoundExt = OGG, packOverride:Null<String> = null):String
    {
        var goodPath:String = asset('songs/${song.toLowerCase()}/Voices$soundExt', packOverride);
        if(!FileSystem.exists(goodPath))
            // Try to get the asset from funkin (default pack) if it doesn't exist in current
            goodPath = goodPath.replace('assets/${packToUse}', 'assets/funkin');

        return goodPath;
    }
}

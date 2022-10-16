package funkin;

typedef Song = {
    // Base Song Info
    var song:String;
    var notes:Array<Section>;
    var bpm:Float;

    @:deprecated("`needsVoices` is unused. Please check if the vocals file exists instead.")
    @:optional var needsVoices:Bool;
    
    var speed:Float;
    var keyCount:Null<Int>;
    var keyNumber:Null<Int>; // Used in Yoshi Engine Charts, This is keyCount but under a different name.
    var mania:Null<Int>; // Used for Shaggy Charts

    // Art
    var player1:String;
    var player2:String;

    var gf:Null<String>;
    var gfVersion:Null<String>;

    // An array of paths to scripts
    var scripts:Array<String>;

    // I would add a deprecated message to this but i have to check for this being used in the code
    // So uh no. You still should use gf or gfVersion.
    var player3:Null<String>;

    var stage:Null<String>;
    var events:Array<Array<Dynamic>>;
    // var uiSkin:Null<String>;
}

class SongLoader {
    public static function returnSong(song:String, diff:String = "normal"):Song {
        return returnParsedData(Assets.get(TEXT, Paths.json('songs/${song.toLowerCase()}/$diff')));
    }

    public static function returnParsedData(data:String):Song {
        return tjson.TJSON.parse(data).song;
    }
}
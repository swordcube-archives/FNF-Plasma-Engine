package gameplay;

import haxe.Json;

typedef Song = {
    // Base Song Info
    var song:String;
    var notes:Array<Section>;
    var bpm:Float;

    @:deprecated("`needsVoices` is unused. Please check if the vocals file exists instead.")
    var needsVoices:Bool;
    
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

    //@:deprecated("`player3` is deprecated. Use `gf` or `gfVersion` instead.")
    // you should still not use this, but compatibility + raf hates deprecated messages like i do
    var player3:Null<String>;

    var stage:Null<String>;
    // var uiSkin:Null<String>;
}

class SongLoader {
    public static function getJSON(song:String, diff:String = "normal"):Song
        return Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json('songs/${song.toLowerCase()}/$diff'))).song;
}
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

    // Art
    var player1:String;
    var player2:String;

    var gf:Null<String>;
    var gfVersion:Null<String>;

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
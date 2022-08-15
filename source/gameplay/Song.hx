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

    @:deprecated("`player3` is deprecated. Use `gf` or `gfVersion` instead.")
    var player3:Null<String>;

    var stage:Null<String>;
    // var uiSkin:Null<String>;
}

class SongLoader {
    public static function getJSON(song:String, diff:String = "normal"):Song
    {
        var rawText:String = FNFAssets.returnAsset(TEXT, AssetPaths.json('songs/${song.toLowerCase()}/$diff'));
        return Json.parse(rawText).song;
    }
}
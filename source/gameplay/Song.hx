package gameplay;

import haxe.Json;

typedef Song =
{
    // Base Song Info
    var song:String;
    var notes:Array<Section>;
    var bpm:Float;
    //var needsVoices:Bool; // I think this is kinda useless now isn't it
    var speed:Float;
    var keyCount:Null<Int>;

    // Art
    var player1:String;
    var player2:String;

    var gf:Null<String>;
    var gfVersion:Null<String>;
    var player3:Null<String>;
    
    var stage:Null<String>;
    // var uiSkin:Null<String>;
}

class SongLoader
{
    public static function getJSON(song:String, diff:String = "normal"):Song
    {
        var rawText:String = FNFAssets.returnAsset(TEXT, AssetPaths.json('songs/${song.toLowerCase()}/$diff'));
        return Json.parse(rawText).song;
    }
}
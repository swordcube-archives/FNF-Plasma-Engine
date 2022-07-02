package funkin.game;

import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import haxe.Json;

typedef Song =
{
    // Base Song Info
    var song:String;
    var notes:Array<Section>;
    var bpm:Float;
    var needsVoices:Bool;
    var speed:Float;
    var keyCount:Null<Int>;

    // Art
    var player1:String;
    var player2:String;

    var gf:Null<String>;
    var gfVersion:Null<String>;
    var player3:Null<String>;
    
    var stage:Null<String>;
    var uiSkin:Null<String>;
}

/**
    Typedef for Section Data.
**/
typedef Section =
{
    // The notes for this section.
    var sectionNotes:Array<Dynamic>;
    // Stuff for charting.
    var lengthInSteps:Int;
    var mustHitSection:Bool;
    // Determines if the opponent/player should use alt anims for this section.
    var altAnim:Bool;
    // BPM Stuff
    var bpm:Float;
    var changeBPM:Bool;
}

class SongLoader
{
    public static function getJSON(song:String, diff:String = "normal")
    {
        var rawText:String = FunkinAssets.getText(Paths.json('songs/${song.toLowerCase()}/$diff'));
        return Json.parse(rawText);
    }
}
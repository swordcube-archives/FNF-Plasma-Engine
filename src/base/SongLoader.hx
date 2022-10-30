package base;

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

    // please don't use this use gf or gfVersion instead
    var player3:Null<String>;

    var stage:Null<String>;
}

typedef Section = {
    var sectionNotes:Array<Dynamic>;
    var mustHitSection:Bool;
    var altAnim:Bool;
    
    var bpm:Null<Float>;
    var changeBPM:Null<Bool>;

    var lengthInSteps:Int;

	var timeScale:Array<Int>;
	var changeTimeScale:Bool;
}

/**
 * A class for loading song data.
 */
class SongLoader {
    public static function returnSong(song:String, diff:String = "normal"):Song
        return Json.parse(Assets.load(TEXT, Paths.json('songs/${song.toLowerCase()}/$diff'))).song;
}
package systems;

import sys.io.File;
import haxe.Json;

typedef ReplayNote = {
    var strumTime:Float;
    var noteData:Int;

    var rating:String;
}

typedef ReplayKeyData = {
    var noteData:Int; // fuhnkld
    var status:Int; // 0 = Just Pressed, 1 = Just Released
    var time:Float; // The time the key was pressed or whatever
};

typedef ReplayData = {
    var packUsed:String;

    var keyData:Array<ReplayKeyData>;
    var notes:Array<ReplayNote>;

    var difficulty:String;
};

class Replay
{
    public static function loadReplay(path:String):ReplayData
        return Json.parse(File.getContent(AssetPaths.replay(path)));

    public static function saveReplay(path:String, data:ReplayData)
        File.saveContent(AssetPaths.replay(path), Json.stringify(data, "\t"));
}
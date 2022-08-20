package systems;

import sys.io.File;
import haxe.Json;

typedef ReplayNote = {
    var strumTime:Float;
    var noteData:Int;

    var msTime:Float;
}

typedef ReplayKeyData = {
    var status:Int; // 0 = Just Pressed, 1 = Pressed, 2 = Just Released
    var time:Float; // The time the key was pressed or whatever
};

typedef ReplayData = {
    var packUsed:String;

    var justPressed:Array<ReplayKeyData>;
    var pressed:Array<ReplayKeyData>;
    var justReleased:Array<ReplayKeyData>;

    var notes:Array<ReplayNote>;
};

class Replay
{
    public static function loadReplay(path:String):ReplayData
        return Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.replay(path)));

    public static function saveReplay(path:String, data:ReplayData)
        File.saveContent(AssetPaths.replay(path), Json.stringify(data));
}
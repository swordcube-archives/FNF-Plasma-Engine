package base;

import haxe.Json;

class SongLoader
{
    public static function loadJSON(song:String, difficulty:String)
    {
        return Json.parse(GenesisAssets.getAsset('songs/$song/$difficulty.json', TEXT));
    }
}
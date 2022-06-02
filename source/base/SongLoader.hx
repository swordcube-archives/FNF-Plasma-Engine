package base;

import base.Song;
import haxe.Json;

class SongLoader
{
    public static function loadJSON(song:String, difficulty:String)
    {
        var loaded:RawSong = Json.parse(GenesisAssets.getAsset('songs/$song/$difficulty.json', TEXT));
        if(loaded.song.keyCount == null)
            loaded.song.keyCount = 4;

        if(loaded.song.uiSkin == null)
            loaded.song.uiSkin = 'arrows';

        return loaded;
    }
}
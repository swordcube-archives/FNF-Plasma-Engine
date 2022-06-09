package hscript;

/**
    This is literally just a version of GenesisAssets for HScript
    i don't like hscript likes the whole "path, IMAGE" thingie so
    i made these functions
**/
class HScriptGenesisAssets
{
    public static function getImage(path:String, ?mod:Null<String>)
    {
        return GenesisAssets.getAsset(path, IMAGE, mod);
    }

    public static function getSparrow(path:String, ?mod:Null<String>)
    {
        return GenesisAssets.getAsset(path, SPARROW, mod);
    }

    public static function getMusic(path:String, ?mod:Null<String>)
    {
        return GenesisAssets.getAsset(path, MUSIC, mod);
    }

    public static function getSound(path:String, ?mod:Null<String>)
    {
        return GenesisAssets.getAsset(path, SOUND, mod);
    }

    public static function getSong(song:String, ?mod:Null<String>)
    {
        return GenesisAssets.getAsset(song, SONG, mod);
    }

    public static function getFont(path:String, ?mod:Null<String>)
    {
        return GenesisAssets.getAsset(path, FONT, mod);
    }

    public static function getDirectory(path:String, ?mod:Null<String>)
    {
        return GenesisAssets.getAsset(path, DIRECTORY, mod);
    }
}
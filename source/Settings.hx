package;

class Settings
{
    public static function get(option:String)
        return Settings.get(option);

    public static function set(option:String, value:Dynamic, flush:Bool = true)
    {
        Init.trueSettings.set(option, value);
        if(flush)
            Init.saveSettings();
    }
}
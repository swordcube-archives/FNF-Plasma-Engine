package;

import states.PlayState;

/**
    A class for accessing `Init.trueSettings` in an easier way.
**/
class Settings
{
    /**
        Returns the value of `option`.

        @param option        The option to get.
    **/
    public static function get(option:String)
        return Init.trueSettings.get(option);

    /**
        Sets the value of `option` to `value`.

        @param option        The option to set.
        @param value         The value to set the option to.
        @param flush         Choose whether or not to save the setting permanently or temporarily. (true = Permanent)
    **/
    public static function set(option:String, value:Dynamic, flush:Bool = true)
    {
        Init.trueSettings.set(option, value);
        if(flush) {
            if(PlayState.current != null)
                PlayState.current.currentSettings.set(option, value);
            Init.saveSettings();
        }
    }
}
package systems;

import flixel.FlxG;

class Highscore
{
    public static var scores:Map<String, Int> = [];

    public static function init()
    {
        if(FlxG.save.data.scores != null)
            scores = FlxG.save.data.scores;
        else
        {
            FlxG.save.data.scores = scores;
            FlxG.save.flush();
        }
    }

    public static function getScore(thing:String, ?packOverride:Null<String>):Int
    {
        var packToUse:String = packOverride != null ? packOverride : AssetPaths.currentPack;
        return scores.get(thing+":"+packToUse);
    }

    public static function setScore(thing:String, value:Int, ?packOverride:Null<String>)
    {
        var packToUse:String = packOverride != null ? packOverride : AssetPaths.currentPack;
        scores.set(thing+":"+packToUse, value);

        FlxG.save.data.scores = scores;
        FlxG.save.flush();
    }
}
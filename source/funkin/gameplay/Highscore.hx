package funkin.gameplay;

class Highscore {
    public static var scores:Map<String, Int> = [];

    public static function init()
    {
        if(FlxG.save.data.scores != null)
            scores = FlxG.save.data.scores;
        else {
            FlxG.save.data.scores = scores;
            FlxG.save.flush();
        }
    }

    public static function getScore(thing:String, ?mod:Null<String>):Int {
        var packToUse:String = mod != null ? mod : Paths.currentMod;
        if(scores.get(thing+":"+packToUse) == null)
            setScore(thing, 0, mod);
        
        return scores.get(thing+":"+packToUse);
    }

    public static function setScore(thing:String, value:Int, ?mod:Null<String>) {
        var packToUse:String = mod != null ? mod : Paths.currentMod;
        scores.set(thing+":"+packToUse, value);

        FlxG.save.data.scores = scores;
        FlxG.save.flush();
    }
}
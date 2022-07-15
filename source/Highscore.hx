package;

import flixel.FlxG;

class Highscore
{
    static public function getScore(thing:String, diff:String):Int
    {
        if(Reflect.getProperty(FlxG.save.data, thing+"-"+diff) != null)
            return Reflect.getProperty(FlxG.save.data, thing+"-"+diff);
        else
        {
            Reflect.setProperty(FlxG.save.data, thing+"-"+diff, 0);
            FlxG.save.flush();
            return 0;
        }
    }

    static public function setScore(thing:String, diff:String, value:Int)
    {
        Reflect.setProperty(FlxG.save.data, thing+"-"+diff, value);
        FlxG.save.flush();
    }
}
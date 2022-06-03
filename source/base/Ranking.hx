package base;

import states.PlayState;

class Ranking
{
    public static function getRank(accuracy:Float)
    {
        var ranking:String = "N/A";

        if(PlayState.instance.totalNotes > 0)
        {
            var conditions:Array<Array<Dynamic>> = [
                [accuracy >= 100, "S+"], // S+
                [accuracy >= 90, "S"], // S
                [accuracy >= 80, "A"], // A
                [accuracy >= 70, "B"], // B
                [accuracy >= 60, "C"], // C
                [accuracy >= 50, "D"], // D
                [accuracy >= 40, "E"], // E
                [accuracy <= 30, "F"], // F
            ];
            
            for(condition in conditions)
            {
                var boolResult:Bool = condition[0];
                ranking = condition[1];

                if(boolResult == true)
                    break;
            }
        }

        return ranking;
    }

    public static function judgeNote(strumTime:Float):String
    {
        var noteTime = Conductor.songPosition - strumTime;

        var judgementWindows:Map<String, Float> = [
            "sick" => 22.5,
            "good" => 45,
            "bad" => 85,
            "shit" => 100
        ];

        if(Math.abs(noteTime) >= judgementWindows["shit"])
            return "shit";

        if(Math.abs(noteTime) >= judgementWindows["bad"])
            return "bad";

        if(Math.abs(noteTime) >= judgementWindows["good"])
            return "good";
    
        if(Math.abs(noteTime) >= judgementWindows["sick"])
            return "sick";

        return "marvelous";
    }

    public static function getRatingScore(rating:String)
    {
        var scores:Map<String, Int> = [
            "marvelous" => 300,
            "sick" => 300,
            "good" => 200,
            "bad" => 100,
            "shit" => 50
        ];

        return scores[rating];
    }
}
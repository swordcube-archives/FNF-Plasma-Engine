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
}
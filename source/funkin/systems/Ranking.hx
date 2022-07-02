package funkin.systems;

import funkin.game.PlayState;
import haxe.iterators.ArrayIterator;

typedef Judgement =
{
	var time:Float;
	var score:Int;
	var ?noteSplash:Bool;
	var ?mod:Float;
	var ?health:Float;
}

class Ranking
{
	public static var judgements:Map<String, Judgement> = [
		"marvelous" => {
			time: 40.75,
			score: 300,
			noteSplash: true,
			mod: 1
		},
		"sick" => {
			time: 43.5,
			score: 300,
			noteSplash: true,
			mod: 0.95
		},
		"good" => {time: 73.5, score: 200, mod: 0.7},
		"bad" => {time: 125, score: 100, mod: 0.4},
		"shit" => {time: 150, score: 50, health: -0.15}
	];

	static var ranks:Map<Int, String> = [
		100 => "S+",
		90 => "S",
		80 => "A",
		70 => "B",
		60 => "C",
		50 => "D",
		40 => "E",
		10 => "F",
		0 => "booooo",
	];

	public static function getRank(accuracy:Float)
	{
		if (PlayState.instance.totalNotes > 0)
		{
			// biggest Haccuracy
			var bigHacc:Int = 0;
			var leRank:String = "";

			for (minAccuracy => rank in ranks)
			{
				if (minAccuracy <= accuracy && minAccuracy >= bigHacc)
				{
					bigHacc = minAccuracy;
					leRank = rank;
				}
			}

			return leRank;
		}

		return "N/A";
	}

	public static function judgeNote(strumTime:Float)
	{
		var noteDiff:Float = Math.abs(Conductor.position - strumTime);
		var lastJudge:String = "no";
		
		for(key => judge in judgements)
		{
			if(noteDiff >= judge.time && lastJudge == "no")
				lastJudge = key;
		}

		// because map keys are iterators >:((((((( grrrr
		var keys:Array<String> = [];
		for(key in judgements.keys())
			keys.push(key);
		
		if(lastJudge == "no")
			lastJudge = keys[keys.length - 1];
		
		return lastJudge;
	}
}
package base;

import states.PlayState;

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
	public static final judgements:Map<String, Judgement> = [
		"marvelous" => {
			time: 39.25,
			score: 300,
			noteSplash: true,
			mod: 1
		},
		"sick" => {
			time: 43.5,
			score: 300,
			noteSplash: true,
			mod: 1
		},
		"good" => {time: 73.5, score: 200, mod: 0.7},
		"bad" => {time: 125, score: 100, mod: 0.4},
		"shit" => {time: 150, score: 50, health: -0.15}
	];

	static final ranks:Map<Int, String> = [
		100 => "S+",
		90 => "S",
		80 => "A",
		70 => "B",
		60 => "C",
		50 => "D",
		40 => "E",
		30 => "F"
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
		var noteDiff:Float = Math.abs(Conductor.songPosition - strumTime);
		var lastJudge:String = "";

		for (name => judge in judgements)
		{
			if (noteDiff >= judge.time)
				return name;
			else
				lastJudge = name;
		}

		return lastJudge;
	}
}

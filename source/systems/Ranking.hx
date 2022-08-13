package systems;

import states.PlayState;

typedef Judgement = {
	var name:String;
	var time:Float;
	var score:Int;
	var ?noteSplash:Bool;
	var ?mod:Float;
	var ?health:Float;
}

class Ranking {
	// This is an array because from what i've heard maps have undefined orders in haxe
	// fun!
	public static var judgements:Array<Judgement> = [
		// marvelous
		{
			name: "marvelous",
			time: 22.5,
			score: 300,
			noteSplash: true,
			mod: 1
		},
		// sick
		{
			name: "sick",
			time: 45,
			score: 300,
			noteSplash: true,
			mod: 0.95
		},
		// good
		{
			name: "good",
			time: 73.5, 
			score: 200, 
			mod: 0.7
		},
		// bad
		{
			name: "bad",
			time: 125, 
			score: 100, 
			mod: 0.4
		},
		// shit
		{
			name: "shit",
			time: 150, 
			score: 50, 
			health: -0.15
		}
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
		0 => "skill issue",
	];

	public static function getRank(accuracy:Float)
	{
		if (PlayState.current.totalNotes > 0)
		{
			var lastAccuracy:Int = 0;
			var leRank:String = "";

			for (minAccuracy => rank in ranks)
			{
				if (minAccuracy <= accuracy && minAccuracy >= lastAccuracy)
				{
					lastAccuracy = minAccuracy;
					leRank = rank;
				}
			}

			return leRank;
		}

		return "N/A";
	}

	public static function getInfo(rating:String):Judgement
	{
		var judgement:Judgement = null;
		for(judge in judgements)
		{
			if(judge.name == rating)
			{
				judgement = judge;
				break;
			}
		}

		return judgement;
	}

	public static function judgeNote(strumTime:Float)
	{
		var noteDiff:Float = Math.abs(Conductor.position - strumTime);
		var lastJudge:String = "no";
		
		for(judge in judgements)
		{
			if(noteDiff <= judge.time && lastJudge == "no")
				lastJudge = judge.name;
		}
		
		if(lastJudge == "no")
			lastJudge = judgements[judgements.length - 1].name;
		
		return lastJudge;
	}
}

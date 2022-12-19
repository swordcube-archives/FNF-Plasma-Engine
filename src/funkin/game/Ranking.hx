package funkin.game;

import funkin.states.PlayState;

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
		// sick
		{
			name: "sick",
			time: 45,
			score: 300,
			noteSplash: true,
			mod: 1
		},
		// good
		{
			name: "good",
			time: 90, 
			score: 200, 
			mod: 0.7
		},
		// bad
		{
			name: "bad",
			time: 135, 
			score: 100, 
			mod: 0.4
		},
		// shit
		{
			name: "shit",
			time: 180, 
			score: 50, 
			mod: 0,
			health: -0.175
		}
	];
	public static final defaultJudgements:Array<Judgement> = judgements.copy();

	public static var ranks:Map<Int, String> = [
		100 => "S+",
		90 => "S",
		80 => "A",
		70 => "B",
		60 => "C",
		50 => "D",
		40 => "E",
		20 => "F",
		0 => "L"
	];
	public static final defaultRanks:Map<Int, String> = ranks.copy();

	/**
	 * Returns a rank based off of `accuracy`.
	 * @param accuracy The accuracy to get the rank from.
	 * @return String
	 */
	public static function getRank(accuracy:Float):String {
		if (PlayState.current.totalNotes > 0) {
			var lastAccuracy:Int = 0;
			var leRank:String = "";
			for (minAccuracy => rank in ranks) {
				if (minAccuracy <= accuracy && minAccuracy >= lastAccuracy) {
					lastAccuracy = minAccuracy;
					leRank = rank;
				}
			}
			return leRank;
		}
		return "N/A";
	}

	/**
	 * Finds the judgement data with the name of `rating` and returns it.
	 * @param rating 
	 * @return Judgement
	 */
	public static function getInfo(rating:String):Judgement {
		for(judge in judgements) {
			if(judge.name == rating) {
				return judge;
			}
		}
		return null;
	}

	/**
	 * Returns a judgement based on the strum time of a note.
	 * @param strumTime The milliseconds to get the judgement from.
	 * @return String
	 */
	public static function judgeNote(strumTime:Float):String {
		var noteDiff:Float = Math.abs(Conductor.position - strumTime) / FlxG.sound.music.pitch;
		var lastJudge:String = "no";
		
		for(judge in judgements) {
			if(noteDiff <= judge.time && lastJudge == "no")
				lastJudge = judge.name;
		}
		
		if(lastJudge == "no")
			lastJudge = judgements[judgements.length - 1].name;
		
		return lastJudge;
	}
}
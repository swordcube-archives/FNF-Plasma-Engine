package base;

class Highscore {
	public static var scores:Map<String, Int> = [];

	public static function init() {
		if (FlxG.save.data.scores != null)
			scores = FlxG.save.data.scores;
		else {
			FlxG.save.data.scores = scores;
			FlxG.save.flush();
		}
	}

	public static function getScore(thing:String):Int {
		if (scores.get(thing) == null)
			setScore(thing, 0);

		return scores.get(thing);
	}

	public static function setScore(thing:String, value:Int) {
		scores.set(thing, value);

		FlxG.save.data.scores = scores;
		FlxG.save.flush();
	}
}

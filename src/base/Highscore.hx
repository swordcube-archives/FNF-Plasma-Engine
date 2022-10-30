package base;

/**
 * A class for handling highscores.
 */
class Highscore {
	public static var scores:Map<String, Int> = [];

	/**
	 * Loads your scores from save data.
	 */
	public static function init() {
		if (FlxG.save.data.scores != null)
			scores = FlxG.save.data.scores;
		else {
			FlxG.save.data.scores = scores;
			FlxG.save.flush();
		}
	}

	/**
	 * Returns the value of a score named `thing`
	 * @param thing 
	 * @return Int
	 */
	public static function getScore(thing:String):Int {
		if (scores.get(thing) == null)
			setScore(thing, 0);

		return scores.get(thing);
	}

	/**
	 * Sets the value of a score named `thing` to `value`
	 * @param thing The score to set.
	 * @param value The value to use.
	 */
	public static function setScore(thing:String, value:Int) {
		scores.set(thing, value);

		FlxG.save.data.scores = scores;
		FlxG.save.flush();
	}
}

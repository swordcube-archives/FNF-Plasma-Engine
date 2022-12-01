package base;

import flixel.FlxG;

/**
 * A class to get high scores.
 */
class Highscore {
	public static var songScores:Map<String, Int> = [];

	public inline static function saveScore(song:String, score:Int = 0, ?diff:String = "normal"):Void {
		var daSong:String = formatSong(song, diff);
		if (songScores.exists(daSong)) {
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		} else
			setScore(daSong, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	inline static function setScore(song:String, score:Int):Void {
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public inline static function formatSong(song:String, diff:String):String {
		return song+'-'+diff;
	}

	public inline static function getScore(song:String, diff:String):Int {
		var formatted:String = formatSong(song, diff);
		if (!songScores.exists(formatted)) setScore(formatted, 0);
		return songScores.get(formatted);
	}

	public static function load():Void {
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;
	}
}

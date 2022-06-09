package base;

import flixel.FlxG;

using StringTools;

class Highscore
{
	public static var songScores:Map<String, Int> = new Map<String, Int>();

	public static function init()
	{
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;
	}

	// Week Scores
	public static function getWeekScore(week:Int, diff:String):Int
	{
		if (!songScores.exists(formatSong('week' + week, diff)))
			setScore(formatSong('week' + week, diff), 0);

		return songScores.get(formatSong('week' + week, diff));
	}

	public static function saveWeekScore(week:String = "tutorial", score:Int = 0, ?diff:String = "normal"):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	// Song Scores
	public static function getScore(song:String, diff:String):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function setScore(song:String, score:Int):Void
	{
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:String = "normal"):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);
	}

	// Formatting
	public static function formatSong(song:String, diff:String):String
	{
		return song.replace(" ", "-") + '-' + diff;
	}
}

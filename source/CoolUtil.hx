package;

import flixel.math.FlxPoint;
import gameplay.Character;

using StringTools;

class CoolUtil
{
	public static function range(max:Int, ?min = 0):Array<Int>
	{
		var a:Array<Int> = [];

		for (i in min...max)
			a.push(i);

		return a;
	}

	public static function firstLetterUppercase(s:String):String
	{
		var strArray:Array<String> = s.split(' ');
		var newArray:Array<String> = [];
		for (str in strArray)
			newArray.push(str.charAt(0).toUpperCase()+str.substring(1));
	
		return newArray.join(' ');
	}

	public static function listFromText(text:String):Array<String>
	{
		var a:Array<String> = text.trim().split('\n');

		for (i in 0...a.length)
			a[i] = a[i].trim();

		return a;
	}

    public static function getLeatherStagePos(character:Character, position:FlxPoint):Array<Float>
        return [(position.x - (character.width / 2)), (position.y - character.height)];
}

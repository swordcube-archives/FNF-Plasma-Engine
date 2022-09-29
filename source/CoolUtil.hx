package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import gameplay.Character;

using StringTools;

class CoolUtil
{
	/**
		Generates an `Array` from a range of `min` to `max`.

		(Max goes first because i copied this function from base FNF)

		@param max        The maximum number for the range.
		@param min        The minimum number for the range. (0 by default)

		@author swordcube
	**/
	public static function range(max:Int, ?min = 0):Array<Int>
	{
		var a:Array<Int> = [];

		for (i in min...max)
			a.push(i);

		return a;
	}

	/**
		Makes the first letter of each word in `s` uppercase.

		@param s       The string to modify

		@author swordcube
	**/
	public static function firstLetterUppercase(s:String):String
	{
		var strArray:Array<String> = s.split(' ');
		var newArray:Array<String> = [];
		
		for (str in strArray)
			newArray.push(str.charAt(0).toUpperCase()+str.substring(1));
	
		return newArray.join(' ');
	}

	/**
		Splits `text` into an array of multiple strings.

		@param text    The string to split

		@author swordcube
	**/
	public static function listFromText(text:String):Array<String>
	{
		var a:Array<String> = text.trim().split('\n');

		for (i in 0...a.length)
			a[i] = a[i].trim();

		return a;
	}

	/**
		FlxMath.lerp but not tied to the framerate.

		@param a        Number to lerp from.
		@param b        Number to lerp to.
		@param ratio    The speed the lerp has.

		@author swordcube
	**/
	public static function coolLerp(a:Float, b:Float, ratio:Float)
		return a + camLerpShit(ratio) * (b - a);

	/**
		I don't fuckin know what this does i'm not a math expert
	**/
	public static function camLerpShit(ratio:Float):Float {
		return FlxG.elapsed / (1 / 60) * ratio;
	}

	/**
		Gets the position of `character` at `position` in a Leather Engine stage.

		@param character The character to get the position of.
		@param position `FlxPoint` representing the position in the stage.

		@return `Array<Float>` that represents the position of the character.

		@author Leather128
	**/
    public static function getLeatherStagePos(character:Character, position:FlxPoint):Array<Float> {
        return [(position.x - (character.width / 2)), (position.y - character.height)];
	}
}

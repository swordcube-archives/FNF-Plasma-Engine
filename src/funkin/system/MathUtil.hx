package funkin.system;

import flixel.math.FlxMath;

/**
 * A class full of math utilities.
 */
class MathUtil {
	/**
	 * Round a decimal number to have reduced precision (less decimal numbers).
	 *
	 * ```haxe
	 * roundDecimal(1.2485, 2) = 1.25
	 * ```
	 *
	 * @param	Value		Any number.
	 * @param	Precision	Number of decimals the result should have.
	 * @return	The rounded value of that number.
	 */
	public static function roundDecimal(Value:Float, Precision:Int):Float {
		return Math.round(Value * Math.pow(10, Precision)) / Math.pow(10, Precision);
	}

	/**
	 * Returns the linear interpolation of two numbers if `ratio`
	 * is between 0 and 1, and the linear extrapolation otherwise.
	 * 
	 * RATIO IS AFFECTED BY THE FRAMERATE WITH THIS FUNCTION BTW!!!
	 *
	 * Examples:
	 *
	 * ```haxe
	 * fixedLerp(a, b, 0) = a
	 * fixedLerp(a, b, 1) = b
	 * fixedLerp(5, 15, 0.5) = 10
	 * fixedLerp(5, 15, -1) = -5
	 * ```
	 */
	public inline static function fixedLerp(a:Float, b:Float, ratio:Float) {
		return FlxMath.lerp(a, b, FlxMath.bound(fpsAdjust(ratio), 0, 1));
	}

	/**
	 * Adjusts a number to match the framerate.
	 * Useful for lerp functions.
	 * @param num The number to adjust.
	 */
	public inline static function fpsAdjust(num:Float) {
		return FlxG.elapsed * 60 * num;
	}

	/**
	 * Generates an array of numbers from `min` to `max`.
	 * @param max The maximum number in the range.
	 * @param min The minimum number in the range.
	 * @return Array<Int>
	 */
	 public inline static function range(max:Int, ?min = 0):Array<Int> {
		var dumbArray:Array<Int> = [];
		for (i in min...max) dumbArray.push(i);
		return dumbArray;
	}
}

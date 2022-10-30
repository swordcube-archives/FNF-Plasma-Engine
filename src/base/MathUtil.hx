package base;

import flixel.math.FlxMath;

/**
 * A class full of math utilties.
 */
class MathUtil {
    /**
     * This is just `FlxMath.lerp` but it adjusts to your framerate.
     */
    public static function fixedLerp(a:Float, b:Float, t:Float) {
        return FlxMath.lerp(a, b, FlxG.elapsed * 60 * t);
    }

    /**
     * This is just `FlxMath.roundDecimal` but better i guess lmao!
     * @param number The float to round.
     * @param precision The amount of decimals to leave.
     */
    public static function roundDecimal(number:Float, precision:Int) {
        var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
    }
}
package base;

import flixel.math.FlxMath;

class MathUtil {
    /**
     * This is just `FlxMath.lerp` but it adjusts to your framerate.
     */
    public static function fixedLerp(a:Float, b:Float, t:Float) {
        return FlxMath.lerp(a, b, FlxG.elapsed * 60 * t);
    }
}
package external.memory;

#if cpp
/**
 * Memory class to properly get accurate memory counts
 * for the program.
 * @author Leather128 (Haxe) - David Robert Nadeau (Original C Header)
 */
@:buildXml('<include name="../../../../src/external/memory/build.xml" />')
@:include("memory.h")
extern class Memory {
    @:native("getPeakRSS")
    public static function getPeakUsage():Int;

    @:native("getCurrentRSS")
    public static function getCurrentUsage():Int;
}
#else
import openfl.system.System;

/**
 * If you are not running on a CPP Platform, The `totalMemory` variable from `openfl.system.System` gets used instead!
 * Doesn't work on HTML5!
 * @author swordcube
 */
class Memory {
    public static var peak:Int = 0;
    public static function getPeakUsage():Int { 
        if(System.totalMemory > peak) peak = System.totalMemory;
        return peak;
    };
    public static function getCurrentUsage():Int { return System.totalMemory; };
}
#end
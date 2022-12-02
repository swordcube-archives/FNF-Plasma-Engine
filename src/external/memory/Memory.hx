package external.memory;

#if cpp
/**
 * Memory class to properly get accurate memory counts
 * for the program.
 * @author Leather128 (Haxe) - David Robert Nadeau (Original C Header)
 */
@:buildXml('<include name="../../../../src/external/memory/build.xml" />')
@:include("memory.h")
@:dox(hide)
extern class Memory
{
    @:native("getPeakRSS")
    public static function getPeakUsage():Int;

    @:native("getCurrentRSS")
    public static function getCurrentUsage():Int;
}
#else
/**
 * If you are not running on a CPP Platform, the code just will not work properly, sorry!
 * @author Leather128
 */
@:dox(hide)
class Memory
{
    public static function getPeakUsage():Int { return 0; };
    public static function getCurrentUsage():Int { return 0; };
}
#end
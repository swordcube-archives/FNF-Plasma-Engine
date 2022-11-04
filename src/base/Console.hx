package base;

/**
 * A class for printing stuff to the console but in a fancier way.
 */
class Console {
    public static var ansiColors:Map<String, String> = [];
    public static var haxeTrace = haxe.Log.trace;

    public static function init() {
        ansiColors['black'] = '\033[0;30m';
		ansiColors['red'] = '\033[31m';
		ansiColors['green'] = '\033[32m';
		ansiColors['yellow'] = '\033[33m';
		ansiColors['blue'] = '\033[1;34m';
		ansiColors['magenta'] = '\033[1;35m';
		ansiColors['cyan'] = '\033[0;36m';
		ansiColors['grey'] = '\033[0;37m';
		ansiColors['white'] = '\033[1;37m';
		ansiColors['orange'] = '\033[38;5;214m';

		// reuse it for quick lookups of colors to log levels
		ansiColors['default'] = ansiColors['grey'];

        // set default trace to new log thing
        haxe.Log.trace = function(v:Dynamic, ?infos:Null<haxe.PosInfos>) {
            log(v);
        }
    }

    public static function haxeLog(text:Dynamic) {
        haxeTrace(text);
    }

    public static function log(text:Dynamic) {
        Sys.println('${ansiColors["grey"]}[   TRACE   ] ${ansiColors["default"]}' + text);
    }

    public static function debug(text:Dynamic) {
        #if debug
        Sys.println('${ansiColors["cyan"]}[   DEBUG   ] ${ansiColors["default"]}' + text);
        #end
    }

    public static function error(text:Dynamic) {
        Sys.println('${ansiColors["red"]}[   ERROR   ] ${ansiColors["default"]}' + text);
    }

    public static function warn(text:Dynamic) {
        Sys.println('${ansiColors["yellow"]}[  WARNING  ] ${ansiColors["default"]}' + text);
    }

    public static function info(text:Dynamic) {
        Sys.println('${ansiColors["cyan"]}[   INFO    ] ${ansiColors["default"]}' + text);
    }
}
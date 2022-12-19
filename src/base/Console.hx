package base;

import funkin.ui.LogsOverlay;

@:dox(hide)
 typedef ConsoleLogSymbol = {
    var regularSymbol:String;
    var fallBackSymbol:String;
}

/**
 * A class for printing stuff to the console in a more readable way.
 */
class Console {
    /**
     * Makes the console prints fancier by adding colors and emojis.
     * This option exists to turn off for people who use terminals that don't support color and/or emojis.
     */
    public static var fancyText:Bool = true;

    /**
     * The default `Haxe` trace function.
     */
    public static var defaultTrace = haxe.Log.trace;
    
    public static var colors:Map<String, String> = [
		'black'		=> '\033[0;30m',
		'red'		=> '\033[31m',
		'green'		=> '\033[32m',
		'yellow'	=> '\033[33m',
		'blue'		=> '\033[1;34m',
		'magenta'	=> '\033[1;35m',
		'cyan'		=> '\033[0;36m',
		'grey'		=> '\033[0;37m',
		'gray'		=> '\033[0;37m', // there's both gr[e]y and gr[a]y because both are literally the same lmao
		'white'		=> '\033[1;37m',
		'orange'	=> '\033[38;5;214m',
		'reset'		=> '\033[0;37m'
	];

    public static inline function init() {
        haxe.Log.trace = function(v:Dynamic, ?infos:Null<haxe.PosInfos>) {
			log(v);
		}
    }

    public static inline function log(v:Dynamic, ?typeThing:Null<String>, ?color:Null<String>, ?symbols:Null<ConsoleLogSymbol>) {
        if(typeThing == null) typeThing = "LOG";
        var symbolData:ConsoleLogSymbol = symbols != null ? symbols : {
            regularSymbol: '⚪️',
            fallBackSymbol: '(i)'
        };
        var symbol:String = fancyText ? symbolData.regularSymbol : symbolData.fallBackSymbol;
        var color:String = color != null ? color : colors["reset"];
        var resetColor:String = colors["reset"];
        var beginning:String = fancyText ? '$color[ $symbol $typeThing ]' : '[ $symbol $typeThing ]';
        var end:String = fancyText ? '${resetColor}$v' : '$v';
        Sys.println('$beginning - $end');
    }

    public static inline function error(v:Dynamic) {
		FlxG.log.error(v);
        var color:String = colors["red"];
        log(v, "ERROR", color, {regularSymbol: '🔴️', fallBackSymbol: '(X)'});
    }

    public static inline function warn(v:Dynamic) {
		FlxG.log.warn(v);
        var color:String = colors["yellow"];
        log(v, "WARN", color, {regularSymbol: '🟡️', fallBackSymbol: '/!\\'});
    }

    public static inline function info(v:Dynamic) {
		FlxG.log.notice(v);
        var color:String = colors["blue"];
        log(v, "INFO", color, {regularSymbol: '🔵️', fallBackSymbol: '(i)'});
    }

    public static inline function debug(v:Dynamic) {
        #if debug
		FlxG.log.notice(v);
        var color:String = colors["green"];
        log(v, "DEBUG", color, {regularSymbol: '🟢️', fallBackSymbol: '(i)'});
        #end
    }
}
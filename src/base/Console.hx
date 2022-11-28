package base;

import funkin.ui.LogsOverlay;

class Console {
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

	public static function init() {
		haxe.Log.trace = function(v:Dynamic, ?infos:Null<haxe.PosInfos>) {
			log(v);
		}
	}

	public inline static function log(v:Dynamic) {
		Sys.println('${colors['grey']}[   Trace   ] ${colors['reset']}${v}');
		//LogsOverlay.trace(v, WHITE);
	}

	public inline static function info(v:Dynamic) {
		Sys.println('${colors['cyan']}[   Info    ] ${colors['reset']}${v}');
		//LogsOverlay.trace(v, CYAN);
	}

	public inline static function debug(v:Dynamic) {
		FlxG.log.notice(v);
		Sys.println('${colors['orange']}[   Debug   ] ${colors['reset']}${v}');
		//LogsOverlay.trace(v, YELLOW);
	}

	public inline static function error(v:Dynamic) {
		FlxG.log.error(v);
		Sys.println('${colors['red']}[   Error   ] ${colors['reset']}${v}');
		//LogsOverlay.error(v);
	}

	public inline static function warn(v:Dynamic) {
		FlxG.log.warn(v);
		Sys.println('${colors['yellow']}[   Warn    ] ${colors['reset']}${v}');
		//LogsOverlay.error(v, YELLOW);
	}

	public inline static function printRaw(v:Dynamic)
		Sys.println(Std.string(v));
}

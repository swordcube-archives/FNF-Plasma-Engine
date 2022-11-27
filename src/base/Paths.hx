package base;

import flixel.FlxG;

class Paths {
	public static var currentMod:String = "Friday Night Funkin'";
	public static var fallbackMod:String = currentMod;

	public static function file(path:String) {
		return '${Sys.getCwd()}$path';
	}

	public static function asset(path:String, ?mod:Null<String>) {
		if(mod == null) mod = currentMod;

		var sourcePath:String = Main.developerMode ? '../../../../' : '';
		var pathsToCheck:Array<String> = [
			// Allow checking of the current mod
			file('${sourcePath}mods/$mod/$path'),
			file('mods/$mod/$path'),

			// Allow checking of the fallback mod if the asset 
			// couldn't be found in the current mod
			file('${sourcePath}assets/$path'),
			file('assets/$path'),
		];
		for(p in pathsToCheck) if(FileSystem.exists(p)) return p;
		return file('${sourcePath}assets/$path');
	}

	public static var scriptExtensions:Array<String> = [
		".hx",
		".hxs",
		".hsc",
		".hscript",
		".lua",
		".py"
	];

	public static function script(path:String, ?mod:Null<String>) {
		var pathsToCheck:Array<String> = [for(ext in scriptExtensions) asset('$path$ext', mod)];
		for(p in pathsToCheck) if(FileSystem.exists(p)) return p;
		return asset('$path.hx', mod);
	}

	public static function image(path:String, useRootFolder:Bool = true, ?mod:Null<String>) {
		var root:String = useRootFolder ? 'images/' : '';
		return asset('$root$path.png', mod);
	}

	public static function json(path:String, ?mod:Null<String>) {
		return asset('$path.json', mod);
	}

	public static function txt(path:String, ?mod:Null<String>) {
		return asset('$path.txt', mod);
	}

	public static function xml(path:String, ?mod:Null<String>) {
		return asset('$path.xml', mod);
	}

	public static function music(path:String, ?mod:Null<String>) {
		return sound('music/$path', false, mod);
	}

	public static function sound(path:String, useRootFolder:Bool = true, ?mod:Null<String>) {
		var root:String = useRootFolder ? 'sounds/' : '';
		return asset('$root$path.ogg', mod);
	}

	public static function randomSound(key:String, min:Int, max:Int, ?mod:Null<String>) {
		return sound(key + FlxG.random.int(min, max), mod);
	}

	public static function inst(song:String, ?mod:Null<String>) {
		return sound('songs/${song.toLowerCase()}/Inst', false, mod);
	}

	public static function voices(song:String, ?mod:Null<String>) {
		return sound('songs/${song.toLowerCase()}/Voices', false, mod);
	}

	public static function font(path:String, ?mod:Null<String>) {
		return asset('fonts/$path', mod);
	}
}
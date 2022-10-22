package base;

using StringTools;

class Utilities {
	public static function fixWorkingDirectory() {
		var curDir = Sys.getCwd();
		var execPath = Sys.programPath();
		var p = execPath.replace("\\", "/").split("/");
		var execName = p.pop(); // interesting
		Sys.setCwd(p.join("\\") + "\\");
	}

	public static function getOS() {
		#if sys return Sys.systemName(); #end
		#if html5 return "HTML5"; #end
		#if android return "Android"; #end

		// Fallback if we can't find the OS the user is on (or is unsupported)
		return "Unknown";
	}

	public static function getSizeLabel(num:Int):String {
		// 2147483648 is 2048 mb btw lmao
		var size:Float = Math.abs(num) != num ? Math.abs(num) + 2147483648 : num;
		var data = 0;
		var dataTexts = ["b", "kb", "mb", "gb", "tb", "pb"];

		while (size > 1024 && data < dataTexts.length - 1) {
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		return size + dataTexts[data]; // smth like 100mb
	}
}

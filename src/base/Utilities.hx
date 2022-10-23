package base;

import haxe.xml.Access;
import funkin.states.FreeplayMenu.FreeplaySong;

using StringTools;

class Utilities {
	public static function fixWorkingDirectory() {
		var curDir = Sys.getCwd();
		var execPath = Sys.programPath();
		var p = execPath.replace("\\", "/").split("/");
		var execName = p.pop(); // interesting
		Sys.setCwd(p.join("\\") + "\\");
	}

	public static function openURL(url:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
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

	public static function trimArray(a:Array<String>):Array<String> {
		var f:Array<String> = [];
		for(i in a) f.push(i.trim());
		return f;
	}

	public static function loadSongListXML(text:String) {
		var retArray:Array<FreeplaySong> = [];
		var data = new Access(Xml.parse(text).firstElement());
		for (song in data.nodes.song) {
			var newSong:FreeplaySong = {
				song: song.att.name,
				displayName: song.has.displayName ? song.att.displayName : song.att.name,
				character: song.att.character,
				color: FlxColor.fromString(song.att.color),
				difficulties: trimArray(song.att.difficulties.split(","))
			}
			retArray.push(newSong);
		}
		return retArray;
	}
}

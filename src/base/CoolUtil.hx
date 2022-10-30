package base;

import flixel.math.FlxPoint;
import haxe.xml.Access;
import funkin.states.FreeplayMenu.FreeplaySong;

using StringTools;

/**
 * A class full of...cool utilties.
 */
class CoolUtil {
	public static function fixWorkingDirectory() {
		var curDir = Sys.getCwd();
		var execPath = Sys.programPath();
		var p = execPath.replace("\\", "/").split("/");
		var execName = p.pop(); // interesting
		Sys.setCwd(p.join("\\") + "\\");
	}

	/**
	 * Converts `b1` and `b2` into either -1 or 1.
	 * @param b1 The first `Bool`
	 * @param b2 The second `Bool`
	 */
	public static function getBoolAxis(b1:Bool, b2:Bool) {
		var num1:Float = b1 ? 1 : 0;
		var num2:Float = b2 ? 1 : 0;
		return num1 - num2;
	}

	/**
	 * Opens a web browser and goes to `url`.
	 * @param url 
	 */
	public static function openURL(url:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	/**
	 * Gets the operating system the user is on.
	 * @return String
	 */
	public static function getOS():String {
		#if sys return Sys.systemName(); #end
		#if html5 return "HTML5"; #end
		#if android return "Android"; #end

		// Fallback if we can't find the OS the user is on (or is unsupported)
		return "Unknown";
	}

	/**
	 * Converts bytes into a human-readable format `(Examples: 1b, 256kb, 1024mb, 2048gb, 4096tb)
	 * @param num The bytes to convert.
	 * @return String
	 */
	public static function getSizeLabel(num:Int):String {
		var size:Float = Math.abs(num) != num ? Math.abs(num) + 2147483648 : num;
		var data = 0;
		var dataTexts = ["b", "kb", "mb", "gb", "tb", "pb"];

		while (size > 1024 && data < dataTexts.length - 1) {
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		return size + dataTexts[data];
	}

	/**
	 * Trims everything in an array and returns it.
	 * @param a The array to modify.
	 * @return Array<String>
	 */
	public static function trimArray(a:Array<String>):Array<String> {
		var f:Array<String> = [];
		for(i in a) f.push(i.trim());
		return f;
	}

	/**
	 * Gets an array of `FreeplaySongs` from the contents of `text`.
	 * @param text The XML data to parse.
	 */
	public static function loadSongListXML(text:String) {
		var retArray:Array<FreeplaySong> = [];
		var data = new Access(Xml.parse(text).firstElement());
		for (song in data.nodes.song) {
			var newSong:FreeplaySong = {
				song: song.att.name,
				displayName: song.has.displayName ? song.att.displayName : song.att.name,
				character: song.att.character,
				color: FlxColor.fromString(song.att.color),
				difficulties: trimArray(song.att.difficulties.split(",")),
				bpm: Std.parseFloat(song.att.bpm)
			}
			retArray.push(newSong);
		}
		return retArray;
	}

	/**
		Makes the first letter of each word in `s` uppercase.
		@param s       The string to modify
		@author swordcube
	**/
	public static function firstLetterUppercase(s:String):String
	{
		var strArray:Array<String> = s.split(' ');
		var newArray:Array<String> = [];
		
		for (str in strArray)
			newArray.push(str.charAt(0).toUpperCase()+str.substring(1));
	
		return newArray.join(' ');
	}

	/**
		Splits `text` into an array of multiple strings.
		@param text    The string to split
		@author swordcube
	**/
	public static function listFromText(text:String):Array<String> {
		var a:Array<String> = text.trim().split('\n');
		for (i in 0...a.length) a[i] = a[i].trim();
		return a;
	}

	/**
	 * Splits `string` using `delimeter` and then converts all items in the array into an `Int` and returns it.
	 * @param string 
	 * @param delimeter 
	 * @return Array<Int>
	 * @author Leather128
	 */
	public static function splitInt(string:String, delimeter:String):Array<Int> {
		var splitString:Array<String> = string.split(delimeter);
		var splitReturn:Array<Int> = [];

		for (string in splitString)
			splitReturn.push(Std.parseInt(string));

		return splitReturn;
	}

	/**
		Gets the position of `character` at `position` in a Leather Engine stage.
		@param character The character to get the position of.
		@param position `FlxPoint` representing the position in the stage.
		@return `Array<Float>` that represents the position of the character.
		@author Leather128
	**/
    public static function getLeatherStagePos(character:funkin.Character, position:FlxPoint):Array<Float> {
        return [(position.x - (character.width / 2)), (position.y - character.height)];
	}
}

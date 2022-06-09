package base;

import flixel.FlxG;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class CoolUtil
{
	public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(contents:String):Array<String>
	{
		var daList:Array<String> = contents.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel))
					{
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					}
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
					{
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function precacheSound(sound:String):Void
	{
		GenesisAssets.getAsset(sound, SOUND);
	}

	public static function precacheMusic(music:String):Void
	{
		GenesisAssets.getAsset(music, MUSIC);
	}

	public static function openURL(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function camLerpShit(ratio:Float)
	{
		return FlxG.elapsed / (1 / 60) * ratio;
	}

	public static function coolLerp(a:Float, b:Float, ratio:Float)
	{
		return a + camLerpShit(ratio) * (b - a);
	}

	private static var hexCodes = "0123456789ABCDEF";

	public static function rgbToHex(r:Int, g:Int, b:Int):String
	{
		var hexString = "#";
		// Red
		hexString += hexCodes.charAt(Math.floor(r / 16));
		hexString += hexCodes.charAt(r % 16);
		// Green
		hexString += hexCodes.charAt(Math.floor(g / 16));
		hexString += hexCodes.charAt(g % 16);
		// Blue
		hexString += hexCodes.charAt(Math.floor(b / 16));
		hexString += hexCodes.charAt(b % 16);

		return hexString;
	}

	public static function rgbaToHex(r:Int, g:Int, b:Int, a:Int):String
	{
		var hexString = "#";
		// Red
		hexString += hexCodes.charAt(Math.floor(r / 16));
		hexString += hexCodes.charAt(r % 16);
		// Green
		hexString += hexCodes.charAt(Math.floor(g / 16));
		hexString += hexCodes.charAt(g % 16);
		// Blue
		hexString += hexCodes.charAt(Math.floor(b / 16));
		hexString += hexCodes.charAt(b % 16);
		// Alpha
		hexString += hexCodes.charAt(Math.floor(a / 16));
		hexString += hexCodes.charAt(a % 16);

		return hexString;
	}
}

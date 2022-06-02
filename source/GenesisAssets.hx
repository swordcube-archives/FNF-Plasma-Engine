package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end


// kinda stole part of this from https://github.com/Yoshubs/FNF-Forever-Engine/blob/master/source/AssetManager.hx
// specifically the `returnGraphic` and `returnSound` functions

// thanks Yoshubs for being cool and gaming and shit

@:enum abstract AssetType(String) to String
{
	var IMAGE = 'image';
	var SPARROW = 'sparrow';
	var MUSIC = 'music';
	var SOUND = 'sound';
	var SONG = 'song';
	var FONT = 'font';
	var DIRECTORY = 'directory';
	var TEXT = 'TEXT';
	var HSCRIPT = 'hx';
}

class GenesisAssets
{
	#if sys
	public static var cwd:String = Sys.getCwd();
	#else
	public static var cwd:String = "";
	#end

	public static var mods:Array<String> = [];
	public static var activeMods:Map<String, Bool> = [];

	public static var keyedAssets:Map<String, Dynamic> = [];

	public static function getAsset(path:String, type:AssetType, ?mod:Null<String> = null, ?compress:Bool = true):Dynamic
	{
		var goodPath:String = getPath(path, type, mod);
		
		switch (type)
		{
			case TEXT:
				#if sys
				return File.getContent(goodPath);
				#else
				return Assets.getText(goodPath);
				#end
			case IMAGE:
				return returnGraphic(goodPath, compress);
			case MUSIC | SOUND | SONG:
				return returnSound(goodPath);
			case SPARROW:
				var graphicPath = getPath(path, IMAGE);
				trace('sparrow graphic path $graphicPath');
				var graphic:FlxGraphic = returnGraphic(graphicPath, compress);
				trace('sparrow xml path $goodPath');
				return FlxAtlasFrames.fromSparrow(graphic, 
					#if sys
					File.getContent(goodPath)
					#else
					Assets.getText(goodPath)
					#end
				);
			default:
				trace('returning directory $goodPath');
				return goodPath;
		}

		trace('Asset: ' + path + ' with type of: ' + type + "could not be found. Returning null.");
		return null;
	}

	public static function init()
	{
		getAllMods();
	}

	public static function returnGraphic(key:String, ?textureCompression:Bool = false)
	{
		#if sys
		if (FileSystem.exists(key))
		#else
		if (Assets.exists(key))
		#end
		{
			if (!keyedAssets.exists(key))
			{
				#if sys
				var bitmap = BitmapData.fromFile(key);
				#end

				var newGraphic:FlxGraphic;

				#if sys
				if (textureCompression)
				{
					var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true);
					texture.uploadFromBitmapData(bitmap);
					keyedAssets.set(key, texture);
					bitmap.dispose();
					bitmap.disposeImage();
					bitmap = null;
					
					trace('new texture $key, bitmap is $bitmap');
					
					newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);

					newGraphic.destroyOnNoUse = false;
					newGraphic.persist = true;
				}
				else
				{
					newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);

					newGraphic.destroyOnNoUse = false;
					newGraphic.persist = true;
					#else
					newGraphic = FlxGraphic.fromAssetKey(key, false, key, false);

					newGraphic.destroyOnNoUse = false;
					newGraphic.persist = true;
					#end

					trace('new bitmap $key, not textured');
				#if sys
				}
				#end

				keyedAssets.set(key, newGraphic);
			}

			trace('graphic returning $key with gpu rendering $textureCompression');
			
			return keyedAssets.get(key);
		}

		trace('graphic returning null at $key with gpu rendering $textureCompression');

		return null;
	}

	public static function returnSound(key:String)
	{
		#if sys
		if (FileSystem.exists(key))
		#else
		if (Assets.exists(key))
		#end
		{
			if (!keyedAssets.exists(key))
			{
				#if sys
				keyedAssets.set(key, Sound.fromFile(key));
				#else
				@:privateAccess
				keyedAssets.set(key, new FlxSound().loadEmbedded(key)._sound);
				#end

				trace('new sound $key');
			}

			trace('sound returning $key');

			return keyedAssets.get(key);
		}

		trace('sound returning null at $key');

		return null;
	}

	public static function getAllMods()
	{
		#if MODS_ALLOWED
		if(FlxG.save.data.mods != null)
			activeMods = FlxG.save.data.mods;

		if(FileSystem.exists('${cwd}mods'))
		{
			mods = [];

			var modsDirectory:Array<String> = FileSystem.readDirectory('${cwd}mods');

			for(mod in modsDirectory)
			{
				if(!mod.contains('.'))
					mods.push(mod);

				if(activeMods.get(mod) == null)
					activeMods.set(mod, true);
			}
		}

		FlxG.save.data.mods = activeMods;
		#end

		trace("returning all mods!");

		return mods;
	}

	public static function getPath(path:String, type:AssetType, ?mod:Null<String> = null)
	{
		var basePath = '';

		trace("TYPE: " + type);
		
		switch(type)
		{
			case IMAGE:
				basePath = 'images/$path.png';
			case SPARROW:
				basePath = 'images/$path.xml';
			case MUSIC:
				basePath = 'music/$path.ogg';
			case SOUND:
				basePath = 'sounds/$path.ogg';
			case SONG:
				basePath = 'songs/$path.ogg';
			case FONT:
				basePath = 'fonts/$path';
			default:
				basePath = path;
		}

		#if MODS_ALLOWED
		if(mod == null)
		{
			for(_mod in mods)
			{
				if(activeMods.get(_mod) == true)
				{
					if(FileSystem.exists('${cwd}mods/$_mod/$basePath'))
					{
						#if html5
						if(type == FONT)
							return openfl.utils.Assets.getFont('${cwd}mods/$_mod/$basePath').fontName;
						#end

						return '${cwd}mods/$_mod/$basePath';
					}
				}
			}
		}
		else 
		{
			if(FileSystem.exists('${cwd}mods/$mod/$basePath'))
			{
				#if html5
				if(type == FONT)
					return openfl.utils.Assets.getFont('${cwd}mods/$mod/$basePath').fontName;
				#end
				
				return '${cwd}mods/$mod/$basePath';
			}
		}
		#end

		if(Assets.exists('assets/$basePath'))
		{
			#if html5
			if(type == FONT)
				return openfl.utils.Assets.getFont('assets/$basePath').fontName;
			#end

			return 'assets/$basePath';
		}

		trace('assets/$basePath doesn\'t exist!');
		return null;
	}
}

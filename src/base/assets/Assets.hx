package base.assets;

import flixel.graphics.frames.FlxAtlasFrames;
import sys.io.File;
import sys.FileSystem;
import openfl.media.Sound;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

using StringTools;

class Assets {
    public static var cache:AssetCache = new AssetCache();

    public static function load(type:AssetType, path:String) {
        switch(type) {
            case IMAGE:
                if(!cache.exists(path)) cache.add(path, FlxGraphic.fromBitmapData(BitmapData.fromFile(path), false, path, false));
                return cache.get(path);

            case SPARROW:
                return FlxAtlasFrames.fromSparrow(load(IMAGE, path), load(TEXT, path.replace(Paths.IMAGE_EXT, ".xml")));

            case PACKER:
                return FlxAtlasFrames.fromSpriteSheetPacker(load(IMAGE, path), load(TEXT, path.replace(Paths.IMAGE_EXT, ".txt")));

            case SOUND:
                if(!cache.exists(path)) cache.add(path, Sound.fromFile(path));
                return cache.get(path);

            case TEXT:
                if(!FileSystem.exists(path)) return "";
                return File.getContent(path);
        }

        Console.error('$type isn\'t a valid type! Returning null!!!');
        return null;
    }
}
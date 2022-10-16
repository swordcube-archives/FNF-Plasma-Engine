package assets;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;

@:enum abstract FunkinAssetType(String) from String to String {
    var IMAGE:FunkinAssetType = "IMAGE";
    var SPARROW:FunkinAssetType = "SPARROW";
    var PACKER:FunkinAssetType = "PACKER";
    var SOUND:FunkinAssetType = "SOUND";
    var TEXT:FunkinAssetType = "TEXT";
    var JSON:FunkinAssetType = "JSON";
}

class Assets {
    public static var cache:Map<String, Dynamic> = [];

    public static function clearCache() {
        for(key in cache.keys()) {
            var item:Dynamic = cache[key];
            if(Std.isOfType(item, FlxGraphic)) {
                var casted = cast(item, FlxGraphic);
                casted.dump();
                casted.destroy();
            }
            cache.remove(key);
        }
    }

    public static function get(type:FunkinAssetType, path:String):Dynamic {
        switch(type) {
            case IMAGE:
                if(!cache.exists(path)) {
                    var bitmap:BitmapData = BitmapData.fromFile(path);
                    var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, path, false);
                    graphic.persist = true;
                    graphic.destroyOnNoUse = true;
                    cache.set(path, graphic);
                }
                return cache[path];

            case SPARROW:
                var xmlPath:String = path;
                for(ext in Paths.imageExts) xmlPath = xmlPath.split(ext)[0];
                xmlPath += ".xml";
                
                if(FileSystem.exists(path) && FileSystem.exists(xmlPath)) {
                    var graphic:FlxGraphic = Assets.get(IMAGE, path);
                    var xmlData:String = Assets.get(TEXT, xmlPath);
                    return FlxAtlasFrames.fromSparrow(graphic, xmlData);
                }

                // Will add a fallback here!
                return null;
        
            case PACKER:
                var xmlPath:String = path;
                for(ext in Paths.imageExts) xmlPath = xmlPath.split(ext)[0];
                xmlPath += ".txt";
                
                if(FileSystem.exists(path) && FileSystem.exists(xmlPath)) {
                    var graphic:FlxGraphic = Assets.get(IMAGE, path);
                    var xmlData:String = Assets.get(TEXT, xmlPath);
                    return FlxAtlasFrames.fromSpriteSheetPacker(graphic, xmlData);
                }

                // Will add a fallback here!
                return null;

            case SOUND:
                if(!cache.exists(path)) {
                    var sound:Sound = Sound.fromFile(path);
                    cache.set(path, sound);
                }
                return cache[path];

            case JSON:
                var jsonResult = {};
                try {
                    var parsed = Json.parse(Assets.get(TEXT, path));
                    jsonResult = parsed;
                } catch(e) {
                    Main.print("error", 'Error occured while loading JSON! ($path)');
                    Main.print("error", '${e.details()}');
                }

                return jsonResult;

            case TEXT:
                if(FileSystem.exists(path))
                    return File.getContent(path);
                
                return "";
                
            default:
                return null;
        }
        return null;
    }
}
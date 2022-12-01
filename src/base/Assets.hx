package base;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

using StringTools;

class Assets {
    public static var fallbackXMLData:String = '<?xml version="1.0" encoding="utf-8"?>
    <TextureAtlas imagePath="fallback.png">
        <SubTexture name="fallback0000" x="0" y="0" width="16" height="16"/>
    </TextureAtlas>';

    public static var cache:AssetCache = new AssetCache();

    public static function load(type:AssetType, path:String):Dynamic {
        switch(type) {
            case IMAGE:
                if(!cache.exists(path)) {
                    var bmp = BitmapData.fromFile(path);
                    // Load default flixel image if image couldn't be found
                    if(bmp == null) bmp = OpenFLAssets.getBitmapData("flixel/images/logo/default.png");
                    // Turn the bitmap into an FlxGraphic and add it to the cache
                    var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bmp, false, path, false);
                    graphic.destroyOnNoUse = false;
                    graphic.persist = true;
                    cache.add(path, graphic);
                }
                return cache.get(path);

            case SPARROW:
                var xmlData:String = load(TEXT, path.replace(".png", ".xml"));
                if(xmlData == "") xmlData = fallbackXMLData;
                return FlxAtlasFrames.fromSparrow(load(IMAGE, path), xmlData);

            case PACKER:
                return FlxAtlasFrames.fromSpriteSheetPacker(load(IMAGE, path), load(TEXT, path.replace(".png", ".txt")));

            case SOUND:
                if(!cache.exists(path)) {
                    var sound = Sound.fromFile(path);
                    cache.add(path, sound);
                }
                return cache.get(path);

            case TEXT:
                if(!FileSystem.exists(path)) return "";
                return File.getContent(path);

            case JSON:
                var errorResult:Dynamic = {"Error": "JSON couldn't load!"};
                if(!FileSystem.exists(path)) return errorResult;
                try {
                    var json:Dynamic = Json.parse(load(TEXT, path));
                    return json;
                } catch(e) {
                    Console.error("Occured while loading JSON: "+e);
                    return errorResult;
                }
                return errorResult;

            default: trace("no");
        }
        return null;
    }
}

private class AssetCache {
    public var cache:Map<String, Dynamic> = [];
    public function new() {}
    public function get(name:String) {
        return cache.get(name);
    }
    public function add(name:String, value:Dynamic) {
        cache.set(name, value);
    }
    public function remove(name:String) {
        var asset:Dynamic = cache.get(name);
        if(Std.isOfType(asset, FlxGraphic)) {
            var graphic:FlxGraphic = cast asset;
            graphic.destroyOnNoUse = true;
            graphic.persist = false;
            graphic.dump();
            graphic.destroy();
        }
        cache.remove(name);
    }
    public function clear() {
        for(key in cache.keys()) remove(key);
    }
    public function exists(name:String) {
        return cache.exists(name);
    }
}
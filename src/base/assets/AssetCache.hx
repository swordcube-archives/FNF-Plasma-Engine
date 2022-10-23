package base.assets;

import flixel.graphics.FlxGraphic;

class AssetCache {
    public var cache:Map<String, Dynamic> = [];

    public function new() {}
    public function get(name:String) {
        return cache.get(name);
    }
    public function add(name:String, value:Dynamic) {
        cache.set(name, value);
    }
    public function remove(name:String) {
        var item = cache.get(name);
        if(Std.isOfType(item, FlxGraphic)) {
            var casted:FlxGraphic = cast item;
            casted.destroyOnNoUse = true;
            casted.persist = false;
            casted.dump();
            casted.destroy();
            casted = null;
        }
        cache.remove(name);
    }
    public function clear() {
        for(key in cache.keys()) {
            remove(key);
        }
    }
    public function exists(name:String) {
        return cache.exists(name);
    }
}
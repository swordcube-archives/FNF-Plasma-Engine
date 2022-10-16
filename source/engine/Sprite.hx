package engine;

import flixel.FlxSprite;

@:enum abstract AnimType(String) from String to String {
    var PREFIX:AnimType = "PREFIX";
    var INDICES:AnimType = "INDICES";
}

typedef SpriteOptions = {
    var animated:Null<Bool>;
    var width:Null<Int>;
    var height:Null<Int>;
};

/**
    A sprite class that extends `FlxSprite`.

    Features:
    * Adding animations by prefix or indices in one function (including offsets!)
    * Loading graphics or sparrow/packer atlases in one function
**/
class Sprite extends FlxSprite {
    public var animOffsets:Map<String, Point> = [];

    public function addAnim(type:AnimType, name:String, prefix:String, fps:Int, loop:Bool = false, ?offsets:Point, ?indices:Array<Int>) {
        switch(type) {
            case PREFIX: animation.addByPrefix(name, prefix, fps, loop);
            case INDICES: animation.addByIndices(name, prefix, indices, "", fps, loop);
        }

        if(offsets != null)
            animOffsets.set(name, offsets);
        else
            animOffsets.set(name, {x:0, y:0});
    }

    public function setOffset(name:String, x:Float, y:Float) {
        animOffsets.set(name, {x:x, y:y});
    }

    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0) {
        if(animation.exists(AnimName))
            animation.play(AnimName, Force, Reversed, Frame);
        
        if(animOffsets.exists(AnimName))
            offset.set(animOffsets[AnimName].x, animOffsets[AnimName].y);
        else
            offset.set();
    }
    
    public function load(type:FunkinAssetType, path:String, ?options:SpriteOptions) {
        if(options == null) options = {
            animated: false,
            width: 0,
            height: 0
        };

        switch(type) {
            case IMAGE: loadGraphic(Assets.get(IMAGE, path), options.animated, options.width, options.height);
            case SPARROW: frames = Assets.get(SPARROW, path);
            case PACKER: frames = Assets.get(PACKER, path);
            default: trace('error', '$type can\'t be loaded in a sprite!');
        }
        return this;
    }

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
        antialiasing = Settings.get("Antialiasing");
    }
}
package base;

/**
 * An extension of `FlxSprite` with offsets for specific animations.
 */
class Sprite extends flixel.FlxSprite {
    public var offsets:Map<String, BasicPoint> = [];

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
        antialiasing = Settings.get("Antialiasing");
    }
    
    /**
     * A function to load certain types of assets onto this sprite.
     * @param type The asset type.
     * @param path The path to the asset.
     */
    public function load(type:base.assets.AssetType, path:String) {
        switch(type) {
            case IMAGE: loadGraphic(Assets.load(IMAGE, path));
            case SPARROW: frames = Assets.load(SPARROW, path);
            case PACKER: frames = Assets.load(PACKER, path);
            default:
                Console.error('$type isn\'t a valid type of image for this Sprite to load!');
        }
        return this;
    }

    override public function makeGraphic(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, unique:Bool = false, ?key:Null<String>):Sprite {
        return cast super.makeGraphic(width,height,color,unique,key);
    }

    public function addAnim(name:String, prefix:String, fps:Int = 24, loop:Bool = false, ?offsets:BasicPoint) {
        animation.addByPrefix(name, prefix, fps, loop);

        // offsets are inverted becuase flixel is like
        // forward = negative, negative = forward
        // by default
        if(offsets != null)
            this.offsets.set(name, {x: -offsets.x, y: -offsets.y});
        else
            this.offsets.set(name, {x: 0, y: 0});
    }

    public function addAnimByIndices(name:String, prefix:String, indices:Array<Int>, fps:Int = 24, loop:Bool = false, ?offsets:BasicPoint) {
        animation.addByIndices(name, prefix, indices, "", fps, loop);

        // offsets are inverted becuase flixel is like
        // forward = negative, negative = forward
        // by default
        if(offsets != null)
            this.offsets.set(name, {x: -offsets.x, y: -offsets.y});
        else
            this.offsets.set(name, {x: 0, y: 0});
    }

    public function setOffset(name:String, x:Float = 0, y:Float = 0) {
        // offsets are inverted becuase flixel is like
        // forward = negative, negative = forward
        // by default
        this.offsets.set(name, {x: -x, y: -y});
    }

    public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
        if(!animation.exists(name)) return #if debug Console.warn('Animation "$name" doesn\'t exist!') #end;
        animation.play(name, force, reversed, frame);
        if(offsets.exists(name))
            offset.set(offsets[name].x, offsets[name].y);
        else
            offset.set(0, 0);
    }
}
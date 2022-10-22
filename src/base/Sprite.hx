package base;

class Sprite extends flixel.FlxSprite {
    public var offsets:Map<String, BasicPoint> = [];

    public function new(x:Float, y:Float) {
        super(x, y);
        antialiasing = true;
    }
    
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

    public function addAnim(name:String, prefix:String, fps:Int = 24, loop:Bool = false, ?offsets:BasicPoint) {
        animation.addByPrefix(name, prefix, fps, loop);

        if(offsets != null)
            this.offsets.set(name, offsets);
        else
            this.offsets.set(name, {x: 0, y: 0});
    }

    public function addAnimByIndices(name:String, prefix:String, indices:Array<Int>, fps:Int = 24, loop:Bool = false, ?offsets:BasicPoint) {
        animation.addByIndices(name, prefix, indices, "", fps, loop);

        if(offsets != null)
            this.offsets.set(name, offsets);
        else
            this.offsets.set(name, {x: 0, y: 0});
    }

    public function setOffset(name:String, x:Float = 0, y:Float = 0) {
        this.offsets.set(name, {x: x, y: y});
    }

    public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
        if(!animation.exists(name)) return Console.warn('Animation "$name" doesn\'t exist!');
        animation.play(name, force, reversed, frame);
        offset.set(this.offsets[name].x, this.offsets[name].y);
    }
}
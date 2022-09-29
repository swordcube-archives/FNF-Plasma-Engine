package systems;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxCamera;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import hscript.HScript;

class ScriptedSprite extends FNFSprite {
    public var script:HScript;
    public var doesDefaultDraw = true;

    public function call(key:String, ?args:Array<Any>) {
        return script.call(key, args);
    }

    public function get(key:String) {
        return script.get(key);
    }

    public function set(key:String, val:Dynamic):Dynamic {
        script.set(key, val);
        return val;
    }

    override public function new(sprite:String, args:Array<Any>, X:Float = 0, Y:Float = 0) {
        super(X, Y);
        script = new HScript('objects/sprites/$sprite');
        script.setScriptObject(this);
        script.set('this', this);
        //for (i in Reflect.fields(this)) {
        //    script.set(i, Reflect.field(this, i));
        //}
        script.start(true, args);
    }

    override public function update(elapsed) {
        script.update(elapsed);
        super.update(elapsed);
        script.call('updatePost', [elapsed]);
    }

    override public function destroy() {
        script.call("destroy");
        super.destroy();
    }
    override public function draw() {
        script.call('draw');
        if (doesDefaultDraw)
            super.draw();
    }
}
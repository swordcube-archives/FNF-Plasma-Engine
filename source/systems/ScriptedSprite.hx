package systems;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxCamera;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import hscript.HScript;

class ScriptedSprite extends FNFSprite {
    public var script:HScript;

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

    override public function new(sprite:String, args:Array<Any>) {
        super(args[0],args[1]);
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
    override public function draw() {
        //if (script.call('draw') != false) {
            super.draw();
        //}
    }
    public override function destroy() {
        script.call("destroy");
        super.destroy();
    }



    // copied from yoshicrafter engine and edited to plasma's format

    public override function getGraphicMidpoint(?point:FlxPoint):FlxPoint {
        var v = script.call("getGraphicMidpoint", [point]);
        if (v != null) return v;
        return super.getGraphicMidpoint(point);
    }

    public override function getRotatedBounds(?newRect:FlxRect):FlxRect {
        var v = script.call("getRotatedBounds", [newRect]);
        if (v != null) return v;
        return super.getRotatedBounds(newRect);
    }

    public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
        var v = script.call("getScreenBounds", [newRect, camera]);
        if (v != null) return v;
        return super.getScreenBounds(newRect, camera);
    }

    public override function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool {
        var v:Null<Bool> = script.call("pixelsOverlapPoint", [point, Mask, Camera]);
        if (v != null) return v;
        return super.pixelsOverlapPoint(point, Mask, Camera);
    }

    public override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, width:Int = 0, height:Int = 0, unique:Bool = false, ?Key:String):FlxSprite {
        if (script.call("loadGraphic", [graphic, animated, width, height, unique, Key]) != false) {
            super.loadGraphic(graphic, animated, width, height, unique, Key);
        }
        return this;
    }
}
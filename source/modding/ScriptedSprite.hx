package modding;

import modding.Script;

class ScriptedSprite extends Sprite {
    public var script:Script;
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

    override public function new(sprite:String, args:Array<Any>, x:Float = 0, y:Float = 0) {
        super(x, y);
        script = Script.createScript('objects/sprites/$sprite');
        if(script.type == "hscript")
            cast(script, modding.HScript).setScriptObject(this);
        script.set('this', this);
        script.start(true, args);
    }

    override public function update(elapsed:Float) {
        script.call('update', [elapsed]);
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
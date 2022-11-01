package funkin;

import scripting.Script;
import scripting.HScriptModule;
import scripting.ScriptModule;

/**
 * A sprite that has a script attached to it.
 */
class ScriptedSprite extends Sprite {
    public var script:ScriptModule;
    public var doesDefaultDraw = true;

    /**
     * Calls a function on this sprite's script.
     * @param key The function to call.
     * @param args The arguments for the function.
     */
    public function call(key:String, args:Array<Any>) {
        return script.call(key, args);
    }

    /**
     * Returns a variable from this sprite's script.
     * @param key 
     */
    public function get(key:String) {
        return script.get(key);
    }

    /**
     * Sets a variable from this sprite's script
     * @param key The variable to modify.
     * @param val The value to set to.
     */
    public function set(key:String, val:Dynamic):Dynamic {
        script.set(key, val);
        return val;
    }

    override public function new(sprite:String, args:Array<Any>, X:Float = 0, Y:Float = 0) {
        super(X, Y);
        script = Script.create(Paths.script('data/scripts/objects/sprites/$sprite'));
        if(Std.isOfType(script, HScriptModule)) cast(script, HScriptModule).setScriptObject(this);
        script.set('this', this);
        script.start(true, args);
    }

    override public function update(elapsed) {
        script.call('onUpdate', [elapsed]);
        super.update(elapsed);
        script.call('onUpdatePost', [elapsed]);
    }

    override public function destroy() {
        script.call("destroy", []);
        super.destroy();
    }
    override public function draw() {
        script.call('draw', []);
        if (doesDefaultDraw)
            super.draw();
    }
}
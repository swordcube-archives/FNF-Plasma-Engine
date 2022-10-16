package scenes.subscenes;

import modding.HScript;
import modding.Script;

class ScriptedSubscene extends Subscene {
    public var script:Script;
    public var name:String;
    public var args:Array<Any>;

    public var allowSwitchingMods:Bool = true;

    public function new(name:String, ?args:Array<Any>) {
        super();
        this.name = name;
        this.args = args;
    }

    override function create() {
        super.create();
        script = Script.createScript('scenes/subscenes/$name');
        if(script.type == "hscript")
            cast(script, HScript).setScriptObject(this);
        script.set("substate", this);
        script.start(true, args);
    }

    override function update(elapsed:Float) {
        script.call("onUpdate", [elapsed]);
        script.call("update", [elapsed]);
        // if(allowSwitchingMods && FlxG.keys.justPressed.TAB)
        //     openSubState(new states.substates.ModSelection());
        super.update(elapsed);
        script.call("onUpdatePost", [elapsed]);
        script.call("updatePost", [elapsed]);
    }

    override function beatHit(curBeat:Int) {
        script.call("onBeatHit", [curBeat]);
        script.call("beatHit", [curBeat]);
        super.beatHit(curBeat);
        script.call("onBeatHitPost", [curBeat]);
        script.call("beatHitPost", [curBeat]);
    }

    override function stepHit(curStep:Int) {
        script.call("onStepHit", [curStep]);
        script.call("stepHit", [curStep]);
        super.stepHit(curStep);
        script.call("onStepHitPost", [curStep]);
        script.call("stepHitPost", [curStep]);
    }

    override function close() {
        script.call("close");
        super.close();
    }

    override function destroy() {
        script.call("destroy");
        super.destroy();
    }
}
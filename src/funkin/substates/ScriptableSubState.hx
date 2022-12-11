package funkin.substates;

import funkin.scripting.Script;

/**
 * An `FlxSubState` that is softcoded.
 * Also has access to `beatHit` and `stepHit` from `Conductor`.
 */
class ScriptableSubState extends FNFSubState {
    public var script:ScriptModule;

    /**
     * Initializes the substate and script.
     * @param script The path to the script.
     */
    public function new(script:String) {
        super();
        this.script = Script.load(Paths.script(script));
        this.script.setParent(this);
    }

    /**
     * Starts the script and calls `create` on it.
     */
    override function create() {
        script.run();
        super.create();
        script.createPostCall();
        Conductor.onBeat.add(beatHit);
        Conductor.onStep.add(stepHit);
    }

    /**
     * Updates the script and state.
     * @param elapsed The time between frames.
     */
    override function update(elapsed:Float) {
        script.updateCall(elapsed);
		super.update(elapsed);
        script.updatePostCall(elapsed);
	}

    /**
     * A function that gets called every beat.
     * @param beat The current beat.
     */
    function beatHit(beat:Int) {
		for(func in ["onBeatHit", "beatHit"]) {
			script.call(func, [beat]);
			script.call(func+"Post", [beat]);
        }
	}

    /**
     * A function that gets called every step.
     * @param step The current step.
     */
	function stepHit(step:Int) {
		for(func in ["onStepHit", "stepHit"]) {
			script.call(func, [step]);
			script.call(func+"Post", [step]);
		}
	}

    /**
     * A function that gets called when the substate is destroyed.
     */
     override public function destroy() {
        script.call("onDestroy");
        script.call("destroy");
        script.destroy();
        super.destroy();
    }
}
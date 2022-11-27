package funkin.states;

import funkin.scripting.Script;

/**
 * An `FlxState` that is softcoded.
 * Also has access to `beatHit` and `stepHit` from `Conductor`.
 */
class ScriptableState extends FNFState {
    public var script:ScriptModule;

    /**
     * Initializes the state and script.
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
        super.create();
        script.run();
        for(func in ["onCreatePost", "createPost"]) script.call(func);
        Conductor.onBeat.add(beatHit);
        Conductor.onStep.add(stepHit);
    }

    /**
     * Updates the script and state.
     * @param elapsed The time between frames.
     */
    override function update(elapsed:Float) {
        for(func in ["onUpdate", "update"]) script.call(func, [elapsed]);
		super.update(elapsed);
        for(func in ["onUpdatePost", "updatePost"]) script.call(func, [elapsed]);
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
}
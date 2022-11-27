package funkin.states;

import funkin.scripting.Script;

class ScriptableState extends FNFState {
    public var script:ScriptModule;

    public function new(script:String) {
        super();
        this.script = Script.load(Paths.script(script));
        this.script.setParent(this);
    }

    override function create() {
        super.create();
        script.run();
        for(func in ["onCreatePost", "createPost"]) script.call(func);
        Conductor.onBeat.add(beatHit);
        Conductor.onStep.add(stepHit);
    }

    override function update(elapsed:Float) {
        for(func in ["onUpdate", "update"]) script.call(func, [elapsed]);
		super.update(elapsed);
        for(func in ["onUpdatePost", "updatePost"]) script.call(func, [elapsed]);
	}

    function beatHit(beat:Int) {
		for(func in ["onBeatHit", "beatHit"]) {
			script.call(func, [beat]);
			script.call(func+"Post", [beat]);
        }
	}

	function stepHit(step:Int) {
		for(func in ["onStepHit", "stepHit"]) {
			script.call(func, [step]);
			script.call(func+"Post", [step]);
		}
	}
}
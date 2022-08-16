package substates;

import hscript.HScript;
import systems.Conductor;
import systems.MusicBeat;

class ModSubState extends MusicBeatState {
    var script:HScript;

    public function new(stateName:String)
    {
        super();

        script = new HScript('states/${stateName}');

        script.set("add", this.add);
        script.set("remove", this.remove);
        script.set("state", this);

        script.start();
        script.callFunction("createPost");
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        script.update(elapsed);
        script.callFunction("updatePost", [elapsed]);
    }

    override public function beatHit()
    {
        super.beatHit();

        script.callFunction("beatHit", [Conductor.currentBeat]);
    }

    override public function stepHit()
    {
        super.stepHit();

        script.callFunction("stepHit", [Conductor.currentStep]);
    }
}
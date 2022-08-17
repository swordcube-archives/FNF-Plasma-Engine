package substates;

import hscript.HScript;
import states.PlayState;
import systems.Conductor;
import systems.MusicBeat;

// Go to "assets/funkin/substates/PauseMenu.hxs" to edit the pause menu.
// Can be overridden by currently loaded pack btw.

class PauseMenu extends MusicBeatSubState {
    var script:HScript;

    public function new()
    {
        super();

        script = new HScript("substates/PauseMenu");

        script.set("add", this.add);
        script.set("remove", this.remove);
        script.set("substate", this);

        if(PlayState.current.countdownTimer != null)
            PlayState.current.countdownTimer.active = false;
    }

    override public function create()
    {
        super.create();

        script.start();
        script.call("createPost", []);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        script.update(elapsed);
        script.call("updatePost", [elapsed]);
    }

    override public function beatHit()
    {
        super.beatHit();

        script.call("beatHit", [Conductor.currentBeat]);
    }

    override public function stepHit()
    {
        super.stepHit();

        script.call("stepHit", [Conductor.currentStep]);
    }

    override function destroy()
    {
        if(PlayState.current.countdownTimer != null)
            PlayState.current.countdownTimer.active = true;

        script.call("destroy");
        super.destroy();
    }
}
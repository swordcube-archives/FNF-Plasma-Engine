package substates;

import hscript.HScript;
import states.PlayState;
import systems.Conductor;
import systems.MusicBeat;

// Go to "assets/funkin/substates/PauseMenu.hxs" to edit the pause menu.
// Can be overridden by currently loaded pack btw.

class PauseMenu extends MusicBeatSubState
{
    var script:HScript;

    public function new()
    {
        super();

        script = new HScript("substates/PauseMenu");

        script.setVariable("add", this.add);
        script.setVariable("remove", this.remove);
        script.setVariable("substate", this);

        if(PlayState.current.countdownTimer != null)
            PlayState.current.countdownTimer.active = false;
    }

    override public function create()
    {
        super.create();

        script.start();
        script.callFunction("createPost", []);
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

    override function destroy()
    {
        if(PlayState.current.countdownTimer != null)
            PlayState.current.countdownTimer.active = true;

        script.callFunction("destroy");
        super.destroy();
    }
}
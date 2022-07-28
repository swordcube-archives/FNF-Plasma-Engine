package states;

import hscript.HScript;
import systems.Conductor;
import systems.MusicBeat;

// Go to "assets/funkin/states/FreeplayMenu.hxs" to edit the title screen.
// Can be overridden by currently loaded pack btw.

class FreeplayMenu extends MusicBeatState
{
    var script:HScript;

    override public function create()
    {
        super.create();

        script = new HScript("states/FreeplayMenu");

        script.setVariable("add", this.add);
        script.setVariable("remove", this.remove);
        script.setVariable("state", this);
        
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

        script.callFunction("stepHit", [Conductor.currentBeat]);
    }
}
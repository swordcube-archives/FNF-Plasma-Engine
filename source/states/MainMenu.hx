package states;

import hscript.HScript;
import systems.Conductor;
import systems.MusicBeat;

// Go to "assets/funkin/states/MainMenu.hxs" to edit the main menu.
// Can be overridden by currently loaded pack btw.

class MainMenu extends MusicBeatState
{
    var script:HScript;
    
    override public function create()
    {
        super.create();

        script = new HScript("states/MainMenu");

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
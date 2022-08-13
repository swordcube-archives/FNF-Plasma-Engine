package states;

import flixel.FlxG;
import hscript.HScript;
import substates.KeybindMenu;
import systems.Conductor;
import systems.MusicBeat;

// Go to "assets/funkin/states/OptionsMenu.hxs" to edit the options menu.
// Can be overridden by currently loaded pack btw.

class OptionsMenu extends MusicBeatState {
    var script:HScript;

    override public function create()
    {
        super.create();

        script = new HScript("states/OptionsMenu");

        script.setVariable("add", this.add);
        script.setVariable("remove", this.remove);
        script.setVariable("state", this);
        
        script.start();
        script.callFunction("createPost");
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.D)
            openSubState(new KeybindMenu(4, true));

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
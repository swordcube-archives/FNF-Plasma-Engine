package states;

import flixel.FlxG;
import hscript.HScript;
import systems.Conductor;
import systems.MusicBeat;

// Go to "assets/funkin/states/MainMenu.hxs" to edit the main menu.
// Can be overridden by currently loaded pack btw.

class MainMenu extends MusicBeatState {
    var script:HScript;
    
    override public function create()
    {
        super.create();

        script = new HScript("states/MainMenu");

        script.set("add", this.add);
        script.set("remove", this.remove);
        script.set("state", this);
        
        script.start();
        script.callFunction("createPost");
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        // lazy hardcoded bullshit ik but it's gonna be removed when i add toolbox
        #if debug
        if(FlxG.keys.justPressed.D)
            Main.switchState(new CharacterEditor());
        #end

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
package substates;

import hscript.HScript;
import systems.Conductor;
import systems.MusicBeat;

// Go to "assets/funkin/substates/GameOver.hxs" to edit the game over.
// Can be overridden by currently loaded pack btw.

class GameOver extends ScriptedSubState {
    var character:String = "bf-dead";

    var x:Float = 0;
    var y:Float = 0;

    var camX:Float = 0;
    var camY:Float = 0;

    public function new(x:Float, y:Float, camX:Float, camY:Float, character:String)
    {
        super('GameOver');

        this.x = x;
        this.y = y;

        this.camX = camX;
        this.camY = camY;

        this.character = character;
    }

    override public function create()
    {
        super.create();

        script.start(false);
        script.call("create", [x, y, camX, camY, character]);
        script.call("createPost", [x, y, camX, camY, character]);
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
}
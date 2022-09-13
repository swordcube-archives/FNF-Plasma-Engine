package states;

import flixel.FlxG;
import hscript.HScript;
import systems.Conductor;
import systems.MusicBeat;

class ScriptedState extends MusicBeatState
{
    public var canSwitchMods:Bool = true;

    public var script:HScript;
    public var name:String;
    public var args:Array<Any> = [];

    public var logsOpen:Bool = false;

    override public function new(state:String, ?_args:Array<Any>)
    {
        super();
        if (FlxG.sound.music != null)
            FlxG.sound.music.onComplete = null;
        name = state;
        if (_args != null) args = _args;

        script = new HScript('states/$state');

        script.set("add", this.add);
        script.set("insert", this.insert);
        script.set("remove", this.remove);
        script.set("members", this.members);
        script.set("state", this);
    }

    override public function create() 
    {  
        super.create();
        script.start(true, args);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        script.update(elapsed);

		if(FlxG.keys.justPressed.F6 && !logsOpen)
		{
			logsOpen = true;
			openSubState(new substates.ScriptedSubState('Logs'));
		}

        if(canSwitchMods && FlxG.keys.justPressed.TAB)
            openSubState(new substates.ModSelectionMenu());
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
    override public function draw()
    {
        super.draw();
        script.call("draw");
    }
}
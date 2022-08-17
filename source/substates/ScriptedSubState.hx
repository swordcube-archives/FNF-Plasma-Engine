package substates;

import hscript.HScript;
import systems.Conductor;
import systems.MusicBeat;

class ScriptedSubState extends MusicBeatSubState
{
    public var script:HScript;
    public var name:String;
    public var args:Array<Any> = [];

    public function new(substate:String, ?_args:Array<Any>)
    {
        super();
        name = substate;
        if (_args != null) args = _args;

        script = new HScript('substates/$substate');

        script.set("add", this.add);
        script.set("insert", this.insert);
        script.set("remove", this.remove);
        script.set("members", this.members);
        script.set("substate", this);
    }

    override public function create() 
    {  
        super.create();
        script.start(false);
        script.call('create', args);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        script.update(elapsed);
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
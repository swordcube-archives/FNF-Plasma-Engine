package states;

import base.MusicBeat.MusicBeatState;
import hscript.HScript;

/**
    A class used for allowing mods to have custom states.
    All a user needs to do to make one is make a .hx file in the "states" folder of their mod.
    Then to switch to it, you do States.switchState(new ModState("stateName"))
**/
class ModState extends MusicBeatState
{
    public var stateScript:HScript;
    public var stateName:String = "";

    public function new(stateName:String)
    {
        super();
        this.stateName = stateName;
    }

    override public function create()
    {
        super.create();
        stateScript = new HScript('states/$stateName.hx');
        stateScript.state = this;
        stateScript.interp.variables.set("add", this.add);
        stateScript.interp.variables.set("remove", this.remove);
        stateScript.start();
        stateScript.callFunction("createPost");
    }
}
package scripting;

import funkin.states.substates.FunkinSubState;

class ScriptedSubState extends FunkinSubState {
    public var script:ScriptModule;
    public var name:String = "";
    public var args:Array<Any>;

    public function new(name:String, args:Array<Any>) {
        super();
        this.name = name;
        this.args = args;

        script = Script.create(Paths.script('data/states/substates/$name'));
        if(Std.isOfType(script, HScriptModule)) cast(script, HScriptModule).setScriptObject(this);
        script.start(true, args);
    }
}
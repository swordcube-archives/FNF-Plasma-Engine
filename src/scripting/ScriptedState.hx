package scripting;

import funkin.states.FunkinState;

class ScriptedState extends FunkinState {
    public var script:ScriptModule;
    public var name:String = "";
    public var args:Array<Any>;

    public function new(name:String, args:Array<Any>) {
        super();
        this.name = name;
        this.args = args;
    }

    override function create() {
		super.create();

		script = Script.create(Paths.script('data/states/$name'));
		if(Std.isOfType(script, HScriptModule)) cast(script, HScriptModule).setScriptObject(this);
		script.start(true, args);
    }
}
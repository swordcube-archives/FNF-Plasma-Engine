package funkin.options.screens;

import funkin.scripting.HScriptModule;
import funkin.scripting.events.SubStateCreationEvent;
import funkin.scripting.Script;
import funkin.options.types.NumberOption;
import funkin.options.types.BoolOption;
import funkin.options.types.ListOption;

class CustomScreen extends OptionScreen {
    public var menuName:String;

    public function new(menuName:String) {
        super();
        this.menuName = menuName;
    }

    override function create() {
        script = Script.load(Paths.script('data/substates/options/$menuName'));
		script.setParent(this);
        switch(script.scriptType) {
            case HScript:
                var casted:HScriptModule = cast script;
                casted.addClasses([BoolOption, NumberOption, ListOption]);
            default: // add more here yourself
        }
		script.run(false);
		script.event("onSubStateCreation", new SubStateCreationEvent(this));
        categories = [];
        script.call("onAddCategories");
        options = [];
        script.call("onAddOptions");
        super.create();
        script.event("onSubStateCreationPost", new SubStateCreationEvent(this));
    }

    override function update(elapsed:Float) {
        for(func in ["onUpdate", "update"]) script.call(func, [elapsed]);
        super.update(elapsed);
        for(func in ["onUpdate", "update"]) script.call(func+"Post", [elapsed]);
    }
}
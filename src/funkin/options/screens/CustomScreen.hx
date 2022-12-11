package funkin.options.screens;

import funkin.options.types.MenuOption;
import funkin.scripting.HScriptModule;
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
                casted.addClasses([BoolOption, NumberOption, ListOption, MenuOption]);
            default: // add more here yourself
        }
		script.run();
        categories = [];
        script.call("onAddCategories");
        options = [];
        script.call("onAddOptions");
        super.create();
        script.createPostCall();
    }

    override function update(elapsed:Float) {
        script.updateCall(elapsed);
        super.update(elapsed);
        script.updatePostCall(elapsed);
    }
}
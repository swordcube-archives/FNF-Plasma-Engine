package scripting;

import haxe.io.Path;

class Script {
    public static function create(path:String):ScriptModule {
        switch(Path.extension(path)) {
            case "hx", "hxs", "hsc", "hscript":
                return new HScriptModule(path);
        }

        return new ScriptModule(path);
    }
}
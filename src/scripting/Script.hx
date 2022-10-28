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

class ScriptGroup {
    public var scripts:Array<ScriptModule> = [];
    
    public function new(?scripts:Array<ScriptModule>) {
        if(scripts == null) scripts = [];
        for(s in scripts) {
            addScript(s);
        }
    }

    public function addScript(script:ScriptModule) {
        if(Std.isOfType(script, HScriptModule))
            script.set("scriptGroup", this);
        scripts.push(script);
    }

    public function removeScript(script:ScriptModule) {
        scripts.remove(script);
        script.destroy();
    }

    public function call(name:String, args:Array<Any>, ?defaultReturnVal:Any) {
        var a = args;
        if (a == null) a = [];
        for (script in scripts) {
            var returnVal = script.call(name, a);
            if (returnVal != defaultReturnVal && defaultReturnVal != null) {
                return returnVal;
            }
        }
        return defaultReturnVal;
    }

    public function callMultiple(name:String, args:Array<Any>, ?defaultReturnVal:Array<Any>) {
        var a = args;
        if (a == null) a = [];
        if (defaultReturnVal == null) defaultReturnVal = [null];
        for (script in scripts) {
            var returnVal = script.call(name, a);
            if (!defaultReturnVal.contains(returnVal)) {
                return returnVal;
            }
        }
        return defaultReturnVal[0];
    }

    public function set(name:String, val:Dynamic) {
        for (script in scripts) script.set(name, val);
    }

    public function setFunc(name:String, val:Dynamic) {
        for (script in scripts) script.setFunc(name, val);
    }

    public function get(name:String, defaultReturnVal:Any) {
        for (script in scripts) {
            var variable = script.get(name);
            if (variable != defaultReturnVal) {
                return variable;
            }
        }
        return defaultReturnVal;
    }

    public function destroy() {
        for(script in scripts) script.destroy();
        scripts = [];
    }
}
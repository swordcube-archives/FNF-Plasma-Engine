package modding;

class ModClass {
    public var script:Script;
    public var name:String;

    public var variables:Map<String, Dynamic> = [];

    public function new(name:String, ?args:Array<Any>) {
        this.name = name;
        script = Script.createScript('classes/$name', null, true);
        if(script.type == "hscript") {
            var _script = cast(script, HScript);
            _script.set("get", function(variable:String) {
                return _script.interp.variables.get(variable);
            });
            _script.set("set", function(variable:String, value:Dynamic) {
                _script.interp.variables.set(variable, value);
            });
            _script.set("call", function(func:String, ?args:Null<Array<Any>>) {
                if (_script.interp.variables.exists(func)) {
                    try {
                        var f = _script.interp.variables.get(func);
                        if (args == null)
                            return f();
                        else
                            return Reflect.callMethod(null, f, args);
                    } catch (e) {
                        trace(e.details());
                        trace(name + ": ERROR Caused in " + func + " with " + Std.string(args) + " args");
                    }
                }
                return true;
            });
        }
        script.start();
    }

    public function get(variable:String):Dynamic {
        if(script.type == "hscript") {
            var _script = cast(script, HScript);
            return _script.interp.variables.get(variable);
        }
        return null;
    }

    public function set(variable:String, value:Dynamic) {
        if(script.type == "hscript") {
            var _script = cast(script, HScript);
            _script.interp.variables.set(variable, value);
        }
    }

    public function call(func:String, ?args:Null<Array<Any>>):Dynamic {
        if(script.type == "hscript") {
            var _script = cast(script, HScript);
            if (_script.interp.variables.exists(func)) {
                try {
                    var f = _script.interp.variables.get(func);
                    if (args == null)
                        return f();
                    else
                        return Reflect.callMethod(null, f, args);
                } catch (e) {
                    trace(e.details());
                    trace(name + ": ERROR Caused in " + func + " with " + Std.string(args) + " args");
                }
            }
            return true;
        }
        return true;
    }
}
package modding;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.io.Path;
import sys.FileSystem;

class Script implements IFlxDestroyable {
    public var type:String = "unknown";

    public static var classes:Map<String, ModClass> = [];
    public static var staticVars:Map<String, Dynamic> = [];
    
    public function new(path:String) {}
    public function get(name:String):Dynamic {return null;}
    public function set(name:String, value:Dynamic) {}
    public function start(create:Bool = true, ?args:Array<Any>) {}
    public function setFunction(name:String, value:Dynamic) {}
    public function call(name:String, ?args:Array<Any>):Dynamic {
        for(s in otherScripts) s.call(name, args);
        return true;
    }

    public var otherScripts:Map<String, Script> = [];

    public static function createScript(path:String, ?mod:Null<String>, isClass:Bool = false):Script {
        for(e in Main.supportedFileTypes) {
            var p:String = Paths.path(path+e, mod);
            var ext:String = Path.extension(p);

            if(FileSystem.exists(p)) {
                switch(ext.toLowerCase()) {
                    case 'hx', 'hxs', 'hsc', 'hscript':
                        var script:HScript = new HScript(path);
                        // i have an idea for classes but i'ma do that later teehee
                        // if(!isClass) {
                        //     for(item in CoolUtil.readDirectory('classes')) {
                        //         var extShit:String = "."+Path.extension(item);
                        //         var className:String = item.split(extShit)[0];
                        //         script.set(className, new ModClass(className));
                        //     }
                        // }
                        return script;
                    #if LUA_ALLOWED
                    case 'lua':
                        return new LuaScript(path);
                    #end
                }
            }
        }

        return new Script("");
    }

    public function destroy() {}
}

class ScriptGroup {
    public var scripts:Array<Script> = [];
    
    public function new(scripts:Array<Script>) {
        for(s in scripts) {
            addScript(s);
        }
    }

    public function addScript(script:Script) {
        if(script.type == "hscript")
            script.set("scriptGroup", this);
        scripts.push(script);
    }

    public function removeScript(script:Script) {
        scripts.remove(script);
        script.destroy();
    }

    public function call(name:String, ?args:Array<Any>, ?defaultReturnVal:Any, ?haxeOnlyArgs:Array<Any>) {
        var a = args;
        if (a == null) a = [];
        
        for (script in scripts) {
            var returnVal = script.call(name, (haxeOnlyArgs != null && script.type == "hscript") ? haxeOnlyArgs : a);
            if (returnVal != defaultReturnVal && defaultReturnVal != null) {
                return returnVal;
            }
        }

        return defaultReturnVal;
    }

    public function callMultiple(name:String, ?args:Array<Any>, ?defaultReturnVal:Array<Any>, ?haxeOnlyArgs:Array<Any>) {
        var a = args;
        if (a == null) a = [];
        if (defaultReturnVal == null) defaultReturnVal = [null];
        for (script in scripts) {
            var returnVal = script.call(name, (haxeOnlyArgs != null && script.type == "hscript") ? haxeOnlyArgs : a);
            if (!defaultReturnVal.contains(returnVal)) {
                return returnVal;
            }
        }
        return defaultReturnVal[0];
    }

    public function set(name:String, val:Dynamic) {
        for (script in scripts) script.set(name, val);
    }

    public function setFunction(name:String, val:Dynamic) {
        for (script in scripts) script.setFunction(name, val);
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
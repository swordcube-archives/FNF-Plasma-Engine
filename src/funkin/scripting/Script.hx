package funkin.scripting;

import funkin.scripting.events.SimpleNoteEvent;
import funkin.scripting.events.NoteHitEvent;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import funkin.scripting.events.CancellableEvent;
import haxe.io.Path;

/**
 * The type a script can have. EmptyScript is used for scripts that couldn't load.
 */
@:enum abstract ScriptType(String) from String to String {
    var HScript = "HScript";
    var LuaScript = "LuaScript";
    var PythonScript = "PythonScript";
    var EmptyScript = "EmptyScript";
}

class Script {
    /**
     * Returns a `ScriptModule` instance with code loaded from `path`.
     * @param path
     * @return ScriptModule
     */
    public static function load(path:String, ?forcefulCode:Null<String>):ScriptModule {
        if(FileSystem.exists(path) || forcefulCode != null) {
            var ext:String = forcefulCode != null ? path : Path.extension(path);
            switch(ext) {
                case 'hx', 'hxs', 'hsc', 'hscript':
                    return new HScriptModule(path, forcefulCode);
                #if LUA_ALLOWED
                case 'lua':
                    return new LuaModule(path, forcefulCode);
                #end
            }
        }
        // Oops! The script couldn't load so we just load an empty one instead!
        return new ScriptModule("");
    }
}

/**
 * A placeholder script used for if a script couldn't load.
 * 
 * Extend this class to add support for languages like **Python** and **Lua**.
 */
class ScriptModule implements IFlxDestroyable {
    public var path:String = "";
    public var code:String = "";
    public var scriptType:ScriptType = EmptyScript;
    public var running:Bool = false;

    // use the create function so you don't have to do super lmao
	@:noCompletion public function new(path:String, ?forcefulCode:Null<String>) {
        if(forcefulCode != null) {
            this.path = "Preloaded code";
            this.code = forcefulCode;
        } else {
            this.path = path;
            this.code = Assets.load(TEXT, path);
        }
        create();
    }

    function create():Void {}
    public function get(name:String):Dynamic {return null;}
    public function set(name:String, value:Dynamic):Void {}
    public function setFunc(name:String, value:Dynamic):Void {}
    public function call(func:String, ?args:Array<Dynamic>):Dynamic {return null;}
    public function run(callCreate:Bool = true, ?args:Array<Dynamic>):Void {}
    public function setParent(parent:Dynamic):Void {}
    public function createCall(?args:Array<Dynamic>):Void {}
    public function updateCall(delta:Float):Void {}
    public function createPostCall(?args:Array<Dynamic>):Void {}
    public function updatePostCall(delta:Float):Void {}

    public function event(func:String, event:CancellableEvent) {
        switch(this.scriptType) {
            case HScript:
                this.call(func, [event]);
            case LuaScript:
                // this is dumb as hell but lua is mental pain on whole new levels
                var args:Array<Dynamic> = [];
                switch(Type.getClass(event)) {
                    case NoteHitEvent:
                        var event:NoteHitEvent = cast event;
                        args = [
                            event.cancelled,
                            event.note.strumTime, event.note.direction, event.note.isSustainNote, event.note.mustPress,
                            event.note.parent.notes.members.indexOf(event.note), event.rating, 
                            event.note.type
                        ];
                    case SimpleNoteEvent:
                        var event:SimpleNoteEvent = cast event;
                        args = [
                            event.cancelled,
                            event.note.strumTime, event.note.direction, event.note.isSustainNote, event.note.mustPress,
                            event.note.parent.notes.members.indexOf(event.note), 
                            event.note.type
                        ];
                }
                var ret:Dynamic = this.call(func, args);
                if(ret == false)
                    event.cancel();
            default: // gah
        }
        return event;
    }

    public function destroy() {}
}


class ScriptGroup {
    public var scripts:Array<ScriptModule> = [];
    
    public function new(?scripts:Array<ScriptModule>) {
        if(scripts == null) scripts = [];
        for(s in scripts) addScript(s);
    }

    public function addScript(script:ScriptModule) {
        if(script.scriptType == HScript) script.set("scriptGroup", this);
        scripts.push(script);
    }

    public function containsScript(script:ScriptModule) {
        return scripts.contains(script);
    }

    public function removeScript(script:ScriptModule) {
        scripts.remove(script);
    }

    public function call(name:String, ?args:Array<Dynamic>, ?defaultReturnVal:Any, ?isNotBuiltIn:Bool = false) {
        var a = args;
        if (a == null) a = [];
        for (script in scripts) {
            var returnVal = script.call(name, a);
            if (returnVal != defaultReturnVal && defaultReturnVal != null) return returnVal;
        }
        return defaultReturnVal;
    }

    public function createCall() {
        for(script in scripts)
            script.createCall();
    }
    public function createPostCall() {
        for(script in scripts)
            script.createPostCall();
    }
    public function updateCall(delta:Float) {
        for(script in scripts)
            script.updateCall(delta);
    }
    public function updatePostCall(delta:Float) {
        for(script in scripts)
            script.updatePostCall(delta);
    }

    public function event(func:String, event:CancellableEvent, ?excludeScripts:Array<ScriptModule>) {
        if(excludeScripts == null) excludeScripts = [];
        for(e in scripts) {
            if(!excludeScripts.contains(e)) e.event(func, event);
            if (event.cancelled) break;
        }
        return event;
    }

    public function callMultiple(name:String, ?args:Array<Dynamic>, ?defaultReturnVal:Array<Any>) {
        var a = args;
        if (a == null) a = [];
        if (defaultReturnVal == null) defaultReturnVal = [null];
        for (script in scripts) {
            var returnVal = script.call(name, a);
            if (!defaultReturnVal.contains(returnVal)) return returnVal;
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
            if (variable != defaultReturnVal) return variable;
        }
        return defaultReturnVal;
    }

    public function destroy() {
        for(script in scripts) script.destroy();
        scripts = [];
    }
}
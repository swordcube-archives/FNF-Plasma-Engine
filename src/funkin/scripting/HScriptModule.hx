package funkin.scripting;

import funkin.scripting.hscript.HScriptUtil;
import sys.io.Process;
import funkin.system.ModData;
import funkin.states.PlayState;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import funkin.scripting.Script.ScriptModule;

/**
 * A class for making scripts with HScript.
 */
class HScriptModule extends ScriptModule {
    var parser:Parser = new Parser();
    var program:Expr;
    var interp:Interp = new Interp();

    override function create() {
        #if !docs
        this.scriptType = HScript;
        this.running = true;

        parser.allowTypes = true;
        parser.allowJSON = true;
        parser.allowMetadata = true;

        interp.errorHandler = _errorHandler;

        // Allow unsafe shit to be imported depending on if
        // "Allow unsafe mods" is on in Settings.
        if(ModData.allowUnsafeScripts)
            addClasses([Sys, File, FileSystem, Process]);
        else {
            interp.importBlocklist = [
                "Sys",
                "sys.io.File",
                "sys.io.Process",
                "sys.FileSystem"
            ];
            addClassesAsNull([Sys, File, FileSystem, Process]);
        }
        
        // Default imports
        set("scriptModule", this);
        set("importScript", function(path:String) {
            var script:ScriptModule = Script.load(Paths.script(path));
            script.run(false);
            @:privateAccess {
                switch(Type.getClass(script)) {
                    case HScriptModule:
                        var casted:HScriptModule = cast script;
                        for(name=>value in casted.interp.variables)
                            set(name, value);
                        
                    case LuaModule:
                        var casted:LuaModule = cast script;
                        for(name=>value in casted.variables)
                            set(name, value);
                        
                        for(name=>value in casted.functions)
                            set(name, value);
                }
            }
            script.destroy();
        });
        set("loadScript", function(path:String, ?autoRun:Bool = false) {
            var script:ScriptModule = Script.load(Paths.script(path));
            if(autoRun) script.run();
            return script;
        });

        for(key => value in HScriptUtil.getDefaultImports())
            set(key, value);

        try {
            program = parser.parseString(code);
        } catch(e:Error) {
            _errorHandler(e);
        } catch(e) {
            _errorHandler(new Error(ECustom(e.toString()), 0, 0, path, 0));
        }
        #end
    }

    #if !docs
    function _errorHandler(error:Error) {
        Console.error('$path - Line ${error.line}: ${error.toString()}');
    }
    #end

    /**
     * Runs the script.
     * @param callCreate Whether or not to call a `create` function when this script runs.
     * @param args The arguments for the `create` function, Defaults to an empty array if not specified or null.
     */
    override public function run(callCreate:Bool = true, ?args:Array<Dynamic>) {
        try {
            if(program != null)
                interp.execute(program);
        } catch(e) {
            Console.error(e.details());
            running = false;
            destroy();
        }
        if(callCreate && running) {
            createCall(args);
        }
    }

    override public function createCall(?args:Array<Dynamic>) {
        call("onCreate", args);
        call("create", args);
        call("new", args);
    }
    override public function createPostCall(?args:Array<Dynamic>) {
        call("onCreatePost", args);
        call("createPost", args);
        call("newPost", args);
    }
    override public function updateCall(delta:Float) {
        call("onUpdate", [delta]);
        call("update", [delta]);
    }
    override public function updatePostCall(delta:Float) {
        call("onUpdatePost", [delta]);
        call("updatePost", [delta]);
    }

    /**
     * Returns a variable from this script.
     * @param name The name of the variable.
     * @return Dynamic
     */
    override public function get(name:String):Dynamic {
        if(!running) return null;
        return interp.variables.get(name);
    }

    /**
     * Sets a variable from this script to a given variable.
     * @param name 
     * @param value 
     */
    override public function set(name:String, value:Dynamic):Void {
        if(!running) return;
        interp.variables.set(name, value);
    }

    override public function setParent(value:Dynamic):Void {
        if(!running) return;        
        interp.scriptObject = value;
    }

    override public function call(funcName:String, ?args:Array<Dynamic>):Dynamic {
        if(args == null) args = [];
        if(!running) return true;
        try {
            var func:Dynamic = interp.variables.get(funcName);
            if(func != null && Reflect.isFunction(func)) {
                if(args != null && args.length > 0)
                    return Reflect.callMethod(null, func, args);
                else
                    return func();
            }
        } catch(e) {
            Console.error(e.details());
        }
        return true;
    }
    
    override public function destroy() {
        scriptType = EmptyScript;
        running = false;
        interp = null;
        program = null;
        parser = null;
    }

    public function addClass(c:Class<Dynamic>) {
        var array = Type.getClassName(c).split(".");
        set(array[array.length-1], c);
    }

    public function addClasses(a:Array<Class<Dynamic>>) {
        for(c in a) addClass(c);
    }

    public function addClassAsNull(c:Class<Dynamic>) {
        var array = Type.getClassName(c).split(".");
        set(array[array.length-1], null);
    }

    public function addClassesAsNull(a:Array<Class<Dynamic>>) {
        for(c in a) addClassAsNull(c);
    }
}

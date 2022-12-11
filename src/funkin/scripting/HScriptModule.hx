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
        this.scriptType = HScript;
        this.running = true;

        parser.allowTypes = true;
        parser.allowJSON = true;
        parser.allowMetadata = true;

        interp.errorHandler = function(e:hscript.Error) {
            #if debug
            Console.error(e);
            #end
            this.scriptType = EmptyScript;
            this.running = false;
            var posInfo = interp.posInfos();
            var lineNumber = Std.string(posInfo.lineNumber);
            var methodName = posInfo.methodName;
            Console.error('Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nScript File: $path');
        }

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

        for(key => value in HScriptUtil.getDefaultImports())
            set(key, value);
    }

    /**
     * Runs the script.
     * @param callCreate Whether or not to call a `create` function when this script runs.
     * @param args The arguments for the `create` function, Defaults to an empty array if not specified or null.
     */
    override public function run(callCreate:Bool = true, ?args:Array<Dynamic>) {
        try {
            running = true;
            program = parser.parseString(code);
            interp.execute(program);
        } catch(e) {
            scriptType = EmptyScript;
            callCreate = false;
            Console.error(e.details());
            running = false;
        }
        if(callCreate) {
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
            if(func != null && Reflect.isFunction(func)) return Reflect.callMethod(null, func, args);
        } catch(e) {
            scriptType = EmptyScript;
            Console.error(e.details());
            running = false;
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

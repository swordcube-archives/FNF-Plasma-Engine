package scripting;

import flixel.group.FlxGroup;
import funkin.gameplay.NoteSplash;
import funkin.gameplay.Note;
import funkin.gameplay.StrumLine;
import funkin.ModPackData.GlobalModShit;
import sys.io.Process;
import flixel.util.FlxAxes;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.states.PlayState;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import hscript.Interp;
import hscript.Parser;
import hscript.Expr;

class HScriptModule extends ScriptModule {
    var parser:Parser = new Parser();
    var program:Expr;
    var interp:Interp = new Interp();

    public var scriptPath:String = "";
    public var code:String = "";
    public var running:Bool = true;

    /**
     * Controls what happens when this script is created.
     * @param scriptPath The path to the code to load.
     */
    override function create(scriptPath:String) {
        this.scriptPath = scriptPath;
        code = Assets.load(TEXT, scriptPath);

        parser.allowTypes = true; // Allow typing of things like: var sprite:FlxSprite;
        parser.allowJSON = true; // Dunno what this does but uh yes.
        parser.allowMetadata = true; // Dunno what this does but uh yes #2.

        // Error handling
        interp.errorHandler = function(e:hscript.Error) {
            #if debug
            Console.error(e);
            #end
            var posInfo = interp.posInfos();
            var lineNumber = Std.string(posInfo.lineNumber);
            var methodName = posInfo.methodName;
            Console.error('Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nScript File: $scriptPath');
        }

        // Setting up (Classes & Abstracts)
        // Haxe
        addClasses([Main, Std, Math, String, StringTools]);
        if(GlobalModShit.allowUnsafeScripts)
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
        set("Json", {
            "parse": function(data:String) {return TJSON.parse(data);},
            "stringify": function(data:Dynamic, thing:String = "\t") {return TJSON.encode(data, thing == "\t" ? "fancy" : null);}
        });
        set("Reflect", Reflect);
        set("scriptModule", this);
        // Flixel
        set("FlxColor", HScriptClasses.get_FlxColor());
        set("FlxKey", HScriptClasses.get_FlxKey());
        set("FlxAxes", FlxAxes);
        set("FlxGroup", FlxGroup);
        addClasses([FlxG, FlxSprite, FlxMath, FlxTween, FlxEase]);
        // Funkin
        addClasses([Paths, Assets, Sprite, Settings, CoolUtil, Controls]);
        addClasses([Conductor, StrumLine, StrumNote, Note, NoteSplash]);
        set("PlayState", PlayState.current);
        set("PlayState_", PlayState);
        // Abstracts
	    set("Array", Array);
        set("Float", Float);
        set("Int", Int);
        set("Bool", Bool);
        set("Dynamic", Dynamic);
    }
    /**
     * Starts the script.
     * @param create Whether or not an `onCreate()` function should be called.
     * @param args The arguments for the `onCreate()` function.
     */
    override public function start(create:Bool = true, args:Array<Any>) {
        try {
            running = true;
            program = parser.parseString(code);
            interp.execute(program);
        } catch(e) {
            create = false;
            Console.error(e.details());
            running = false;
        }
        if(create) {
            call("onCreate", args);
            call("create", args);
        }
    }
    public function setScriptObject(o:Dynamic) {
        interp.scriptObject = o;
    }
    function addClass(c:Class<Dynamic>) {
        var array = Type.getClassName(c).split(".");
        set(array[array.length-1], c);
    }
    function addClassAsNull(c:Class<Dynamic>) {
        var array = Type.getClassName(c).split(".");
        set(array[array.length-1], null);
    }
    function addClasses(a:Array<Class<Dynamic>>) {
        for(c in a) addClass(c);
    }
    function addClassesAsNull(a:Array<Class<Dynamic>>) {
        for(c in a) addClassAsNull(c);
    }
    /**
     * Gets a variable from this script.
     * @param variable The variable name.
     * @return Dynamic
     */
    override public function get(variable:String) {
        return interp.variables.get(variable);
    }
    /**
     * Sets a variable from this script to `value`.
     * @param variable The variable name.
     * @param value The value of the variable.
     */
    override public function set(variable:String, value:Dynamic) {
        interp.variables.set(variable, value);
    }
    /**
     * Sets a function from this script to `value`.
     * @param funcName The function name.
     * @param value The function to use.
     */
    override public function setFunc(variable:String, value:Dynamic) {
        set(variable, value);
    }
    /**
     * Calls a function from the script.
     * @param funcName The name of the function to be called.
     * @param args The arguments for the `onCreate()` function.
     */
    override public function call(funcName:String, args:Array<Any>):Dynamic {
        if(!running) return true;
        try {
            var func:Dynamic = interp.variables.get(funcName);
            if(func != null) return Reflect.callMethod(null, func, args);
        } catch(e) {
            Console.error(e.details());
            running = false;
        }
        return true;
    }
    override public function destroy() {
        running = false;
        interp = null;
        program = null;
        parser = null;
    }
}
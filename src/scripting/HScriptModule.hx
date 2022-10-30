package scripting;

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

    public var code:String = "";

    public var running:Bool = true;

    /**
     * Controls what happens when this script is created.
     * @param scriptPath The path to the code to load.
     */
    override function create(scriptPath:String) {
        code = Assets.load(TEXT, scriptPath);

        parser.allowTypes = true; // Allow typing of things like: var sprite:FlxSprite;
        parser.allowJSON = true; // Dunno what this does but uh yes.
        parser.allowMetadata = true; // Dunno what this does but uh yes #2.

        // Setting up (Classes & Abstracts)
        // Haxe
        addClasses([Sys, FileSystem, Std, Math, String, StringTools]);
        set("Json", {
            "parse": function(data:String) {return TJSON.parse(data);},
            "stringify": function(data:Dynamic, thing:String = "\t") {return TJSON.encode(data, thing == "\t" ? "fancy" : null);}
        });
        // Flixel
        addClasses([FlxG, FlxSprite, FlxMath]);
        // Funkin
        addClasses([Sprite, Settings, CoolUtil, Controls, Main, Conductor]);
        set("PlayState", PlayState.current);
        set("PlayState_", PlayState);
        // Abstracts
        set("Float", Float);
        set("Int", Int);
        set("Bool", Bool);
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
            Console.error(e.details());
            running = false;
        }
        if(create)
            call("onCreate", [this]);
    }
    public function setScriptObject(o:Dynamic) {
        interp.scriptObject = o;
    }
    function addClass(c:Class<Dynamic>) {
        var array = Type.getClassName(c).split(".");
        set(array[array.length-1], c);
    }
    function addClasses(a:Array<Class<Dynamic>>) {
        for(c in a) addClass(c);
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
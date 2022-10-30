package scripting;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * A generic class to extend to add scripting support for other languages 
 * like **Lua** and **Python**.
 */
class ScriptModule implements IFlxDestroyable {
    // Use the create() function so you're not forced to use super
    @:noCompletion public function new(scriptPath:String) {create(scriptPath);}

    /**
     * Override this to control what happens when this script is created.
     * @param scriptPath The path to the code to load.
     */
    public function create(scriptPath) {}
    /**
     * Starts the script.
     * @param create Whether or not an `onCreate()` function should be called.
     * @param args The arguments for the `onCreate()` function.
     */
    public function start(create:Bool = true, args:Array<Any>) {}
    /**
     * Gets a variable from this script.
     * @param variable The variable name.
     * @return Dynamic
     */
    public function get(variable:String):Dynamic {return null;}
    /**
     * Sets a variable from this script to `value`.
     * @param variable The variable name.
     * @param value The value of the variable.
     */
    public function set(variable:String, value:Dynamic) {}
    /**
     * Sets a function from this script to `value`.
     * @param funcName The function name.
     * @param value The function to use.
     */
    public function setFunc(funcName:String, value:Dynamic) {}
    /**
     * Calls a function from the script.
     * @param funcName The name of the function to be called.
     * @param args The arguments for the `onCreate()` function.
     */
    public function call(funcName:String, args:Array<Dynamic>):Dynamic {return false;}
    public function destroy() {}
}
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
    public function get(variable:String):Dynamic {return null;}
    public function set(variable:String, value:Dynamic) {}
    public function setFunc(funcName:String, value:Dynamic) {}
    public function call(funcName:String, args:Array<Dynamic>):Dynamic {return false;}
    public function destroy() {}
}
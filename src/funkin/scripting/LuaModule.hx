package funkin.scripting;

#if LUA_ALLOWED
import funkin.scripting.lua.LuaUtil;
import llua.Convert;
import funkin.scripting.Script.ScriptModule;
import llua.Lua;
import llua.LuaL;
import llua.State;

class LuaModule extends ScriptModule {
    var lua:State;

    override function create() {
        scriptType = LuaScript; // don't forget to set this lmao!!
        running = true;

        lua = LuaL.newstate();
        
        // Initialization
        LuaL.openlibs(lua);
        Lua.init_callbacks(lua);

        // Debug
        Console.debug("Lua version: " + Lua.version());
        Console.debug("LuaJIT version: " + Lua.versionJIT());
    }

    override public function get(name:String):Dynamic {
		if(lua == null) return null;
        return variables[name];
	}

    override public function set(name:String, value:Dynamic) {
		if(lua == null) return;
		Convert.toLua(lua, value);
		Lua.setglobal(lua, name);
        variables[name] = value;
	}

    var variables:Map<String, Dynamic> = [];
    var functions:Map<String, Dynamic> = [];
    override public function setFunc(func:String, value:Dynamic) {
        functions[func] = value;
		Lua_helper.add_callback(lua, func, value);
	}

    override public function run(callCreate:Bool = true, ?args:Array<Dynamic>) {
        try {
            running = true;
            LuaUtil.setScriptDefaults(this);
            var result:Dynamic = LuaL.dostring(lua, code);
            var resultStr:String = Lua.tostring(lua, result);
			if(resultStr != null && result != 0) {
				#if windows
				lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
				#else
				Console.error('Occured on LUA file: $path | $resultStr');
				#end
                running = false;
				lua = null;
				return;
			}
        } catch(e) {
            scriptType = EmptyScript;
            callCreate = false;
            Console.error(e.details());
            running = false;
            lua = null;
        }
        if(callCreate)
            createCall(args);
    }

    override public function call(func:String, ?args:Array<Dynamic>):Dynamic {
		if (lua == null) return true;
		if (args == null) args = [];

		try {
            Lua.settop(lua, 0);
			Lua.getglobal(lua, func);
            var type:Int = Lua.type(lua, -1);
            if (type != Lua.LUA_TFUNCTION) {
                if (functions[func] != null && Reflect.isFunction(functions[func]))
                    return Reflect.callMethod(null, functions[func], args);

                return true; // No function!! get fucked right up the ass
            }
            
            for (k=>val in args) {
                switch (Type.typeof(val)) {
                    case Type.ValueType.TNull:
                        Lua.pushnil(lua);
                    case Type.ValueType.TBool:
                        Lua.pushboolean(lua, val);
                    case Type.ValueType.TInt:
                        Lua.pushinteger(lua, cast(val, Int));
                    case Type.ValueType.TFloat:
                        Lua.pushnumber(lua, val);
                    case Type.ValueType.TClass(String):
                        Lua.pushstring(lua, cast(val, String));
                    case Type.ValueType.TClass(Array):
                        Convert.arrayToLua(lua, val);
                    case Type.ValueType.TObject:
                        @:privateAccess
                        Convert.objectToLua(lua, val);
                    default:
                }
            }
            
            if (Lua.pcall(lua, args.length, 1, 0) != 0) {
                var err = LuaUtil.getErrorMessage(lua);
                if(err != null) {
                    Console.error('Occured on LUA file: $path | $err');
                    return true;
                }
            }
    
            var value = Convert.fromLua(lua, Lua.gettop(lua));
            return value;
		}
		catch (e) {
			Console.error('Occured on LUA file: $path | ${e.details()}');
		}
		return true;
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

    override public function destroy() {
        scriptType = EmptyScript;
        running = false;
        Lua.close(lua);
        lua = null;
    }
}
#end
package funkin.scripting.lua;

import flixel.util.FlxTimer;
import openfl.display.BlendMode;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import funkin.states.PlayState;
import llua.Lua;
import llua.State;

using StringTools;

/**
 * A big sloppy mess of functions and/or variables for `LuaModule`.
 */
class LuaUtil {
    public static function setScriptDefaults(script:LuaModule) {
		// Variables
        script.set("engine", {
            "name": "Plasma Engine",
            "version": Main.engineVersion
        });

		// Functions
		var game = PlayState.current;
		for(i in 0...game.UI.opponentStrums.receptors.members.length) {
			var receptor = game.UI.opponentStrums.receptors.members[i];
			script.set("opponentReceptorPosX"+i, receptor.x);
			script.set("opponentReceptorPosY"+i, receptor.y+10);
		}
		for(i in 0...game.UI.playerStrums.receptors.members.length) {
			var receptor = game.UI.playerStrums.receptors.members[i];
			script.set("playerReceptorPosX"+i, receptor.x);
			script.set("playerReceptorPosY"+i, receptor.y+10);
		}

		script.setFunc("print", function(v:Dynamic) {
			Console.log(v);
		});
		script.setFunc("get", function(variable:String) {
			var result:Dynamic = null;
			var split:Array<String> = variable.split('.');
			if(split.length > 1)
				result = getVarInArray(getPropertyLoopThingWhatever(split), split[split.length-1]);
			else
				result = getVarInArray(PlayState.current, variable);

			@:privateAccess // don't you love it when private vars technically aren't private
			if(result == null) Lua.pushnil(script.lua);
			return result;
		});
		script.setFunc("getFromClass", function(className:String, variable:String) {
			@:privateAccess {
				var split:Array<String> = variable.split('.');
				if(split.length > 1) {
					var obj:Dynamic = getVarInArray(Type.resolveClass(className), split[0]);
					for (i in 1...split.length-1) obj = getVarInArray(obj, split[i]);
					
					return getVarInArray(obj, split[split.length-1]);
				}
				return getVarInArray(Type.resolveClass(className), variable);
			}
		});
		
		script.setFunc("set", function(variable:String, value:Dynamic) {
			var split:Array<String> = variable.split('.');
			if(split.length > 1) {
				setVarInArray(getPropertyLoopThingWhatever(split), split[split.length-1], value);
				return true;
			}
			setVarInArray(PlayState.current, variable, value);
			return true;
		});
		script.setFunc("setFromClass", function(className:String, variable:String, value:Dynamic) {
			@:privateAccess {
				var split:Array<String> = variable.split('.');
				if(split.length > 1) {
					var obj:Dynamic = getVarInArray(Type.resolveClass(className), split[0]);
					for (i in 1...split.length-1) obj = getVarInArray(obj, split[i]);
					
					setVarInArray(obj, split[split.length-1], value);
					return true;
				}
				setVarInArray(Type.resolveClass(className), variable, value);
				return true;
			}
		});

		// Sprite utilities
		script.setFunc("screenCenter", function(object:String, axes:String = "xy") {
			var spr:FlxSprite = getLuaObject(object);

			if(spr == null){
				var killMe:Array<String> = object.split('.');
				spr = getLuaObject(killMe[0]);
				if(killMe.length > 1) {
					spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
				}
			}

			if(spr != null) {
				switch(axes.toLowerCase().trim()) {
					case 'x': spr.screenCenter(X);
					case 'y': spr.screenCenter(Y);
					default:  spr.screenCenter(XY);
				}
			} else Console.error('Occured on LUA file: ${script.path} | Sprite/text named $object doesn\'t exist!');
		});

		script.setFunc("updateHitbox", function(object:String) {
			var spr:FlxSprite = getLuaObject(object);

			if(spr == null){
				var killMe:Array<String> = object.split('.');
				spr = getLuaObject(killMe[0]);
				if(killMe.length > 1) {
					spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
				}
			}

			if(spr != null) {
				spr.updateHitbox();
			} else Console.error('Occured on LUA file: ${script.path} | Sprite/text named $object doesn\'t exist!');
		});

		// Tweening & Timers
		script.setFunc("cancelTween", function(tag:String) {
			var gotten:Dynamic = game.luaVars[tag];
			if(gotten != null && gotten is FlxTween) {
				var tween:FlxTween = cast gotten;
				tween.cancel();
				tween.destroy();
				game.luaVars.remove(tag);
			}
		});

		script.setFunc("tweenObject", function(tag:String, obj:String, properties:Dynamic, duration:Float, ease:String, ?onComplete:Dynamic) {
			var gotten:Dynamic = game.luaVars[tag];
			if(gotten != null && gotten is FlxTween) {
				var tween:FlxTween = cast gotten;
				tween.cancel();
				tween.destroy();
				game.luaVars.remove(tag);
			}

			var spr:Dynamic = getLuaObject(obj);

			if(spr == null){
				var killMe:Array<String> = obj.split('.');
				spr = getLuaObject(killMe[0]);
				if(killMe.length > 1) {
					spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
				}
			}

			if(spr != null) {
				game.luaVars[tag] = FlxTween.tween(spr, properties, duration, {ease: easeFromString(ease), onComplete: function(twn) {
					if(onComplete != null) onComplete();
					PlayState.current.scripts.call("onTweenFinish", [tag]);
					PlayState.current.scripts.call("tweenFinish", [tag]);
				}});
			} else Console.error('Occured on LUA file: ${script.path} | Object named $obj doesn\'t exist!');
		});

		script.setFunc("cancelTimer", function(tag:String) {
			var gotten:Dynamic = game.luaVars[tag];
			if(gotten != null && gotten is FlxTimer) {
				var timer:FlxTimer = cast gotten;
				timer.cancel();
				timer.destroy();
				game.luaVars.remove(tag);
			}
		});

		script.setFunc("runTimer", function(tag:String, duration:Float, ?loops:Int = 1) {
			var gotten:Dynamic = game.luaVars[tag];
			if(gotten != null && gotten is FlxTimer) {
				var timer:FlxTimer = cast gotten;
				timer.cancel();
				timer.destroy();
				game.luaVars.remove(tag);
			}

			game.luaVars[tag] = new FlxTimer().start(duration, function(tmr) {
				PlayState.current.scripts.call("onTimerTick", [tag, tmr.loopsLeft]);
				PlayState.current.scripts.call("timerTick", [tag, tmr.loopsLeft]);
			}, loops);
		});

		// Controls
		script.setFunc("arrowJustPressed", function(direction:Int, ?keyAmount:Null<Int>) {
			if(keyAmount == null) keyAmount = PlayState.SONG.keyAmount;
			return PlayerSettings.controls.getP('GAME_$keyAmount', direction);
		});
		script.setFunc("arrowPressed", function(direction:Int, ?keyAmount:Null<Int>) {
			if(keyAmount == null) keyAmount = PlayState.SONG.keyAmount;
			return PlayerSettings.controls.get('GAME_$keyAmount', direction);
		});
		script.setFunc("arrowJustReleased", function(direction:Int, ?keyAmount:Null<Int>) {
			if(keyAmount == null) keyAmount = PlayState.SONG.keyAmount;
			return PlayerSettings.controls.getR('GAME_$keyAmount', direction);
		});

		script.setFunc("controlJustPressed", function(name:String) {
			return PlayerSettings.controls.getP(name);
		});
		script.setFunc("controlPressed", function(name:String) {
			return PlayerSettings.controls.get(name);
		});
		script.setFunc("controlJustReleased", function(name:String) {
			return PlayerSettings.controls.getR(name);
		});

		// Options
		script.setFunc("getOption", function(name:String) {
			return PlayerSettings.prefs.get(name);
		});
		script.setFunc("setOption", function(name:String, value:Dynamic) {
			return PlayerSettings.prefs.set(name, value);
		});
		script.setFunc("flushOptions", function() {
			return PlayerSettings.prefs.flush();
		});
		script.setFunc("reloadOptions", function() {
			return PlayerSettings.prefs.reload();
		});
    }

	public static function easeFromString(?ease:String = '') {
		switch(ease.toLowerCase().trim()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	public static function blendModeFromString(blend:String):BlendMode {
		switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
	}

	public static function getLuaObject(id:String):Dynamic {
		if (!PlayState.current.luaVars.exists(id))
			return Reflect.getProperty(PlayState.current, id);

		return PlayState.current.luaVars.get(id);
	}

	public static function getPropertyLoopThingWhatever(split:Array<String>, ?getProperty:Bool=true, ?instance:Dynamic):Dynamic {
		var obj:Dynamic = instance != null ? Reflect.getProperty(instance, split[0]) : getLuaObject(split[0]);
		
		var end = split.length;
		if(getProperty) end = split.length-1;

		for (i in 1...end) obj = getVarInArray(obj, split[i]);
		
		return obj;
	}

	public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic):Any {
		var shit:Array<String> = variable.split('[');
		if(shit.length > 1) {
			var blah:Dynamic = null;
			if(PlayState.current.luaVars.exists(shit[0])) {
				var retVal:Dynamic = PlayState.current.luaVars.get(shit[0]);
				if(retVal != null)
					blah = retVal;
			} else
				blah = Reflect.getProperty(instance, shit[0]);

			for (i in 1...shit.length) {
				var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
				if(i >= shit.length-1) //Last array
					blah[leNum] = value;
				else //Anything else
					blah = blah[leNum];
			}
			return blah;
		}
			
		if(PlayState.current.luaVars.exists(variable)) {
			PlayState.current.luaVars.set(variable, value);
			return true;
		}

		Reflect.setProperty(instance, variable, value);
		return true;
	}

	public static function getVarInArray(instance:Dynamic, variable:String):Any {
		var shit:Array<String> = variable.split('[');
		if(shit.length > 1) {
			var blah:Dynamic = null;
			if(PlayState.current.luaVars.exists(shit[0])) {
				var retVal:Dynamic = PlayState.current.luaVars.get(shit[0]);
				if(retVal != null)
					blah = retVal;
			}
			else {
				blah = Reflect.getProperty(instance, shit[0]);
				var getterFunc:Dynamic = Reflect.getProperty(instance, "get_"+shit[0]);
				if(getterFunc != null) blah = getterFunc();
			}

			for (i in 1...shit.length) {
				var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
				blah = blah[leNum];
			}
			return blah;
		}

		if(PlayState.current.luaVars.exists(variable)) {
			var retVal:Dynamic = PlayState.current.luaVars.get(variable);
			if(retVal != null)
				return retVal;
		}

		var getterFunc:Dynamic = Reflect.getProperty(instance, "get_"+variable);
		if(getterFunc != null) return getterFunc();

		return Reflect.getProperty(instance, variable);
	}

    public static function getErrorMessage(lua:State) {
		if(lua == null) return null;
		var v:String = Lua.tostring(lua, -1);
		if(!isErrorAllowed(v)) v = null;
		return v;
	}

	public static function resultIsAllowed(leLua:State, leResult:Null<Int>) {
		if(leLua == null) return true;
		var type:Int = Lua.type(leLua, leResult);
		return type >= Lua.LUA_TNIL && type < Lua.LUA_TTABLE && type != Lua.LUA_TLIGHTUSERDATA;
	}

	public static function isErrorAllowed(error:String) {
		switch(error) {
			case 'attempt to call a nil value' | 'C++ exception':
				return false;
		}
		return true;
	}
}
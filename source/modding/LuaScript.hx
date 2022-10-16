package modding;

import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import openfl.utils.Dictionary;
#if LUA_ALLOWED
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import llua.*;
import llua.Lua.Lua_helper;
import openfl.display.BlendMode;
import scenes.PlayState;
import scenes.subscenes.ScriptedSubscene;
import sys.FileSystem;

// Lua is meant for more simple modcharts, so it won't have as much power as Haxe
// If you wanna make a 6000+ crazy effects modchart with 92834391 mechanics, grow some balls
// And learn Haxe
class LuaScript extends Script {
    public var lua:State = null;

    public var _path:String = "";

    public function new(path:String) {
        super(path);
        type = "lua";

        PlayState.current.luaVars.set('bf', PlayState.current.bf);
        PlayState.current.luaVars.set('boyfriend', PlayState.current.bf);
        PlayState.current.luaVars.set('gf', PlayState.current.gf);
        PlayState.current.luaVars.set('girlfriend', PlayState.current.gf);
        PlayState.current.luaVars.set('dad', PlayState.current.dad);

		try{
            _path = path;

			lua = LuaL.newstate();
			LuaL.openlibs(lua);
			Lua.init_callbacks(lua);
            
			var result:Dynamic = LuaL.dostring(lua, Assets.get(TEXT, Paths.path(path+".lua")));
			var resultStr:String = Lua.tostring(lua, result);
			if(resultStr != null && result != 0) {
				trace('Error on lua script! ' + resultStr);
				#if windows
				lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
				#else
				Main.print("error", 'Error loading lua script: "$path"\n' + resultStr);
				#end
				lua = null;
				return;
			}

			// Variables
			set('curBpm', Conductor.bpm);
			set('bpm', PlayState.SONG.bpm);
			set('songLength', FlxG.sound.music.length);
			set('songName', PlayState.SONG.song);
			set('startedCountdown', false);

			set('isStoryMode', PlayState.isStoryMode);
			set('difficulty', PlayState.currentDifficulty);
			set('difficulties', PlayState.availableDifficulties);

			set("screenWidth", lime.app.Application.current.window.display.currentMode.width);
			set("screenHeight", lime.app.Application.current.window.display.currentMode.height);
			set('gameWidth', FlxG.width);
			set('gameHeight', FlxG.height);

			set('curBeat', 0);
			set('curStep', 0);
			set('curBeatFloat', 0);
			set('curStepFloat', 0);
			set('songPosition', Conductor.crochet * -5);
			set("crochet", Conductor.crochet);
			set("stepCrochet", Conductor.stepCrochet);

			set('downscroll', Settings.get("Downscroll"));
			set('middlescroll', Settings.get("Centered Notes"));
			set('centeredNotes', Settings.get("Centered Notes"));
			set('ghostTapping', Settings.get("Ghost Tapping"));
			set('noteOffset', Settings.get("Note Offset"));
			set('currentFPS', Main.fpsCounter.currentFPS);
            set('fpsCap', Main.framerate);
			set("currentOS", #if sys Sys.systemName() #elseif html5 "HTML5" #elseif android "Android" #end);
			set("isDebugBuild", #if debug true #else false #end);

			// Helpers
			addHelper("FlxColor", ScriptHelpers.getFlxColor());
			
			// Functions
			setFunction("print", function(text:String) {
				Main.print("lua", text);
			});
			setFunction("luaPrint", function(text:String) {
				Sys.println(text);
			});
            setFunction("loadScript", function(path:String, ?args:Array<Any>) {
                var script:Script = Script.createScript(path);
                script.start(true, args);
                var split:Array<String> = path.split("/");
                otherScripts.set(split[split.length-1], script);
            });
            setFunction("removeScript", function(path:String) {
                if(otherScripts.exists(path)) {
                    var script:Script = otherScripts.get(path);
                    script.destroy();
                    script = null;
                    otherScripts.remove(path);
                }
            });
			setFunction("getSetting", function(s:String) {return Settings.get(s);});
			setFunction("setSetting", function(s:String, v:Dynamic, f:Bool = false) {
				Settings.set(s,v);
				if(f) Settings.save();
			});
            setFunction('trace', function(a:String) {trace(a);});
			if(PlayState.current != null) {
				setFunction("startCountdown", function() {
					PlayState.current.startCountdown();
				});
				setFunction("endSong", function() {
					PlayState.current.endSong();
				});
				setFunction('setVariable', function(variable:String, value:Dynamic) {
					PlayState.current.luaVars.set(variable, value);
				});
				setFunction('getVariable', function(variable:String) {
					return PlayState.current.luaVars.get(variable);
				});
			}
			#if VIDEOS_ALLOWED
			setFunction("playVideo", function(path:String) {
				PlayState.playVideo(path, function() {
					if(PlayState.current.inCutscene) {
						PlayState.current.inCutscene = false;
						if(!PlayState.current.endingSong)
							PlayState.current.startCountdown();
					}
				});
			});
			setFunction("playVideoSprite", function(path:String) {
				var spr:VideoSprite = PlayState.playVideoSprite(path, null);
				PlayState.current.luaVars.set('VideoSprite:$path', spr);
			});
			#end
			setFunction("getProperty", function(object:String, variable:String) {
				var result:Dynamic = null;
				var split:Array<String> = variable.split('.');
				if(split.length > 1)
					result = getVarInArray(getPropertyLoopThingWhatever(split), split[split.length-1]);
				else
					result = getVarInArray(PlayState.current, variable);
	
				if(result == null) Lua.pushnil(lua);
				return result;
			});
			setFunction("getPropertyFromClass", function(className:String, variable:String) {
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
			setFunction("setProperty", function(variable:String, value:Dynamic) {
				var split:Array<String> = variable.split('.');
				if(split.length > 1) {
					setVarInArray(getPropertyLoopThingWhatever(split), split[split.length-1], value);
					return true;
				}
				setVarInArray(PlayState.current, variable, value);
				return true;
			});
			setFunction("setPropertyFromClass", function(className:String, variable:String, value:Dynamic) {
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
			setFunction("openScriptedSubscene", function(name:String, ?args:Array<Any>, pauseGame:Bool = false) {
				if(args == null) args = [];
				if(pauseGame) {
					FlxG.state.persistentUpdate = false;
					FlxG.state.persistentDraw = true;
					if(PlayState.current != null && FlxG.sound.music != null) {
						FlxG.sound.music.pause();
						PlayState.current.vocals.pause();
					}
				}
				FlxG.state.openSubState(new ScriptedSubscene(name, args));
			});
			setFunction("closeCurrentSubState", function() {
				FlxG.state.closeSubState();
			});
			setFunction("cameraFlash", function(camera:String = "", color:FlxColor, time:Float = 1, force:Bool = false) {
				cameraFromString(camera).flash(color, time, null, force);
			});

			// Sprite Functions
			if(PlayState.current != null) {
				setFunction("makeSprite", function(name:String, x:Float, y:Float) {
					if(!PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = new Sprite(x, y);
						PlayState.current.luaVars.set(name, spr);
					}
				});
				setFunction("makeGraphic", function(name:String, width:Int, height:Int, hex:String = "#000000") {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.makeGraphic(width, height, FlxColor.fromString(hex));
					}
				});
				setFunction("loadGraphic", function(name:String, path:String) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.loadGraphic(Assets.get(IMAGE, Paths.image(path)));
					}
				});
				setFunction("loadSparrowFrames", function(name:String, path:String) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.frames = Assets.get(SPARROW, Paths.image(path));
					}
				});
				setFunction("loadPackerFrames", function(name:String, path:String) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.frames = Assets.get(PACKER, Paths.image(path));
					}
				});
				setFunction("addAnimationByPrefix", function(name:String, animName:String, prefix:String, fps:Int = 24, loop:Bool = false) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.animation.addByPrefix(animName, prefix, fps, loop);
					}
				});
				setFunction("addAnimationByIndices", function(name:String, animName:String, prefix:String, indices:Array<Int>, fps:Int = 24, loop:Bool = false) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.animation.addByIndices(animName, prefix, indices, "", fps, loop);
					}
				});
				setFunction("addAnimation", function(name:String, animName:String, frames:Array<Int>, fps:Int = 24, loop:Bool = false) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.animation.add(animName, frames, fps, loop);
					}
				});
				setFunction("setOffsetOnAnimation", function(name:String, animName:String, x:Float, y:Float) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.setOffset(animName, x, y);
					}
				});
				setFunction("playAnimation", function(name:String, animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.playAnim(animName, force, reversed, frame);
					}
				});
				setFunction("setGraphicSize", function(name:String, x:Float = 0, ?y:Null<Float> = null) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						if(y != null)
							spr.setGraphicSize(Std.int(x), Std.int(y));
						else
							spr.setGraphicSize(Std.int(x));
					}
				});
				setFunction("getGraphicSize", function(name:String, x:Float = 0, ?y:Null<Float> = null) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						return [spr.width, spr.height];
					}
					return [0, 0];
				});
				setFunction("updateHitbox", function(name:String) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.updateHitbox();
					}
				});
				setFunction("setObjectCamera", function(name:String, camera:String) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.cameras = [cameraFromString(camera)];
					}
				});
				setFunction("addSprite", function(name:String) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						PlayState.current.add(spr);
					}
				});
				setFunction("removeSprite", function(name:String) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						PlayState.current.remove(spr, true);
					}
				});
				setFunction("destroySprite", function(name:String) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						PlayState.current.luaVars.remove(name);
						PlayState.current.remove(spr, true);	
						spr.destroy();
					}
				});
				setFunction("setSpriteBlendMode", function(name:String, blend:String) {
					if(PlayState.current.luaVars.exists(name)) {
						var spr:Sprite = PlayState.current.luaVars.get(name);
						spr.blend = blendModeFromString(blend);
					}
				});
			}
			// Tweening
			setFunction("tweenObject", function(objectName:String, properties:Dynamic, value:Dynamic, duration:Float = 1, ease:String = "linear") {
				cancelTween(objectName);
				var object:Dynamic = getLuaObject(objectName);

				PlayState.current.luaTweens.set(objectName, FlxTween.tween(object, properties, duration, { ease: flxEaseFromString(ease), onComplete: function(twn:FlxTween) {
					PlayState.current.scripts.call("onTweenCompleted", [objectName]);
					PlayState.current.scripts.call("onTweenFinished", [objectName]);
					PlayState.current.scripts.call("tweenCompleted", [objectName]);
					PlayState.current.scripts.call("tweenFinished", [objectName]);
					var twn:FlxTween = PlayState.current.luaTweens.get(objectName);
					twn.destroy();
					PlayState.current.luaTweens.remove(objectName);
				}}));
			});
			setFunction("cancelObjectTween", function(objectName:String) {
				cancelTween(objectName);
			});

			// Timers
			setFunction("startTimer", function(name:String, duration:Float = 1) {
				cancelTimer(name);

				PlayState.current.luaTimers.set(name, new FlxTimer().start(duration, function(tmr:FlxTimer) {
					PlayState.current.scripts.call("onTimerCompleted", [name]);
					PlayState.current.scripts.call("onTimerFinished", [name]);
					PlayState.current.scripts.call("timerCompleted", [name]);
					PlayState.current.scripts.call("timerFinished", [name]);
					var tmr:FlxTimer = PlayState.current.luaTimers.get(name);
					tmr.destroy();
					PlayState.current.luaTimers.remove(name);
				}));
			});
			setFunction("cancelTimer", function(name:String) {
				cancelTimer(name);
			});

			// Sounds
			setFunction("playSound", function(name:String, path:String, ?vol:Float = 1) {
				var snd:FlxSound = new FlxSound().loadEmbedded(Assets.get(SOUND, Paths.sound(path)));
				snd.volume = vol;
				snd.play();
				snd.onComplete = function() {
					PlayState.current.luaSounds.remove(name);
					snd.destroy();
				}
				PlayState.current.luaSounds.set(name, snd);
			});
			setFunction("stopSound", function(name:String) {
				stopSound(name);
			});

			// Music
			setFunction("playMusic", function(path:String, ?vol:Float = 1) {
				FlxG.sound.playMusic(Assets.get(SOUND, Paths.sound(path)), vol);
			});
			setFunction("stopMusic", function(name:String) {
				FlxG.sound.music.stop();
			});
			setFunction("pauseMusic", function(name:String) {
				FlxG.sound.music.pause();
			});
			setFunction("resumeMusic", function(name:String) {
				FlxG.sound.music.resume();
			});
		} catch(e) {
			Main.print('error', e.details());
			destroy();
		}
    }

	public static function getPropertyLoopThingWhatever(split:Array<String>, ?getProperty:Bool=true):Dynamic {
		var obj:Dynamic = getLuaObject(split[0]);
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
			}
			else
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
			else
				blah = Reflect.getProperty(instance, shit[0]);

			for (i in 1...shit.length) {
				var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
				blah = blah[leNum];
			}
			return blah;
		}

		if(PlayState.current.luaVars.exists(variable))
		{
			var retVal:Dynamic = PlayState.current.luaVars.get(variable);
			if(retVal != null)
				return retVal;
		}

		return Reflect.getProperty(instance, variable);
	}

	function addHelper(className:String, classThing:Dynamic) {
        for (i in Reflect.fields(classThing)) {
            var cuminmyass:Dynamic = Reflect.field(classThing, i);
            if(Reflect.isFunction(cuminmyass))
                setFunction(className+"_"+i, cuminmyass);
            else
                set(className+"_"+i, cuminmyass);
        }
	}

	function cancelTween(name:String) {
		if(PlayState.current.luaTweens.exists(name)) {
			var twn:FlxTween = PlayState.current.luaTweens.get(name);
			twn.cancel();
			twn.destroy();
			PlayState.current.luaTweens.remove(name);
		}
	}

	function cancelTimer(name:String) {
		if(PlayState.current.luaTimers.exists(name)) {
			var twn:FlxTimer = PlayState.current.luaTimers.get(name);
			twn.cancel();
			twn.destroy();
			PlayState.current.luaTimers.remove(name);
		}
	}

	function stopSound(name:String) {
		if(PlayState.current.luaSounds.exists(name)) {
			var snd:FlxSound = PlayState.current.luaSounds.get(name);
			snd.stop();
			snd.destroy();
			PlayState.current.luaSounds.remove(name);
		}
	}

	public static function flxEaseFromString(?ease:String = '') {
		ease = ease.toLowerCase();
		var eases:Map<String, Dynamic> = [
			'backin' => FlxEase.backIn,
			'backinout' => FlxEase.backInOut,
			'backout' => FlxEase.backOut,
			'bouncein' => FlxEase.bounceIn,
			'bounceinout' => FlxEase.bounceInOut,
			'bounceout' => FlxEase.bounceOut,
			'circin' => FlxEase.circIn,
			'circinout' => FlxEase.circInOut,
			'circout' => FlxEase.circOut,
			'cubein' => FlxEase.cubeIn,
			'cubeinout' => FlxEase.cubeInOut,
			'cubeout' => FlxEase.cubeOut,
			'elasticin' => FlxEase.elasticIn,
			'elasticinout' => FlxEase.elasticInOut,
			'elasticout' => FlxEase.elasticOut,
			'expoin' => FlxEase.expoIn,
			'expoinout' => FlxEase.expoInOut,
			'expoout' => FlxEase.expoOut,
			'quadin' => FlxEase.quadIn,
			'quadinout' => FlxEase.quadInOut,
			'quadout' => FlxEase.quadOut,
			'quartin' => FlxEase.quartIn,
			'quartinout' => FlxEase.quartInOut,
			'quartout' => FlxEase.quartOut,
			'quintin' => FlxEase.quintIn,
			'quintinout' => FlxEase.quintInOut,
			'quintout' => FlxEase.quintOut,
			'sinein' => FlxEase.sineIn,
			'sineinout' => FlxEase.sineInOut,
			'sineout' => FlxEase.sineOut,
			'smoothstepin' => FlxEase.smoothStepIn,
			'smoothstepinout' => FlxEase.smoothStepInOut,
			'smoothstepout' => FlxEase.smoothStepInOut,
			'smootherstepin' => FlxEase.smootherStepIn,
			'smootherstepinout' => FlxEase.smootherStepInOut,
			'smootherstepout' => FlxEase.smootherStepOut
		];
		return eases.exists(ease) ? eases[ease] : eases["linear"];
	}

    public static function blendModeFromString(blend:String):BlendMode {
        blend = blend.toLowerCase();
        var modes:Map<String, BlendMode> = [
            "add"        => BlendMode.ADD,
            "alpha"      => BlendMode.ALPHA,
            "darken"     => BlendMode.DARKEN,
            "difference" => BlendMode.DIFFERENCE,
            "erase"      => BlendMode.ERASE,
            "hardlight"  => BlendMode.HARDLIGHT,
            "invert"     => BlendMode.INVERT,
            "layer"      => BlendMode.LAYER,
            "lighten"    => BlendMode.LIGHTEN,
            "multiply"   => BlendMode.MULTIPLY,
            "normal"     => BlendMode.NORMAL,
            "overlay"    => BlendMode.OVERLAY,
            "screen"     => BlendMode.SCREEN,
            "shader"     => BlendMode.SHADER,
            "subtract"   => BlendMode.SUBTRACT
        ];
        return modes.exists(blend) ? modes[blend] : modes["normal"];
    }

	override public function start(create:Bool = true, ?args:Array<Any>) {
		if(create) {
			call("onCreate", args);
			call("create", args);
			call("new", args);
		}
	}

    public static function getLuaObject(id:String):Dynamic {
		if (!PlayState.current.luaVars.exists(id))
			return Reflect.getProperty(PlayState.current, id);

		return PlayState.current.luaVars.get(id);
	}

    override public function destroy() {
		if(lua == null) return;
		Lua.close(lua);
		lua = null;
	}

    public function cameraFromString(cam:String):FlxCamera {
        cam = cam.toLowerCase();
        var cameras:Map<String, FlxCamera> = [
            "game"     => PlayState.current.camGame,
			"camGame"  => PlayState.current.camGame,
            "hud"      => PlayState.current.camHUD,
			"camHUD"   => PlayState.current.camHUD,
            "other"    => PlayState.current.camOther,
			"camOther" => PlayState.current.camOther
        ];
        return cameras.exists(cam) ? cameras[cam] : cameras["game"];
    }

	override public function set(variable:String, data:Dynamic) {
		if(lua == null) return;
		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

    override public function setFunction(name:String, value:Dynamic) {
		if(lua == null) return;
        Lua_helper.add_callback(lua, name, value);
	}

    override public function call(func:String, ?args:Array<Any>):Dynamic {
		if (lua == null) return true;
		if (args == null) args = [];

		try {
			// basically a transplant from leather engine that doesn't crash the game on linux lmfao!!!
			var result:Any = null;
			Lua.getglobal(lua, func);
			for (arg in args) Convert.toLua(lua, arg);

			result = Lua.pcall(lua, args.length, 1, 0);

			var p = Lua.tostring(lua, result);
			var e = getErrorMessage();

			if (result == null)
				return null;
			else {
				// the one part of the engine that remained
				var conv:Dynamic = cast getResult(lua, result);
				Lua.pop(lua, 1);
				if(conv == null) conv = true;
				return conv;
			}
		}
		catch (e) {
			Main.print('error', e.details());
		}
		return true;
    }

	function getErrorMessage() {
		if(lua == null) return null;
		var v:String = Lua.tostring(lua, -1);
		if(!isErrorAllowed(v)) v = null;
		return v;
	}

	function resultIsAllowed(leLua:State, leResult:Null<Int>) {
		if(lua == null) return true;
		var type:Int = Lua.type(leLua, leResult);
		return type >= Lua.LUA_TNIL && type < Lua.LUA_TTABLE && type != Lua.LUA_TLIGHTUSERDATA;
	}

	function isErrorAllowed(error:String) {
		switch(error) {
			case 'attempt to call a nil value' | 'C++ exception':
				return false;
		}
		return true;
	}

	function getResult(l:State, result:Int):Any {
		var ret:Any = null;

		switch(Lua.type(l, result)) {
			case Lua.LUA_TNIL:
				ret = null;
			case Lua.LUA_TBOOLEAN:
				ret = Lua.toboolean(l, -1);
			case Lua.LUA_TNUMBER:
				ret = Lua.tonumber(l, -1);
			case Lua.LUA_TSTRING:
				ret = Lua.tostring(l, -1);
		}
		
		return ret;
	}
	
}
#end
package modding;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxRuntimeShader;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.effects.particles.FlxEmitter;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfThree;
import flixel.util.typeLimit.OneOfTwo;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import scenes.ChartingMenu;
import scenes.OptionsMenu;
import scenes.PlayState;
import sys.thread.Thread;

class HScript extends Script {
    public var script:String;

	public var parser:Parser = new Parser();
	public var program:Expr;
	public var interp:Interp = new Interp();

    public var canStart:Bool = true;
    public var runningScript:Bool = true;

    public var _path:String = "";

    public static var hscriptExts:Array<String> = [
        ".hxs",
        ".hx",
        ".hsc",
        ".hscript"
    ];

    public var usedExtension:String = ".hxs";

    public function new(path:String) {
        super(path);
        type = "hscript";

        _path = path;

        // Get the raw script text
        var awesomeSwagPath:String = Paths.path(path+".hxs");

        for(ext in hscriptExts) {
            if(FileSystem.exists(Paths.path(path+ext))) {
                usedExtension = ext;
                awesomeSwagPath = Paths.path(path+ext);
                break;
            }
        }

        script = Assets.get(TEXT, awesomeSwagPath);

        parser.allowJSON = true;
        parser.allowTypes = true;
        parser.allowMetadata = true;

        interp.errorHandler = function(e:hscript.Error) {
            runningScript = false;
            canStart = false;
            
            #if DEBUG_PRINTING
            trace('${e.toString()}');
            #end
            var posInfo = interp.posInfos();

            var lineNumber = Std.string(posInfo.lineNumber);
            var methodName = posInfo.methodName;

            Main.print("error", 'Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e.toString()}\n\nHX File: $path$usedExtension');
        };

        // Set variables/classes
        // Flixel
        set("trace", function(text:String) {
            Main.print("hscript", text);
        });
        set("traceDebug", function(text:String) {
            Main.print("debug", text);
        });
        set("traceError", function(text:String) {
            Main.print("error", text);
        });
        set("traceWarning", function(text:String) {
            Main.print("warn", text);
        });
        set("traceWarn", function(text:String) {
            Main.print("warn", text);
        });
        set("StringTools", StringTools);
        set("Reflect", Reflect);
        set("Type", Type);
        set("Math", Math);
        set("Std", Std);
        set("Array", Array);
        set("String", String);
        set("Float", Float);
        set("Int", Int);
        set("Bool", Bool);
        set("Dynamic", Dynamic);
        set("static", Script.staticVars); // static variables!
        set("Json", {
            "parse": tjson.TJSON.parse,
            "stringify": haxe.Json.stringify
        });
        set("Thread", {
            "readMessage": Thread.readMessage,
            "create": Thread.create,
            "createWithEventLoop": Thread.createWithEventLoop
        });
        set("FlxG", flixel.FlxG);
        set("FlxColor", ScriptHelpers.getFlxColor());
        set("FlxTween", flixel.tweens.FlxTween);
        set("FlxEase", flixel.tweens.FlxEase);
        set("FlxKey", ScriptHelpers.getFlxKey());
        set("BlendMode", ScriptHelpers.getBlendMode());
        set("FlxGroup", flixel.group.FlxGroup);
        set("FlxTypedGroup", flixel.group.FlxGroup.FlxTypedGroup);
        set("FlxSpriteGroup", flixel.group.FlxSpriteGroup);
        set("FlxTypedSpriteGroup", flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup);
        set("FlxCameraFollowStyle", ScriptHelpers.getFlxCameraFollowStyle());
        set("FlxTextAlign", ScriptHelpers.getFlxTextAlign());
        set("FlxTextBorderStyle", ScriptHelpers.getFlxTextBorderStyle());
        set("FlxSprite", flixel.FlxSprite);
        set("FlxBackdrop", flixel.addons.display.FlxBackdrop);
        set("FlxTimer", flixel.util.FlxTimer);
        set("FlxSound", flixel.system.FlxSound);
        set("FlxMath", flixel.math.FlxMath);
        set("FlxTypeText", flixel.addons.text.FlxTypeText);
        set("FlxText", flixel.text.FlxText);
        set("FlxAxes", flixel.util.FlxAxes);
        set("FlxTrail", flixel.addons.effects.FlxTrail);
        set("Window", Application.current.window);
        set("Application", Application.current);
        set("Application_", Application);
        
        set("currentOS", #if sys Sys.systemName() #elseif html5 "HTML5" #elseif android "Android" #else "Unknown" #end);
        set("isDebugBuild", #if debug true #else false #end);

        // Funkin
        set("script", this);
        #if discord_rpc
        set("DiscordRPC", misc.DiscordRPC);
        #end
        set("Sprite", engine.Sprite);
        set("Paths", {
            "path": Paths.path,
            "image": function(p:String, ?mod:Null<String>, useRootFolder:Bool = true) {return Assets.get(IMAGE, Paths.image(p, mod, useRootFolder));},
            "sound": function(p:String, ?mod:Null<String>, useRootFolder:Bool = true) {return Assets.get(SOUND, Paths.sound(p, mod, useRootFolder));},
            "music": function(p:String, ?mod:Null<String>) {return Assets.get(SOUND, Paths.music(p, mod));},
            "sparrow": function(p:String, ?mod:Null<String>, useRootFolder:Bool = true) {return Assets.get(SPARROW, Paths.image(p, mod, useRootFolder));},
            "songInst": function(p:String, ?mod:Null<String>) {return Assets.get(SOUND, Paths.songInst(p, mod));},
            "songVoices": function(p:String, ?mod:Null<String>) {return Assets.get(SOUND, Paths.songVoices(p, mod));},
            "txt": function(p:String, ?mod:Null<String>) {return Assets.get(TEXT, Paths.txt(p, mod));},
            "json": function(p:String, ?mod:Null<String>) {return Assets.get(JSON, Paths.json(p, mod));},
            "xml": function(p:String, ?mod:Null<String>) {return Assets.get(TEXT, Paths.xml(p, mod));},
            "frag": function(p:String, ?mod:Null<String>) {return Assets.get(TEXT, Paths.frag(p, mod));},
            "vert": function(p:String, ?mod:Null<String>) {return Assets.get(TEXT, Paths.vert(p, mod));},
            "video": Paths.video,
            "font": Paths.font
        });
        set("SongLoader", funkin.Song.SongLoader);
        set("Main", Main);
        set("Paths_", Paths);
        set("CoolUtil", CoolUtil);
        set("Assets", Assets);
        set("Conductor", Conductor);
        set("PlayState", PlayState.current);
        set("PlayState_", PlayState);
        set("ModClass", ModClass);
        set("HealthIcon", funkin.HealthIcon);
        set("Alphabet", funkin.Alphabet);
        set("Note", funkin.gameplay.Note);
        set("StrumLine", funkin.gameplay.StrumLine);
        set("StrumNote", funkin.gameplay.StrumNote);
        set("ScriptedSprite", modding.ScriptedSprite);
        set("ScriptedScene", scenes.ScriptedScene);
        set("ScriptedSubscene", scenes.subscenes.ScriptedSubscene);
        set("Character", funkin.gameplay.Character);
        set("UI_", funkin.gameplay.UI);
        set("Settings", misc.Settings);
        set("Keybinds", misc.Keybinds);
        set("loadScript", function(path:String, ?args:Array<Any>) {
            var script:Script = Script.createScript(path);
            script.start(true, args);
            var split:Array<String> = path.split("/");
            otherScripts.set(split[split.length-1], script);
            return script;
        });
        set("removeScript", function(path:String) {
            if(otherScripts.exists(path)) {
                var script:Script = otherScripts.get(path);
                script.destroy();
                script = null;
                otherScripts.remove(path);
            }
        });

        try {
            program = parser.parseString(script);
        } catch(e) {
            runningScript = false;
            canStart = false;
            Main.print('error', e.details());
        }
    }

    override public function destroy() {
        runningScript = false;
        canStart = false;
        script = "";
        program = null;
        parser = null;
        interp = null;
    }

    override public function get(name:String) {
        if(!runningScript) return null;
        return interp.variables.get(name);
    }

    override public function set(name:String, value:Dynamic) {
        if(!runningScript) return;
        interp.variables.set(name, value);
    }

    override public function call(func:String, ?args:Array<Any>):Dynamic {
        if(!runningScript) return true;

        for(s in otherScripts) s.call(func, args);
        
		if (interp.variables.exists(func)) {
			try {
                var f = interp.variables.get(func);
				if (args == null)
					return f();
				else
					return Reflect.callMethod(null, f, args);
			} catch (e) {
				trace(e.details());
				trace(_path + ": ERROR Caused in " + func + " with " + Std.string(args) + " args");
			}
		}

        return true;
    }

    override public function start(create:Bool = true, ?args:Array<Any>) {
        // If we're not allowed to start the script, then we say "fuck off" to the script
        if(!canStart) return;

        runningScript = true;
        try {
            interp.execute(program);
            if(create) {
                call("onCreate", args);
                call("create", args);
                call("onStart", args);
                call("start", args);
                call("new", args);
            }
        } catch(e) {
            runningScript = false;
            canStart = false;

            #if DEBUG_PRINTING
            trace(e.details());
            #end

            Main.print("error", e.details());
        }
    }

    public function setScriptObject(obj:Dynamic) {
        interp.scriptObject = obj;
    }
}
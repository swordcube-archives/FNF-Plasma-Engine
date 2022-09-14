package hscript;

import flixel.FlxG;
import haxe.Exception;
import hscript.Expr.Error;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import states.PlayState;
import sys.FileSystem;
import sys.thread.Thread;
import systems.MusicBeat.MusicBeatState;
import ui.Notification;

using StringTools;

class HScript {
    public var locals(get, set):Map<String, {r:Dynamic, depth:Int}>;
    function get_locals():Map<String, {r:Dynamic, depth:Int}> {
        @:privateAccess
        return interp.locals;
    }
    function set_locals(local:Map<String, {r:Dynamic, depth:Int}>) {
        @:privateAccess
        return interp.locals = local;
    }

	public var _path:String;
	public var script:String;

	public var parser:Parser = new Parser();
	public var program:Expr;
	public var interp:Interp = new Interp();

	public var otherScripts:Array<HScript> = [];

	public var executedScript:Bool = false;

    public static var function_continue:String = "FUNCTION_CONTINUE";
    public static var function_stop:String = "FUNCTION_STOP";
    public static var function_stop_script:String = "FUNCTION_STOP_SCRIPT";

    public static var hscriptExts:Array<String> = [
        ".hxs",
        ".hx",
        ".hsc",
        ".hscript"
    ];

    public var usedExtension:String = ".hxs";

    public function new(path:String, fileExt:String = ".hxs", useRawPath:Bool = false)
    {
        var awesomeSwagPath:String = useRawPath ? path : AssetPaths.asset(path+fileExt);

        if(!useRawPath) {
            for(ext in hscriptExts)
            {
                if(FileSystem.exists(AssetPaths.asset(path+ext)))
                {
                    usedExtension = ext;
                    awesomeSwagPath = AssetPaths.asset(path+ext);
                }
                else if(FileSystem.exists(AssetPaths.asset(path+ext, 'funkin')))
                {
                    usedExtension = ext;
                    awesomeSwagPath = AssetPaths.asset(path+ext, 'funkin');
                }
            }
        }

        try
        {
            _path = path;
            script = FNFAssets.returnAsset(TEXT, awesomeSwagPath);

            parser = new Parser();

            // Parser Settings
            parser.allowJSON = true;
            parser.allowTypes = true;
            parser.allowMetadata = true;

            interp = new Interp();

            // Set all of the classes/variables/functions
            //

            // Haxe/HaxeFlixel classes
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

            set("Thread", {
                "readMessage": Thread.readMessage,
                "create": Thread.create,
                "createWithEventLoop": Thread.createWithEventLoop
            });
            
            set("StringTools", StringTools);
            set("FlxG", flixel.FlxG);
            set("OpenFLAssets", openfl.utils.Assets);
            set("LimeAssets", lime.utils.Assets);

            set("FlxFlicker", flixel.effects.FlxFlicker);

            set("FlxTween", flixel.tweens.FlxTween);
            set("FlxEase", flixel.tweens.FlxEase);

            set("Reflect", Reflect);

            set("FlxGroup", flixel.group.FlxGroup);
            set("FlxTypedGroup", flixel.group.FlxGroup.FlxTypedGroup);
            set("FlxSpriteGroup", flixel.group.FlxSpriteGroup);
            set("FlxTypedSpriteGroup", flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup);

            set("FlxTextBorderStyle", HScriptHelpers.getFlxTextBorderStyle());
            set("FlxTextAlign", HScriptHelpers.getFlxTextAlign());

            set("FlxKey", HScriptHelpers.getFlxKey());
            // flxcolor is a stupid abstract class so i am doing this
            set("FlxColor", HScriptHelpers.getFlxColor());

            set("Json", {
                "parse": haxe.Json.parse,
                "stringify": haxe.Json.stringify
            });
            
            set("FNFSprite", systems.FNFSprite);
            set("FlxSprite", flixel.FlxSprite);
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
            #if discord_rpc
            set("DiscordRPC", DiscordRPC);
            #end

            set("BitmapData", openfl.display.BitmapData);
            set("FlxGraphic", flixel.graphics.FlxGraphic);
            
            set("Math", Math);
            set("Std", Std);

            set("Type", Type);

            set("FlxCameraFollowStyle", HScriptHelpers.getFlxCameraFollowStyle());

            set("BlendMode", HScriptHelpers.getBlendMode());
            set("isDebugBuild", #if debug true #else false #end);
            set("currentOS", Main.getOS());

            // Game functions
            set("loadScript", function(scriptPath:String, ?args:Array<Any>)
                {
                    var new_script = new HScript(scriptPath);
                    new_script.start(true, args);
    
                    otherScripts.push(new_script);
                    return new_script;
                });
            set("importScript", HScriptHelpers.importScript);
            set("updateClass", function(name) {
                HScriptHelpers.updateClass(name, this);
            });

            // Game classes
            set("function_continue", function_continue);
            set("function_stop", function_stop);
            set("function_stop_script", function_stop_script);

            set("Global", Global);
            set("CoolUtil", CoolUtil);
            set("UIControls", systems.UIControls);
            
            set("ColorShader", shaders.ColorShader);

            set("Conductor", systems.Conductor);
            set("AssetPaths", AssetPaths);

            set("Stage", gameplay.Stage);
            set("Ranking", systems.Ranking);
            
            set("HScript", HScript);

            set("StrumLine", gameplay.StrumLine);
            set("StrumNote", gameplay.StrumNote);
            set("Note", gameplay.Note);

            set("Character", gameplay.Character);
            set("Boyfriend", gameplay.Boyfriend);

            set("NoteSplash", ui.NoteSplash);
            
            set("FNFAssets", HScriptHelpers.getFNFAssets());
            set("FNFAssets_", FNFAssets);

            set("AssetUtil", HScriptHelpers.getAssetUtil());

            set("Main", Main);
            set("Init", Init);
            set("Settings", Settings);
            set("Transition", Transition);

            set("Alphabet", ui.Alphabet);

            set("SongLoader", gameplay.Song.SongLoader);

            set("Highscore", systems.Highscore);
            set("HealthIcon", ui.HealthIcon);
            set("FNFCheckbox", ui.FNFCheckbox);

            set("Notification", {
                "showError": function(title:String, description:String) {
                    var notif:Notification = new Notification(title, description, Error);
                    cast(FlxG.state, MusicBeatState).notificationGroup.add(notif);
                    return notif;
                },
                "showWarning": function(title:String, description:String) {
                    var notif:Notification = new Notification(title, description, Warn);
                    cast(FlxG.state, MusicBeatState).notificationGroup.add(notif);
                    return notif;
                },
                "showInfo": function(title:String, description:String) {
                    var notif:Notification = new Notification(title, description, Info);
                    cast(FlxG.state, MusicBeatState).notificationGroup.add(notif);
                    return notif;
                }
            });

            // Gameplay Characters
            if(PlayState.current != null)
            {
                set("dad", PlayState.current.dad);
                set("gf", PlayState.current.gf);
                set("bf", PlayState.current.bf);
                set("boyfriend", PlayState.current.bf);
            }

            // Game states
            set("ToolboxMain", toolbox.ToolboxMain);

            set("PlayState", PlayState.current);
            set("PlayState_", PlayState);

            set("ScriptedState", states.ScriptedState);
            set("ScriptedSubState", substates.ScriptedSubState);
            set("ScriptedSprite", systems.ScriptedSprite);
            set("CustomShader", shaders.CustomShader);

            // Game substates
            set("KeybindMenu", substates.KeybindMenu);
            set("ModSelectionMenu", substates.ModSelectionMenu);

            set("setScriptObject", setScriptObject);

            // Set the script object to PlayState if we're in Playstate
            if(PlayState.current != null)
                setScriptObject(PlayState.current);

            program = parser.parseString(script);

            interp.errorHandler = function(e:hscript.Error) {
                executedScript = false;

                #if DEBUG_PRINTING
                trace('$e');
                #end
                var posInfo = interp.posInfos();

                var lineNumber = Std.string(posInfo.lineNumber);
                var methodName = posInfo.methodName;
                var className = posInfo.className;

                Main.print("error", 'Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nHX File: $path.hxs');

                cast(FlxG.state, MusicBeatState).notificationGroup.add(new Notification(
                    '${e}',
                    'Occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'} in $path.hxs',
                    Error
                ));
            };

            // Execute the script
            interp.execute(program);
        }
        catch(e)
        {
            executedScript = false;

            #if DEBUG_PRINTING
            trace('$e');
            #end
            var posInfo = interp.posInfos();

            var lineNumber = Std.string(posInfo.lineNumber);
            var methodName = posInfo.methodName;
            var className = posInfo.className;

            Main.print("error", 'Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nHX File: $path.hxs');

            cast(FlxG.state, MusicBeatState).notificationGroup.add(new Notification(
                '${e}',
                'Occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'} in $path.hxs',
                Error
            ));

            stop();
        }
    }

	public function log(text, ?doTrace:Bool = true)
	{
		if (doTrace)
			Main.print("hscript", text);
	}

    public function stop() {
        executedScript = false;
        parser = null;
        program = null;
        interp = null;
    }

	public function start(callFuncs:Bool = true, ?args:Array<Any>)
	{
		executedScript = true;
		try
		{
			interp.variables.set("state", flixel.FlxG.state);
			interp.execute(program);
		}
		catch (e)
		{
			executedScript = false;
			log(e.details(), true);
		}

		if (executedScript && callFuncs) {
			call("create", args);
            call("new", args);
        }
	}

	public function update(elapsed:Float)
	{
		if (executedScript)
			call("update", [elapsed]);
	}

	public function call(func:String, ?args:Array<Dynamic>):Dynamic
	{
		if (!executedScript)
			return function_continue;

		if (interp.variables.exists(func))
		{
			var real_func = interp.variables.get(func);
			try
			{
				if (args == null)
					return real_func();
				else
					return Reflect.callMethod(null, real_func, args);
			}
			catch (e)
			{
				log(e.details(), true);
				log(_path + usedExtension + ": ERROR Caused in " + func + " with " + Std.string(args) + " args", true);
			}
		}

		for (otherScript in otherScripts)
			otherScript.call(func, args);

        return function_continue;
	}

    public function set(variable:String, value:Dynamic) {
        interp.variables.set(variable, value);
        locals.set(variable, {r: value, depth: 0});
    }
    
    public function get(variable:String):Dynamic
    {
        if (locals.exists(variable) && locals[variable] != null) {
            return locals.get(variable).r;
        } else if (interp.variables.exists(variable))
            return interp.variables.get(variable);
        return null;
    }
    //the "locals" things are for the script's own variables!!

    public function getAll()
    {
        var balls = {};
        for (i in locals.keys()) {
            Reflect.setField(balls, i, get(i));
        }
        for (i in interp.variables.keys()) {
            Reflect.setField(balls, i, get(i));
        }
        return balls;
    }
    
    public function setScriptObject(obj:Dynamic) {
        interp.scriptObject = obj;
    }
}
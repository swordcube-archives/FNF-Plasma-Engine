package hscript;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import haxe.Exception;
import hscript.Expr.Error;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import openfl.display.BlendMode;
import openfl.media.Sound;
import states.PlayState;
import sys.thread.Thread;
import systems.MusicBeat.MusicBeatState;
import ui.Notification;

using StringTools;

class HScript {
	public var _path:String;
	public var script:String;

	public var parser:Parser = new Parser();
	public var program:Expr;
	public var interp:Interp = new Interp();

	public var otherScripts:Array<HScript> = [];

	public var executedScript:Bool = false;

    public function new(path:String)
    {
        try
        {
            _path = path;
            script = FNFAssets.returnAsset(TEXT, AssetPaths.hxs(path));

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
                log(text);
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

            set("FlxGroup", flixel.group.FlxGroup);
            set("FlxTypedGroup", flixel.group.FlxGroup.FlxTypedGroup);
            set("FlxSpriteGroup", flixel.group.FlxSpriteGroup);
            set("FlxTypedSpriteGroup", flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup);

            set("FlxTextBorderStyle", {
                "NONE": FlxTextBorderStyle.NONE,
                "SHADOW": FlxTextBorderStyle.SHADOW,
                "OUTLINE": FlxTextBorderStyle.OUTLINE,
                "OUTLINE_FAST": FlxTextBorderStyle.OUTLINE_FAST
            });

            set("FlxTextAlign", {
                "LEFT": "left",
                "CENTER": "center",
                "RIGHT": "right",
                "JUSTIFY": "justify",
                "fromOpenFL": FlxTextAlign.fromOpenFL,
                "toOpenFL": FlxTextAlign.toOpenFL
            });

            // flxcolor is a stupid abstract class so i am doing this
            set("FlxColor", HScriptHelpers.getFlxColorClass());

            set("Json", {
                "parse": haxe.Json.parse,
                "stringify": haxe.Json.stringify
            });
            
            set("BGSprite", gameplay.BGSprite);
            set("BackgroundDancer", gameplay.BackgroundDancer);
            set("FNFSprite", systems.FNFSprite);
            set("FlxSprite", flixel.FlxSprite);
            set("FlxTimer", flixel.util.FlxTimer);
            set("FlxSound", flixel.system.FlxSound);
            set("FlxMath", flixel.math.FlxMath);
            set("FlxTypeText", flixel.addons.text.FlxTypeText);
            set("FlxText", flixel.text.FlxText);
            set("FlxAxes", flixel.util.FlxAxes);
            set("Window", Application.current.window);
            set("Application", Application.current);
            set("Application_", Application);

            set("BitmapData", openfl.display.BitmapData);
            set("FlxGraphic", flixel.graphics.FlxGraphic);
            
            set("Math", Math);
            set("Std", Std);

            set("Type", Type);

            set("FlxCameraFollowStyle", {
                "LOCKON": FlxCameraFollowStyle.LOCKON,
                "PLATFORMER": FlxCameraFollowStyle.PLATFORMER,
                "TOPDOWN": FlxCameraFollowStyle.TOPDOWN,
                "TOPDOWN_TIGHT": FlxCameraFollowStyle.TOPDOWN_TIGHT,
                "SCREEN_BY_SCREEN": FlxCameraFollowStyle.SCREEN_BY_SCREEN,
                "NO_DEAD_ZONE": FlxCameraFollowStyle.NO_DEAD_ZONE
            });

            set("BlendMode", {
                "ADD": BlendMode.ADD,
                "ALPHA": BlendMode.ALPHA,
                "DARKEN": BlendMode.DARKEN,
                "DIFFERENCE": BlendMode.DIFFERENCE,
                "ERASE": BlendMode.ERASE,
                "HARDLIGHT": BlendMode.HARDLIGHT,
                "INVERT": BlendMode.INVERT,
                "LAYER": BlendMode.LAYER,
                "LIGHTEN": BlendMode.LIGHTEN,
                "MULTIPLY": BlendMode.MULTIPLY,
                "NORMAL": BlendMode.NORMAL,
                "OVERLAY": BlendMode.OVERLAY,
                "SCREEN": BlendMode.SCREEN,
                "SHADER": BlendMode.SHADER,
                "SUBTRACT": BlendMode.SUBTRACT
            });

            set("isDebugBuild", #if debug true #else false #end);

            // Game functions
            set("loadScript", function(scriptPath:String, ?args:Array<Any>)
            {
                var new_script = new HScript(scriptPath);
                new_script.callFunction("create", args);
                new_script.callFunction("createPost", args);

                otherScripts.push(new_script);
                return new_script;
            });

            // Game classes
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

            set("JudgementUI", ui.JudgementUI);
            set("NoteSplash", ui.NoteSplash);
            
            set("FNFAssets", HScriptHelpers.getFNFAssetsClass());
            set("Main", Main);
            set("Init", Init);
            set("Settings", Init.trueSettings);
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
            }

            // Game states
            set("TitleState", states.TitleState);
            set("MainMenu", states.MainMenu);

            set("StoryMenu", states.StoryMenu);
            set("FreeplayMenu", states.FreeplayMenu);
            set("OptionsMenu", states.OptionsMenu);

            set("ToolboxMain", toolbox.ToolboxMain);

            set("PlayState", PlayState.current);
            set("PlayState_", PlayState);

            set("ModState", states.ModState);
            set("ModSubState", substates.ModSubState);

            // Game substates
            set("KeybindMenu", substates.KeybindMenu);
            set("ModSelectionMenu", substates.ModSelectionMenu);

            program = parser.parseString(script);

            interp.errorHandler = function(e:hscript.Error) {
                trace('$e');
                if(!flixel.FlxG.keys.pressed.SHIFT) {
                    var posInfo = interp.posInfos();

                    var lineNumber = Std.string(posInfo.lineNumber);
                    var methodName = posInfo.methodName;
                    var className = posInfo.className;

                    #if windows
                    Application.current.window.alert('Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nIf the message boxes blocks the engine, hold down SHIFT to bypass.', 'HScript error! - $path.hxs');
                    #else
                    Main.print("error", 'Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nHX File: $path.hxs');
                    #end

                    cast(FlxG.state, MusicBeatState).notificationGroup.add(new Notification(
                        '${e}',
                        'Occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'} in $path.hxs',
                        Error
                    ));
                }
            };

            //
            // Execute the script
            interp.execute(program);
        }
        catch(e)
        {
            log(e.message);
        }
    }

	public function log(text, ?doTrace:Bool = true)
	{
		if (doTrace)
			Main.print("hscript", text);

		PlayState.logs += text+"\n";
	}

	public function start(callCreate:Bool = true)
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

		if (executedScript && callCreate)
			callFunction("create");
	}

	public function update(elapsed:Float)
	{
		if (executedScript)
			callFunction("update", [elapsed]);
	}

	public function callFunction(func:String, ?args:Array<Dynamic>)
	{
		if (!executedScript)
			return;

		if (interp.variables.exists(func))
		{
			var real_func = interp.variables.get(func);

			try
			{
				if (args == null)
					real_func();
				else
					Reflect.callMethod(null, real_func, args);
			}
			catch (e)
			{
				log(e.details(), true);
				log(_path + ".hxs: ERROR Caused in " + func + " with " + Std.string(args) + " args", true);
			}
		}

		for (otherScript in otherScripts)
			otherScript.callFunction(func, args);
	}

    public function set(variable:String, value:Dynamic)
        interp.variables.set(variable, value);
}
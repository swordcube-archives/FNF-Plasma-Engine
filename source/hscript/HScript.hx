package hscript;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import openfl.display.BlendMode;
import openfl.media.Sound;
import states.PlayState;

using StringTools;

class HScript
{
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

            // HaxeFlixel classes
            setVariable("trace", function(text:String) {
                log(text);
            });
            setVariable("traceError", function(text:String) {
                Main.print("error", text);
            });
            setVariable("traceWarning", function(text:String) {
                Main.print("warn", text);
            });
            setVariable("traceWarn", function(text:String) {
                Main.print("warn", text);
            });
            
            setVariable("StringTools", StringTools);
            setVariable("FlxG", flixel.FlxG);
            setVariable("OpenFLAssets", openfl.utils.Assets);
            setVariable("LimeAssets", lime.utils.Assets);

            setVariable("FlxFlicker", flixel.effects.FlxFlicker);

            setVariable("FlxTween", flixel.tweens.FlxTween);
            setVariable("FlxEase", flixel.tweens.FlxEase);

            setVariable("FlxGroup", flixel.group.FlxGroup);
            setVariable("FlxTypedGroup", flixel.group.FlxGroup.FlxTypedGroup);
            setVariable("FlxSpriteGroup", flixel.group.FlxSpriteGroup);
            setVariable("FlxTypedSpriteGroup", flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup);

            setVariable("FlxTextBorderStyle", {
                "NONE": FlxTextBorderStyle.NONE,
                "SHADOW": FlxTextBorderStyle.SHADOW,
                "OUTLINE": FlxTextBorderStyle.OUTLINE,
                "OUTLINE_FAST": FlxTextBorderStyle.OUTLINE_FAST
            });

            setVariable("FlxTextAlign", {
                "LEFT": "left",
                "CENTER": "center",
                "RIGHT": "right",
                "JUSTIFY": "justify",
                "fromOpenFL": FlxTextAlign.fromOpenFL,
                "toOpenFL": FlxTextAlign.toOpenFL
            });

            // flxcolor is a stupid abstract class so i am doing this
            setVariable("FlxColor", HScriptHelpers.getFlxColorClass());

            setVariable("Json", {
                "parse": haxe.Json.parse,
                "stringify": haxe.Json.stringify
            });
            
            setVariable("FNFSprite", systems.FNFSprite);
            setVariable("FlxSprite", flixel.FlxSprite);
            setVariable("FlxTimer", flixel.util.FlxTimer);
            setVariable("FlxSound", flixel.system.FlxSound);
            setVariable("FlxMath", flixel.math.FlxMath);
            setVariable("FlxTypeText", flixel.addons.text.FlxTypeText);
            setVariable("FlxText", flixel.text.FlxText);
            setVariable("FlxAxes", flixel.util.FlxAxes);
            setVariable("Window", Application.current.window);
            setVariable("Application", Application.current);
            setVariable("Application_", Application);

            setVariable("BitmapData", openfl.display.BitmapData);
            setVariable("FlxGraphic", flixel.graphics.FlxGraphic);
            
            setVariable("Math", Math);
            setVariable("Std", Std);

            setVariable("Type", Type);

            setVariable("BlendMode", {
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

            setVariable("isDebugBuild", #if debug true #else false #end);

            // Game functions
            setVariable("loadScript", function(scriptPath:String, ?args:Array<Any>)
            {
                var new_script = new HScript(scriptPath);
                new_script.callFunction("create", args);
                new_script.callFunction("createPost", args);

                otherScripts.push(new_script);
                return new_script;
            });

            // Game classes
            setVariable("UIControls", systems.UIControls);
            
            setVariable("ColorShader", shaders.ColorShader);

            setVariable("Conductor", systems.Conductor);
            setVariable("AssetPaths", AssetPaths);

            setVariable("Stage", gameplay.Stage);
            setVariable("Ranking", systems.Ranking);
            
            setVariable("HScript", HScript);

            setVariable("StrumLine", gameplay.StrumLine);
            setVariable("StrumNote", gameplay.StrumNote);
            setVariable("Note", gameplay.Note);

            setVariable("Character", gameplay.Character);
            setVariable("Boyfriend", gameplay.Boyfriend);

            setVariable("JudgementUI", ui.JudgementUI);
            setVariable("NoteSplash", ui.NoteSplash);
            
            // i didn't know you could do this whole
            /**
                setVariable("Something" {
                    "someVariableOrFunctionInThisBracketShit": function(balls:String) {
                        return someActualFunctionThatHScriptHatesButCanBeDoneHere(balls);
                    },
                    "beans": FlxColor.BROWN
                });
            **/
            // thing, but uh
            // https://github.com/YoshiCrafter29/hscript-improved/blob/master/script/RunScript.hx
            // line 74 is where i found this information
            setVariable("FNFAssets", {
                "getImage": function(path:String):FlxGraphic {
                    return FNFAssets.returnAsset(IMAGE, path);
                },
                "getSparrow": function(path:String):FlxAtlasFrames {
                    return FNFAssets.returnAsset(SPARROW, path);
                },
                "getCharacterSparrow": function(path:String):FlxAtlasFrames {
                    return FNFAssets.returnAsset(CHARACTER_SPARROW, path);
                },
                "getSound": function(path:String):Sound {
                    return FNFAssets.returnAsset(SOUND, path);
                },
                "getText": function(path:String):String {
                    return FNFAssets.returnAsset(TEXT, path);
                }
            });
            setVariable("Main", Main);
            setVariable("Init", Init);
            setVariable("Settings", Init.trueSettings);
            setVariable("Transition", Transition);

            setVariable("Alphabet", ui.Alphabet);

            setVariable("SongLoader", gameplay.Song.SongLoader);

            setVariable("Highscore", systems.Highscore);
            setVariable("HealthIcon", ui.HealthIcon);
            setVariable("FNFCheckbox", ui.FNFCheckbox);

            // Gameplay Characters
            if(PlayState.current != null)
            {
                setVariable("dad", PlayState.current.dad);
                setVariable("gf", PlayState.current.gf);
                setVariable("bf", PlayState.current.bf);
            }

            // Game states
            setVariable("TitleState", states.TitleState);
            setVariable("MainMenu", states.MainMenu);

            setVariable("StoryMenu", states.StoryMenu);
            setVariable("FreeplayMenu", states.FreeplayMenu);
            setVariable("OptionsMenu", states.OptionsMenu);

            setVariable("PlayState", PlayState.current);
            setVariable("PlayState_", PlayState);

            setVariable("ModState", states.ModState);
            setVariable("ModSubState", substates.ModSubState);

            // Game substates
            setVariable("KeybindMenu", substates.KeybindMenu);
            setVariable("ModSelectionMenu", substates.ModSelectionMenu);

            program = parser.parseString(script);

            interp.errorHandler = function(e) {
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

    public function setVariable(variable:String, value:Dynamic)
        interp.variables.set(variable, value);
}
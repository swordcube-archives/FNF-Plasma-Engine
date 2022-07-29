package hscript;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import openfl.media.Sound;
import states.PlayState;

using StringTools;

class HScript
{
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
            
            setVariable("FlxSprite", flixel.FlxSprite);
            setVariable("FlxTimer", flixel.util.FlxTimer);
            setVariable("FlxSound", flixel.system.FlxSound);
            setVariable("FlxMath", flixel.math.FlxMath);
            setVariable("FlxText", flixel.text.FlxText);
            setVariable("FlxAxes", flixel.util.FlxAxes);
            
            setVariable("Math", Math);
            setVariable("Std", Std);

            // Game functions
            setVariable("loadScript", function(scriptPath:String)
            {
                var new_script = new HScript(FNFAssets.returnAsset(TEXT, AssetPaths.hxs(scriptPath)));
                new_script.start();
                new_script.callFunction("createPost");

                otherScripts.push(new_script);
            });

            // Game classes
            setVariable("UIControls", systems.UIControls);
            
            setVariable("ColorSwap", shaders.ColorSwap);
            setVariable("ColorSwapShader", shaders.ColorSwap.ColorSwapShader);

            setVariable("Conductor", systems.Conductor);
            setVariable("AssetPaths", AssetPaths);
            
            // i didn't know you could do this but uh
            // https://github.com/YoshiCrafter29/hscript-improved/blob/master/script/RunScript.hx
            // line 74 is where i found this information
            setVariable("FNFAssets", {
                "getImage": function(path:String):FlxGraphic {
                    return FNFAssets.returnAsset(IMAGE, path);
                },
                "getSparrow": function(path:String):FlxAtlasFrames {
                    return FNFAssets.returnAsset(SPARROW, path);
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
            setVariable("Transition", Transition);
            setVariable("Alphabet", ui.Alphabet);
            setVariable("SongLoader", gameplay.Song.SongLoader);

            setVariable("HealthIcon", ui.HealthIcon);

            // Game states
            setVariable("TitleState", states.TitleState);
            setVariable("MainMenu", states.MainMenu);
            setVariable("FreeplayMenu", states.FreeplayMenu);

            setVariable("PlayState", PlayState);

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

	public function start()
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

		if (executedScript)
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
				log("ERROR Caused in " + func + " with " + Std.string(args) + " args", true);
			}
		}

		for (otherScript in otherScripts)
		{
			otherScript.callFunction(func, args);
		}
	}

    public function setVariable(variable:String, value:Dynamic)
        interp.variables.set(variable, value);
}
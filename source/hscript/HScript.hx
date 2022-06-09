package hscript;

import base.Conductor;
import base.CoolUtil;
import base.MusicBeat.MusicBeatState;
import base.SongLoader;
import flixel.FlxG;
import hscript.Interp;
import hscript.Parser;
import states.PlayState;
import ui.Alphabet;
import ui.HealthIcon;
import ui.NotificationToast;
import ui.playState.NoteSplash;

using StringTools;

class HScript
{
	public var script:String;

	public var parser:Parser = new Parser();
	public var program:Expr;
	public var interp:Interp = new Interp();

	public var otherScripts:Array<HScript> = [];

	public var executedScript:Bool = false;

	public var state:Dynamic;

	public function new(hscriptPath:String)
	{
		program = parser.parseString(GenesisAssets.getAsset(hscriptPath, HSCRIPT));

		// parser settings
		parser.allowJSON = true;
		parser.allowTypes = true;
		parser.allowMetadata = true;

		// global class shit

		// haxeflixel classes
		interp.variables.set("FlxG", flixel.FlxG);
		interp.variables.set("OpenFLAssets", openfl.utils.Assets);
		interp.variables.set("Assets", lime.utils.Assets);
		interp.variables.set("GenesisAssets", HScriptGenesisAssets);
		interp.variables.set("FlxSprite", flixel.FlxSprite);
		interp.variables.set("FNFSprite", funkin.FNFSprite);
		interp.variables.set("FlxMath", flixel.math.FlxMath);
		interp.variables.set("Math", Math);
		interp.variables.set("Std", Std);

		// game classes
		interp.variables.set("NotificationToast", NotificationToast);
		interp.variables.set("SongLoader", SongLoader);
		interp.variables.set("Alphabet", Alphabet);
		interp.variables.set("NoteSplash", NoteSplash);
		interp.variables.set("HealthIcon", HealthIcon);
		interp.variables.set("Init", Init);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("CoolUtil", CoolUtil);
		interp.variables.set("Stage", null);
		// use stage.addSprite(sprite, "layerTypeHere") to add shit to the stage

		// function shits

		interp.variables.set("trace", function(text:String)
		{
			log(text, true);
		});

		interp.variables.set("loadScript", function(scriptPath:String)
		{
			var new_script = new HScript(GenesisAssets.getAsset(scriptPath, HSCRIPT));
			new_script.start();
			new_script.callFunction("createPost");

			otherScripts.push(new_script);
		});

		interp.variables.set("otherScripts", otherScripts);

		// playstate local shit
		interp.variables.set("bf", PlayState.instance.bf);
		interp.variables.set("gf", PlayState.instance.gf);
		interp.variables.set("dad", PlayState.instance.dad);

		interp.variables.set("removeDefaultStage", null);
		interp.variables.set("startCountdown", PlayState.instance.startCountdown);

		interp.variables.set("import", function(className:String)
		{
			var splitClassName = [for (e in className.split(".")) e.trim()];
			var realClassName = splitClassName.join(".");
			var cl = Type.resolveClass(realClassName);
			var en = Type.resolveEnum(realClassName);
			if (cl == null && en == null)
			{
				log('Class / Enum at $realClassName does not exist.', true);
			}
			else
			{
				if (en != null)
				{
					// ENUM!!!!
					var enumThingy = {};
					for (c in en.getConstructors())
					{
						Reflect.setField(enumThingy, c, en.createByName(c));
					}
					interp.variables.set(splitClassName[splitClassName.length - 1], enumThingy);
				}
				else
				{
					// CLASS!!!!
					interp.variables.set(splitClassName[splitClassName.length - 1], cl);
				}
			}
		});
	}

	public function log(text, ?doTrace:Bool = false)
	{
		if (doTrace)
			trace(text);

		PlayState.logs.push(text);
	}

	public function start()
	{
		executedScript = true;
		try
		{
			interp.variables.set("curState", state);
			interp.execute(program);
		}
		catch (e)
		{
			executedScript = false;
			log(e.details(), true);

			if (state != null)
			{
				state.toasts.add(new NotificationToast("HScript Error",
					"An error happened in one of your scripts! Check the logs by pausing and choosing logs.", NotificationToast.presetColors["ERROR"], ERROR));
			}
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

				if (state != null)
				{
					state.toasts.add(new NotificationToast("HScript Error",
						"An error happened in one of your scripts! Check the logs by pausing and choosing logs.", NotificationToast.presetColors["ERROR"],
						ERROR));
				}
			}
		}

		for (otherScript in otherScripts)
		{
			otherScript.callFunction(func, args);
		}
	}
}

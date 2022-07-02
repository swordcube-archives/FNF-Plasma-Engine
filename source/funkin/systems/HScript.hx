package funkin.systems;

import funkin.game.FunkinState;
import funkin.game.GlobalVariables;
import funkin.game.PlayState;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

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
        #if MODS_ALLOWED
		program = parser.parseString(FunkinAssets.getText(hscriptPath, softmod.SoftMod.modsList[GlobalVariables.selectedMod]));
        #else
        program = parser.parseString(FunkinAssets.getText(hscriptPath));
        #end

		// parser settings
		parser.allowJSON = true;
		parser.allowTypes = true;
		parser.allowMetadata = true;

		// global class shit

		// haxeflixel classes
		interp.variables.set("FlxG", flixel.FlxG);
        interp.variables.set("Paths", funkin.systems.Paths);
		interp.variables.set("OpenFLAssets", openfl.utils.Assets);
		interp.variables.set("Assets", lime.utils.Assets);
		interp.variables.set("FlxSprite", flixel.FlxSprite);
        interp.variables.set("FunkinAssets", funkin.systems.FunkinAssets);
		interp.variables.set("FunkinSprite", funkin.game.FunkinSprite);
		interp.variables.set("FlxSound", flixel.system.FlxSound);
		interp.variables.set("FlxMath", flixel.math.FlxMath);
		interp.variables.set("FlxText", flixel.text.FlxText);
		interp.variables.set("FlxAxes", flixel.util.FlxAxes);
		interp.variables.set("Math", Math);
		interp.variables.set("Std", Std);

		// game classes
		//interp.variables.set("NotificationToast", NotificationToast);
        interp.variables.set("GlobalVariables", GlobalVariables);
		interp.variables.set("SongLoader", funkin.game.Song.SongLoader);
		interp.variables.set("Alphabet", funkin.ui.Alphabet);
		//interp.variables.set("NoteSplash", funkin.ui.playstate.NoteSplash);
		interp.variables.set("HealthIcon", funkin.ui.HealthIcon);
		interp.variables.set("Init", Init);
		interp.variables.set("Conductor", funkin.systems.Conductor);

		// states
		interp.variables.set("TitleState", funkin.menus.TitleState);
		interp.variables.set("MainMenu", funkin.menus.MainMenu);
		//interp.variables.set("StoryMenu", StoryMenu);
		interp.variables.set("FreeplayMenu", funkin.menus.FreeplayMenu);
		interp.variables.set("PlayState", funkin.game.PlayState);
		//interp.variables.set("ModsMenu", ModsMenu);
		//interp.variables.set("ModState", ModState);
		//interp.variables.set("OptionsMenu", OptionsMenu);
		interp.variables.set("FunkinState", funkin.game.FunkinState);
		interp.variables.set("Utilities", Utilities);

		// function shits

		interp.variables.set("trace", function(text:String)
		{
			log(text, true);
		});

		interp.variables.set("loadScript", function(scriptPath:String)
		{
			var new_script = new HScript(scriptPath);
			new_script.start();
			new_script.callFunction("createPost");

			otherScripts.push(new_script);
		});

		interp.variables.set("otherScripts", otherScripts);

		// playstate local shit
		interp.variables.set("bf", PlayState.bf);
		interp.variables.set("gf", PlayState.gf);
		interp.variables.set("dad", PlayState.dad);

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
}

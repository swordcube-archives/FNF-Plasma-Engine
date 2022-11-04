package funkin.states;

import scripting.Script;
import scripting.HScriptModule;
import scripting.ScriptModule;
import openfl.media.Sound;

using StringTools;

class StoryMenu extends FunkinState {
	public var defaultBehavior:Bool = true;
	var script:ScriptModule;
	
	var cachedSounds:Map<String, Sound> = [
		"scroll"  => Assets.load(SOUND, Paths.sound("menus/scrollMenu")),
		"cancel"  => Assets.load(SOUND, Paths.sound("menus/cancelMenu")),
		"confirm" => Assets.load(SOUND, Paths.sound("menus/confirmMenu")),
	];

	override function create() {
		super.create();

		DiscordRPC.changePresence(
            "In the Story Menu",
            null
        );

		script = Script.create(Paths.script("data/states/StoryMenu"));
		if(Std.isOfType(script, HScriptModule)) cast(script, HScriptModule).setScriptObject(this);
		script.start(true, []);

		if(!defaultBehavior) return;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		script.call("onUpdate", [elapsed]);
		script.call("update", [elapsed]);

		if(!defaultBehavior) return;
		if(Controls.getP("back")) {
			FlxG.sound.play(cachedSounds["cancel"]);
			Main.switchState(new MainMenu());
		}
	}
}

package;

import lime.app.Application;
import openfl.Lib;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import funkin.states.FunkinState;

class Init extends FunkinState {
    override function create() {
        super.create();

        FlxG.fixedTimestep = false;
		FlxG.mouse.visible = false;

        FlxG.save.bind("PlasmaEngine", "options");
		Settings.init();
		Controls.init();
		Lib.current.stage.frameRate = Settings.get("Framerate Cap");
		if(FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if(FlxG.save.data.currentMod != null)
			Paths.currentMod = FlxG.save.data.currentMod;
		else {
			FlxG.save.data.currentMod = Paths.currentMod;
			FlxG.save.flush();
		}
		FlxG.keys.preventDefaultKeys = [TAB];

        var rpcConfig:DiscordRPCConfig = TJSON.parse(Assets.load(TEXT, Paths.json("data/discordRPC")));
        DiscordRPC.data = rpcConfig;
        DiscordRPC.initialize(rpcConfig.clientID);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
			switch(e.keyCode) {
				case Keyboard.F11:
					FlxG.fullscreen = !FlxG.fullscreen;
			}
		});
		Application.current.onExit.add(function(exitCode) {
			DiscordRPC.shutdown();
			Settings.flush();
		});

        Main.switchState(new funkin.states.TitleScreen(), false);
    }
}
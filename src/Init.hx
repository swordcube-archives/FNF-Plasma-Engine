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

		// This is here so you can't softlock your copy of the engine.
		if(Settings.get("Framerate Cap") < 10) Settings.set("Framerate Cap", 10);
		if(Settings.get("Framerate Cap") > 1000) Settings.set("Framerate Cap", 1000);

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

		#if debug
		// This basically allows me to add assets to the source code's assets folder
		// and have those assets be used, So i don't have to recompile every time i add an asset
		// or deal with the hellhole that can be the export folder.
		trace(Sys.args());
		if(Sys.args().contains("-livereload")) Main.developerMode = true;
		#end

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

		Conductor.init();
        Main.switchState(new funkin.states.TitleScreen(), false);
    }
}
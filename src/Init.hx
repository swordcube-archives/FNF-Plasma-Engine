package;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import funkin.windows.WindowsAPI;
import funkin.system.AudioSwitchFix;
import lime.app.Application;
import flixel.FlxState;

class Init extends FlxState {
    override function create() {
        super.create();

		FlxG.save.bind('plasmaengine', 'swordcube');

		var playerID:Int = -1;
		if(FlxG.save.data.playerID != null) playerID = FlxG.save.data.playerID;
		else {
			playerID = 1;
			FlxG.save.data.playerID = playerID;
			FlxG.save.flush();
		}

		if(FlxG.save.data.currentMod != null)
			Paths.currentMod = FlxG.save.data.currentMod;
		else {
			FlxG.save.data.currentMod = Paths.currentMod;
			FlxG.save.flush();
		}

		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init(playerID);
		Console.init();
		Highscore.load();
    	Conductor.init();
		AudioSwitchFix.init();
		WindowsAPI.setDarkMode(true);

		Console.fancyText = PlayerSettings.prefs.get("Fancy Console");

		// Exclusive to Leather128 flixel (and maybe Yoshi flixel soon) because fuck you 😎️
		FlxSprite.defaultAntialiasing = PlayerSettings.prefs.get("Antialiasing");

		FlxG.stage.frameRate = PlayerSettings.prefs.get("Framerate Cap");
		FlxG.autoPause = PlayerSettings.prefs.get("Auto Pause");

		FlxG.mouse.visible = false;
        FlxG.fixedTimestep = false;
		
		// why does flixel not automatically do this bro 💀
        if(FlxG.save.data.volume != null) FlxG.sound.volume = FlxG.save.data.volume;

		#if debug
		if(Sys.args().contains("-livereload")) Main.developerMode = true;
		#end

		#if discord_rpc
		DiscordRPC.initialize();
		#end

		Application.current.onExit.add(function(exitCode) {
			FlxG.save.data.volume = FlxG.sound.volume;
			PlayerSettings.controls.flush();
			PlayerSettings.prefs.flush();
			#if discord_rpc
			DiscordRPC.shutdown();
			#end
		});

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
			switch(e.keyCode) {
				case Keyboard.F11:
					FlxG.fullscreen = !FlxG.fullscreen;
			}
		});

		// Make transitions work
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.45, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.45, new FlxPoint(0, 1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		// pizza roll
		trace("PIZZA ROLL!");
		var goodMD5:String = "4faf725d2823199a5ae0e71bc2d5db18";
		var gottenMD5:String = haxe.crypto.Md5.encode(File.getContent('${Sys.getCwd()}assets/images/pizzarolls.png'));
		if(gottenMD5 == goodMD5) {
			Console.info("Pizza rolls png is untouched! You may continue on.");
		} else {
			Console.error("Pizza rolls png has been modified or deleted. You may NOT continue on! Fuck you!");
			var rehe:Dynamic = null;
			rehe.intentionalNullError();
		}

		FlxG.switchState(new funkin.states.menus.TitleState());
    }
}
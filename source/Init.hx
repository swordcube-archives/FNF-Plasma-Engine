package;

import lime.app.Application;
import misc.Keybinds;
#if discord_rpc
import misc.DiscordRPC;
#end

class Init extends Scene {
    override function create() {
        super.create();

        FlxG.save.bind("PlasmaEngine", "PlasmaOptions");

        if(FlxG.save.data.volume != null)
            FlxG.sound.volume = FlxG.save.data.volume;

        Settings.init();
        Keybinds.init();
        Highscore.init();

        FlxG.mouse.useSystemCursor = true; // Makes the game use the system cursor because it looks nicer.
		FlxG.mouse.visible = false;        // Hide the mouse cursor by default.
		FlxG.fixedTimestep = false;        // Makes the game not run dependent of FPS.

        FlxG.keys.preventDefaultKeys = [TAB]; // Prevents tab from unfocusing the game.

        Main.switchScene(Type.createInstance(Main.gameInfo.startingScene, Main.gameInfo.startingSceneArgs), false);

        #if discord_rpc
        var rpcConfig:DiscordRPCConfig = Assets.get(JSON, Paths.json("discordRPC"));
        DiscordRPC.data = rpcConfig;
        DiscordRPC.initialize(rpcConfig.clientID);
        #end

        Application.current.onExit.add(function(exitCode) {
            #if discord_rpc
            DiscordRPC.shutdown();
            #end
            Settings.save();
        });
    }
}
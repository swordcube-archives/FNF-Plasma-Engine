package base;

#if discord_rpc
import Sys.sleep;
import discord_rpc.DiscordRpc;
#end

using StringTools;

typedef DiscordRPCConfig = {
    var clientID:String;
    var largeImageKey:String;
    var largeImageText:String;
};

/**
 * A class for handling Discord Rich Presence.
 */
class DiscordRPC {
    public static var data:DiscordRPCConfig = {
        clientID: "",
        largeImageKey: "",
        largeImageText: ""
    };
    public static var dontDoTitle:Bool = false;
    
	public function new(clientID:String = "969729521341329449") {
		#if discord_rpc
		trace("Discord RPC starting...");
		DiscordRpc.start({
			clientID: clientID,
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord RPC started.");

		while (true) {
			DiscordRpc.process();
			sleep(2);
		}
		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown() {
		#if discord_rpc
		DiscordRpc.shutdown();
		#end
	}

	static function onReady() {
		#if discord_rpc		
        var shit:Null<String> = dontDoTitle ? null : "In the Title Screen";
		DiscordRpc.presence({
			details: shit,
			state: null,
			largeImageKey: data.largeImageKey,
			largeImageText: data.largeImageText
		});
        dontDoTitle = false;
		#end
	}

	static function onError(_code:Int, _message:String) {
		#if discord_rpc
		Console.error('Discord RPC Error! $_code : $_message');
		#end
	}

	static function onDisconnected(_code:Int, _message:String) {
		#if discord_rpc
		Console.error('Discord RPC Disconnected! $_code : $_message');
		#end
	}

	public static function initialize(clientID:String = "969729521341329449", noTitle:Bool = false) {
		#if discord_rpc
        var DiscordDaemon = sys.thread.Thread.create(() -> {
            dontDoTitle = noTitle;
            new DiscordRPC(clientID);
        });
		#end
    }

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
		#if discord_rpc
		var startTimestamp:Float = hasStartTimestamp ? Date.now().getTime() : 0;
		if (endTimestamp > 0) endTimestamp = startTimestamp + endTimestamp;
		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: data.largeImageKey,
			largeImageText: data.largeImageText,
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});
		#end
	}
}
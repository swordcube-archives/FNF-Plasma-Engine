package;

#if discord_rpc
import Sys.sleep;
import discord_rpc.DiscordRpc;
import Init.DiscordRPCConfig;

using StringTools;

class DiscordRPC
{
    public static var data:DiscordRPCConfig;
    public static var dontDoTitle:Bool = false;
    
	public function new(clientID:String = "969729521341329449")
	{
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: clientID,
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			//trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}
	
	static function onReady()
	{
        var shit:Null<String> = dontDoTitle ? null : "In the Title Screen";
		DiscordRpc.presence({
			details: shit,
			state: null,
			largeImageKey: data.largeImageKey,
			largeImageText: data.largeImageText
		});
        dontDoTitle = false;
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize(clientID:String = "969729521341329449", noTitle:Bool = false)
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
            dontDoTitle = noTitle;
			new DiscordRPC(clientID);
		});
		trace("Discord Client initialized");
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

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

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
}
#end
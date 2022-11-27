package funkin.system;

import lime.media.AudioManager;
import flixel.system.FlxSound;
import flixel.FlxState;
import funkin.windows.WindowsAPI;
import flixel.FlxG;

/**
 * if youre stealing this keep this comment at least please lol
 * alright i can atleast do that (i want this audio fix ok don't murder me for taking this
 * the real YoshiCrafter29 😭😭😭😭😭 👍) - swordclormbert
 * 
 * hi gray itsa me yoshicrafter29 i fixed it hehe
 */
@:dox(hide)
class AudioSwitchFix {
	@:noCompletion
	private static function onStateSwitch(state:FlxState):Void {
		#if windows
			if (Main.audioDisconnected) {

				var playingList:Array<PlayingSound> = [];
				for(e in FlxG.sound.list) {
					if (e.playing) {
						playingList.push({
							sound: e,
							time: e.time
						});
						e.stop();
					}
				}
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
				
                AudioManager.shutdown();
                AudioManager.init();
				// #if !lime_doc_gen
				// if (AudioManager.context.type == OPENAL)
				// {
				// 	var alc = AudioManager.context.openal;

				// 	var device = alc.openDevice();
				// 	var ctx = alc.createContext(device);
				// 	alc.makeContextCurrent(ctx);
				// 	alc.processContext(ctx);
				// }
				// #end
				Main.changeID++;
				
				for(e in playingList) {
					e.sound.play(e.time);
				}

				Main.audioDisconnected = false;
			}
		#end
	}

    public static function init() {
        #if windows
		WindowsAPI.registerAudio();
        FlxG.signals.preStateCreate.add(onStateSwitch);
        #end
    }
}

typedef PlayingSound = {
	var sound:FlxSound;
	var time:Float;
}
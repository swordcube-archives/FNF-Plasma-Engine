package funkin.system;

import openfl.media.Sound;
import flixel.graphics.FlxGraphic;

class FNFTools {
    public static function getCountdownTextures(countdownSkin:String):Map<String, FlxGraphic> {
        // Get the correct paths to the images
        var fallbackTexPaths:Array<String> = [
			Paths.image('game/countdown/default/ready'),
			Paths.image('game/countdown/default/set'),
			Paths.image('game/countdown/default/go'),
		];
		var texPaths:Array<String> = [
			Paths.image('game/countdown/$countdownSkin/ready'),
			Paths.image('game/countdown/$countdownSkin/set'),
			Paths.image('game/countdown/$countdownSkin/go'),
		];
		var i:Int = 0;
		for(path in texPaths) {
			if(!FileSystem.exists(path)) texPaths[i] = fallbackTexPaths[i];
			i++;
		}
        
        // Load the images and return them
        return [
            "ready" => Assets.load(IMAGE, texPaths[0]),
            "set"   => Assets.load(IMAGE, texPaths[1]),
            "go"    => Assets.load(IMAGE, texPaths[2])
        ];
    }

    public static function getCountdownSounds(countdownSkin:String):Map<String, Sound> {
        // Get the correct paths to the sounds
        var fallbackSoundPaths:Array<String> = [
			Paths.sound('game/countdown/default/intro3'),
			Paths.sound('game/countdown/default/intro2'),
            Paths.sound('game/countdown/default/intro1'),
            Paths.sound('game/countdown/default/introGo')
		];
		var soundPaths:Array<String> = [
			Paths.sound('game/countdown/$countdownSkin/intro3'),
			Paths.sound('game/countdown/$countdownSkin/intro2'),
            Paths.sound('game/countdown/$countdownSkin/intro1'),
            Paths.sound('game/countdown/$countdownSkin/introGo')
		];
		var i:Int = 0;
		for(path in soundPaths) {
			if(!FileSystem.exists(path)) soundPaths[i] = fallbackSoundPaths[i];
			i++;
		}
        
        // Load the sounds and return them
        return [
            "3"  => Assets.load(SOUND, soundPaths[0]),
            "2"  => Assets.load(SOUND, soundPaths[1]),
            "1"  => Assets.load(SOUND, soundPaths[2]),
            "go" => Assets.load(SOUND, soundPaths[3]),
        ];
    }
}
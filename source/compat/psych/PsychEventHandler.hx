package compat.psych;

import flixel.FlxG;
import flixel.FlxCamera;
import states.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import gameplay.Events;

using StringTools;

class PsychEventHandler {
    public static function processEvent(event:PsychEvent) {
		switch(event.name) {
			case "Hey!":
				var value:Int = 2;
				switch(event.value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(event.value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(PlayState.current.dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						PlayState.current.dad.playAnim('cheer', true);
						PlayState.current.dad.specialAnim = true;
						PlayState.current.dad.animTimer = time;
					} else if (PlayState.current.gf != null) {
						PlayState.current.gf.playAnim('cheer', true);
						PlayState.current.gf.specialAnim = true;
						PlayState.current.gf.animTimer = time;
					}
				}
				if(value != 1) {
					PlayState.current.bf.playAnim('hey', true);
					PlayState.current.bf.specialAnim = true;
					PlayState.current.bf.animTimer = time;
				}

			case 'Change Scroll Speed':
				if (Settings.get("Scroll Speed") > 0)
					return;
				var val1:Float = Std.parseFloat(event.value1);
				var val2:Float = Std.parseFloat(event.value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = PlayState.SONG.speed * val1;

				if(val2 <= 0)
					PlayState.current.scrollSpeed = newValue;
				else {
					PlayState.current.scrollSpeedTween = FlxTween.tween(PlayState.current, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween) {
							PlayState.current.scrollSpeedTween = null;
						}
					});
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [event.value1, event.value2];
				var targetsArray:Array<FlxCamera> = [PlayState.current.camGame, PlayState.current.camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case "Add Camera Zoom":
				var camZoom:Float = Std.parseFloat(event.value1);
				var hudZoom:Float = Std.parseFloat(event.value2);
				if(Math.isNaN(camZoom)) camZoom = 0.015;
				if(Math.isNaN(hudZoom)) hudZoom = 0.03;

				FlxG.camera.zoom += camZoom;
				PlayState.current.camHUD.zoom += hudZoom;
		}
	}
}
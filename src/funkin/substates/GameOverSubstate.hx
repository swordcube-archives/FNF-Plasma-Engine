package funkin.substates;

import openfl.media.Sound;
import funkin.scripting.events.SubStateCreationEvent;
import funkin.scripting.Script;
import funkin.states.PlayState;
import funkin.game.Character;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends FNFSubState {
	var bf:Character;
	var camFollow:FlxObject;

	public static var deathSound:String = "";
	public static var deathMusic:String = "";
	public static var retrySound:String = "";

	public static function reset() {
		deathSound = Paths.sound('game/deathSound');
		deathMusic = Paths.music('death/default');
		retrySound = Paths.sound('game/retrySound');
	}

	public var script:ScriptModule;
	public var runDefaultCode:Bool = true;

	public var randomGameover:Int = 1;
	public var playingDeathSound:Bool = false;

	public var insultSound:Sound;

	var week7Songs:Array<String> = [
		"ugh",
		"guns",
		"stress"
	];

	public function new(x:Float, y:Float, char:String = "bf-dead") {
		super();

		var exclude:Array<Int> = [];
		// if (prefs.get("censor-naughty"))
		// 	exclude = [1, 3, 8, 13, 17, 21];
		randomGameover = FlxG.random.int(1, 25, exclude);

		if(week7Songs.contains(PlayState.SONG.name.toLowerCase()))
			insultSound = Assets.load(SOUND, Paths.sound('game/week7/jeffGameover/jeffGameover-' + randomGameover));

		script = Script.load(Paths.script('data/substates/GameOverSubstate'));
		var event = script.event("onSubStateCreation", new SubStateCreationEvent(this));

		if(!event.cancelled) {
			Conductor.position = 0;

			bf = new Character(x, y, true).loadCharacter(char);
			add(bf);

			camFollow = new FlxObject(0, 0, 1, 1);
			add(camFollow);

			FlxG.sound.play(Assets.load(SOUND, deathSound));
			Conductor.bpm = 100;

			FlxG.camera.target = null;
			FlxG.camera.scroll.set();

			bf.playAnim('firstDeath');
		} else runDefaultCode = false;
	}

	override function update(elapsed:Float) {
		script.call("onUpdate", [elapsed]);
		script.call("update", [elapsed]);

		super.update(elapsed);

		if(runDefaultCode) {
			if (controls.getP("ACCEPT")) endBullshit();

			if (controls.getP("BACK")) {
				FlxG.sound.music.stop();

				if (PlayState.isStoryMode)
					FlxG.switchState(new funkin.states.menus.StoryMenuState());
				else
					FlxG.switchState(new funkin.states.menus.FreeplayState());
			}

			if (bf.animation.curAnim != null && bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12) {
				camFollow.setPosition(bf.getGraphicMidpoint().x + bf.positionOffset.x, bf.getGraphicMidpoint().y + bf.positionOffset.y);
				FlxG.camera.follow(camFollow, LOCKON, 0.01);
			}

			if(week7Songs.contains(PlayState.SONG.name.toLowerCase())) {
				if(bf.animation.curAnim != null && bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !playingDeathSound) {
					bf.playAnim('deathLoop');
					playingDeathSound = true;
					coolStartDeath(0.2);
					FlxG.sound.play(insultSound, 1, false, null, true, function() {
						FlxG.sound.music.fadeIn(4, 0.2, 1);
					});
				}
			} else if (bf.animation.curAnim != null && bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished) {
				bf.playAnim('deathLoop');
				coolStartDeath();
			}

			if (FlxG.sound.music.playing) Conductor.position = FlxG.sound.music.time;
		}

		script.call("onUpdatePost", [elapsed]);
		script.call("updatePost", [elapsed]);
	}

	function coolStartDeath(?startVol:Float = 1) {
		FlxG.sound.playMusic(Assets.load(SOUND, deathMusic), startVol);
	}

	var isEnding:Bool = false;

	function endBullshit():Void {
		if (!isEnding) {
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Assets.load(SOUND, retrySound));
			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
					FlxG.switchState(new PlayState());
				});
			});
		}
	}
}

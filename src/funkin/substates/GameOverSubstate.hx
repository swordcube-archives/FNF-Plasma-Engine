package funkin.substates;

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

	public function new(x:Float, y:Float, char:String = "bf-dead") {
		super();

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
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.getP("ACCEPT")) {
			endBullshit();
		}

		if (controls.getP("BACK")) {
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new funkin.states.menus.StoryMenuState());
			else
				FlxG.switchState(new funkin.states.menus.FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12) {
			camFollow.setPosition(bf.getGraphicMidpoint().x + bf.positionOffset.x, bf.getGraphicMidpoint().y + bf.positionOffset.y);
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished) {
			bf.playAnim('deathLoop');
			FlxG.sound.playMusic(Assets.load(SOUND, deathMusic));
		}

		if (FlxG.sound.music.playing) {
			Conductor.position = FlxG.sound.music.time;
		}
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

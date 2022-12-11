package funkin.substates;

import flixel.util.FlxStringUtil;
import funkin.scripting.Script;
import flixel.util.FlxTimer;
import funkin.ui.Alphabet;
import flixel.math.FlxMath;
import funkin.states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends FNFSubState {
	public var grpMenuShit:FlxTypedGroup<Alphabet>;

	public var menuItems:Array<String> = [
		'Resume', 
		'Restart Song', 
		'Skip Intro',
		'Skip Time',
		'Exit to menu'
	];

	public var curSelected:Int = 0;

	public var pauseMusic:FlxSound;

	public var script:ScriptModule;
	public var runDefaultCode:Bool = true;

	public var timeTxt:FlxText;
	public var curTime:Float = Conductor.position;

	var oldFollowLerp:Float = 0.0;

	public function new() {
		super();

		oldFollowLerp = FlxG.camera.followLerp;

		script = Script.load(Paths.script('data/substates/PauseSubState'));
		script.setParent(this);
		script.run();

		DiscordRPC.changePresence(
			"Paused",
			'${PlayState.SONG.name} - ${PlayState.curDifficulty}'
		);

		if(PlayState.current.startingSong || !PlayState.current.canSkipIntro || PlayState.current.unsortedNotes.length < 1)
			menuItems.remove('Skip Intro');

		FlxG.sound.music.pause();
		PlayState.current.vocals.pause();

		if(curTime < 0) curTime = 0;

		if(runDefaultCode) {
			FlxG.camera.followLerp = 0;
			pauseMusic = new FlxSound().loadEmbedded(Assets.load(SOUND, Paths.music('pauseMusic')), true, true);
			pauseMusic.volume = 0;
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

			FlxG.sound.list.add(pauseMusic);

			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			add(bg);

			var levelInfo:FlxText = new FlxText(20, 15, 0, PlayState.SONG.name, 32);
			levelInfo.scrollFactor.set();
			levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
			levelInfo.updateHitbox();
			add(levelInfo);

			var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, PlayState.curDifficulty.toUpperCase(), 32);
			levelDifficulty.scrollFactor.set();
			levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
			levelDifficulty.updateHitbox();
			add(levelDifficulty);

			levelDifficulty.alpha = 0;
			levelInfo.alpha = 0;

			levelInfo.x = FlxG.width - (levelInfo.width + 20);
			levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

			FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
			FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
			FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

			timeTxt = new FlxText(0, 0, 0, "0:00 / 0:00", 64);
			timeTxt.scrollFactor.set();
			timeTxt.setFormat(Paths.font('vcr.ttf'), 64);
			timeTxt.updateHitbox();
			timeTxt.screenCenter();
			timeTxt.x += 150;
			timeTxt.y += 20;
			timeTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 5);
			timeTxt.visible = false;
			add(timeTxt);

			grpMenuShit = new FlxTypedGroup<Alphabet>();
			add(grpMenuShit);

			for (i in 0...menuItems.length) {
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, Bold, menuItems[i]);
				songText.isMenuItem = true;
				songText.targetY = i;
				grpMenuShit.add(songText);
			}

			changeSelection();
		}

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		script.createPostCall();
	}

	var holdTimer:Float = 0.0;

	override function update(elapsed:Float) {
        script.updateCall(elapsed);
        super.update(elapsed);

		// don't ask why i'm doing this on update
		// flixel is being a shit head
		FlxG.sound.music.pause();
		PlayState.current.vocals.pause();

		if (runDefaultCode) {
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * elapsed;

			if(menuItems[curSelected] == "Skip Time") {
				timeTxt.setPosition(grpMenuShit.members[curSelected].x + 500, grpMenuShit.members[curSelected].y);
				if(controls.get("UI_LEFT") || controls.get("UI_RIGHT"))
					holdTimer += elapsed;
				else
					holdTimer = 0.0;
		
				if(controls.getP("UI_LEFT") || controls.getP("UI_RIGHT") || holdTimer > 0.5) {
					curTime = FlxMath.bound(curTime + (controls.get("UI_LEFT") ? -500 : 500), 0, FlxG.sound.music.length);
					timeTxt.text = FlxStringUtil.formatTime(curTime/1000.0) + " / " + FlxStringUtil.formatTime(FlxG.sound.music.length/1000.0);
		
					if(holdTimer > 0.6) holdTimer = 0.5;
				}
			} else {
				holdTimer = 0.0;
			}

			if (controls.getP("UI_UP")) changeSelection(-1);
			if (controls.getP("UI_DOWN")) changeSelection(1);

			if (controls.getP("ACCEPT")) {
				FlxG.camera.followLerp = oldFollowLerp;
				switch (menuItems[curSelected]) {
					case "Resume":
						//resume all tweens and timers
						FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {
							if (!tmr.finished)
								tmr.active = true;
						});
						FlxTween.globalManager.forEach(function(twn:FlxTween) {
							if (!twn.finished)
								twn.active = true;
						});
						var game = PlayState.current;
						PlayState.paused = false;
						if(!game.startingSong) {
							FlxG.sound.music.play();
							game.vocals.play();
						}
						game.resyncSong();
						game.updateRPC();
						close();

					case "Restart Song":
						PlayState.paused = false;
						FlxTransitionableState.skipNextTransIn = false;
						FlxTransitionableState.skipNextTransOut = false;
						FlxG.resetState();

					case "Skip Time":
						if(curTime != Conductor.position) {
							PlayState.current.clearNotesBefore(curTime);
	
							if(PlayState.current.startingSong)
								PlayState.current.startSong();
	
							if(PlayState.current.countdownTimer != null)
								PlayState.current.countdownTimer.cancel();
					
							FlxG.sound.music.time = curTime;
							FlxG.sound.music.play();
					
							if(Conductor.position <= PlayState.current.vocals.length)
								PlayState.current.vocals.time = curTime;
							
							PlayState.current.vocals.play();
							Conductor.position = curTime;
	
							if(curTime >= FlxG.sound.music.length)
								PlayState.current.endSong();
	
							Conductor.update();
						} else {
							FlxG.sound.music.play();
							PlayState.current.vocals.play();
						}

						//resume all tweens and timers
						FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {
							if (!tmr.finished)
								tmr.active = true;
						});
						FlxTween.globalManager.forEach(function(twn:FlxTween) {
							if (!twn.finished)
								twn.active = true;
						});
						PlayState.paused = false;
						close();

					case "Skip Intro":
						PlayState.current.canSkipIntro = false;

						//resume all tweens and timers
						FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {
							if (!tmr.finished)
								tmr.active = true;
						});
						FlxTween.globalManager.forEach(function(twn:FlxTween) {
							if (!twn.finished)
								twn.active = true;
						});
						var game = PlayState.current;
						PlayState.paused = false;

						FlxG.sound.music.time = game.unsortedNotes[0].strumTime - 1500.0;
						game.vocals.time = FlxG.sound.music.time;
						Conductor.position = FlxG.sound.music.time;

						FlxG.sound.music.play();
						game.vocals.play();
						close();

					case "Exit to menu":
						FlxG.sound.playMusic(Assets.load(SOUND, Paths.music("menuMusic")));
						PlayState.paused = false;
						FlxTransitionableState.skipNextTransIn = false;
						FlxTransitionableState.skipNextTransOut = false;
						if(PlayState.isStoryMode)
							FlxG.switchState(new funkin.states.menus.StoryMenuState());
						else
							FlxG.switchState(new funkin.states.menus.FreeplayState());
				}
			}
		}

        script.updatePostCall(elapsed);
	}

	override function destroy() {
		for(func in ["onDestroy", "destroy"]) script.call(func);
		if (runDefaultCode) pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);

		var bullShit:Int = 0;

		for (item in grpMenuShit.members) {
			item.targetY = bullShit - curSelected;
			item.alpha = curSelected == bullShit ? 1 : 0.6;
			bullShit++;
		}

		timeTxt.visible = menuItems[curSelected] == "Skip Time";
		timeTxt.text = FlxStringUtil.formatTime(curTime/1000.0) + " / " + FlxStringUtil.formatTime(FlxG.sound.music.length/1000.0);
		
		FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/scrollMenu")));
	}
}

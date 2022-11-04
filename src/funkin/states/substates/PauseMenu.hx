package funkin.states.substates;

import scripting.Script;
import scripting.HScriptModule;
import scripting.ScriptModule;
import flixel.util.FlxStringUtil;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;

class PauseMenu extends FunkinSubState {
	public var defaultBehavior:Bool = true;
	var script:ScriptModule;

	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [
        'Resume', 
        'Restart Song',
        'Skip Time',
        'Exit To Menu'
    ];
	var curSelected:Int = 0;
	var pauseMusic:FlxSound;

    var curTime:Float = Conductor.position;
    var timeTxt:FlxText;

	public function new() {
		super();

		DiscordRPC.changePresence(
            "In the Freeplay Menu",
            null
        );

		script = Script.create(Paths.script("data/states/substates/PauseMenu"));
		if(Std.isOfType(script, HScriptModule)) cast(script, HScriptModule).setScriptObject(this);
		script.start(true, []);

		if(!defaultBehavior) return;
		pauseMusic = new FlxSound().loadEmbedded(Assets.load("SOUND", Paths.music('menus/pauseMenu')), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:Sprite = new Sprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, PlayState.songName, 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, PlayState.currentDifficulty.toUpperCase(), 32);
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

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, Bold, menuItems[i]);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

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

		changeSelection();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
    
    var holdTimer:Float = 0.0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		script.call("onUpdate", [elapsed]);
		script.call("update", [elapsed]);

		if(!defaultBehavior) return;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		if(Controls.getP("ui_up"))
			changeSelection(-1);

		if(Controls.getP("ui_down"))
			changeSelection(1);

        if(menuItems[curSelected] == "Skip Time") {
            timeTxt.setPosition(grpMenuShit.members[curSelected].x + 500, grpMenuShit.members[curSelected].y);
            if(Controls.get("ui_left") || Controls.get("ui_right"))
                holdTimer += elapsed;
            else
                holdTimer = 0.0;

            if(Controls.getP("ui_left") || Controls.getP("ui_right") || holdTimer > 0.5) {
                var mult:Float = Controls.get("ui_left") ? -500 : 500;
                curTime = FlxMath.bound(curTime + mult, 0, FlxG.sound.music.length);
                timeTxt.text = FlxStringUtil.formatTime(curTime/1000.0) + " / " + FlxStringUtil.formatTime(FlxG.sound.music.length/1000.0);

                if(holdTimer > 0.5)
                    holdTimer = 0.425;
            }
        } else {
            holdTimer = 0.0;
        }
        
		if(Controls.getP("accept")) {
			switch(menuItems[curSelected]) {
				case "Resume":
                    resumeGame();
					close();

				case "Restart Song":
					PlayState.paused = false;
					Main.resetState();
                    close();

                case "Skip Time":
                    if(curTime != Conductor.position) {
						PlayState.paused = false;
                        PlayState.current.clearNotesBefore(curTime);

                        if(!PlayState.current.startedSong)
                            PlayState.current.startSong();

                        if(PlayState.current.countdownTimer != null)
                            PlayState.current.countdownTimer.cancel();
                
                        FlxG.sound.music.time = curTime;
                        FlxG.sound.music.play();
                
                        if (Conductor.position < PlayState.current.vocals.length)
                            PlayState.current.vocals.time = curTime;
                        
                        PlayState.current.vocals.play();
                        Conductor.position = curTime;
                    } else resumeGame();
                    close();

				case "Exit To Menu":
                    exitToMenu();
					close();
			}
		}
	}

    public function exitToMenu() {
		if(!defaultBehavior) return;
        PlayState.paused = false;
        if(PlayState.isStoryMode)
            FlxG.switchState(new funkin.states.StoryMenu());
        else
            FlxG.switchState(new funkin.states.FreeplayMenu());
    }

    public function resumeGame() {
		if(!defaultBehavior) return;
        PlayState.paused = false;
        if(PlayState.current.startedSong) {
            FlxG.sound.music.play();
            if(PlayState.current.vocals.time < PlayState.current.vocals.length)
                PlayState.current.vocals.play();
        } else {
            if(PlayState.current.countdownTimer != null)
                PlayState.current.countdownTimer.active = true;
        }
    }

	override function destroy() {
		if(defaultBehavior) pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		if(!defaultBehavior) return;
		curSelected += change;
		if(curSelected < 0)
			curSelected = menuItems.length - 1;
		if(curSelected > menuItems.length - 1)
			curSelected = 0;

		for(i in 0...grpMenuShit.members.length) {
            var item = grpMenuShit.members[i];
			item.targetY = i - curSelected;
			item.alpha = curSelected == i ? 1 : 0.6;
		}
        FlxG.sound.play(Assets.load("SOUND", Paths.sound("menus/scrollMenu")));
        timeTxt.visible = menuItems[curSelected] == "Skip Time";
        timeTxt.text = FlxStringUtil.formatTime(curTime/1000.0) + " / " + FlxStringUtil.formatTime(FlxG.sound.music.length/1000.0);
	}
}

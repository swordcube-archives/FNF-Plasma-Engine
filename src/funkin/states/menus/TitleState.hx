package funkin.states.menus;

import funkin.scripting.events.StateCreationEvent;
import openfl.media.Sound;
import funkin.scripting.Script;
import funkin.ui.Alphabet;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class TitleState extends FNFState {
	public var script:ScriptModule;
	public var runDefaultCode:Bool = true;
	
	public var startedIntro:Bool = false;
	static var initialized:Bool = false;

	public var blackScreen:FlxSprite;
	public var credGroup:FlxGroup;
	public var textGroup:FlxGroup;
	public var ngSpr:FlxSprite;

	public var curWacky:Array<String> = [];

	public var freakyMenu:Sound;

	override public function create():Void {
		curWacky = FlxG.random.getObject(getIntroTextShit());
		super.create();

		script = Script.load(Paths.script('data/states/TitleState'));
		script.setParent(this);
		script.run(false);
		var event = script.event("onStateCreation", new StateCreationEvent(this));

		// hey guys..  .  it's  me. . . . ..... saster
		// YOOO IS THAT SASTICLES/?!!?!@?!@?!@?!@?

		if(!event.cancelled) {
			freakyMenu = Assets.load(SOUND, Paths.music('menuMusic'));
			
			logoBl = new FlxSprite(-150, -100);
			logoBl.frames = Assets.load(SPARROW, Paths.image('menus/title/logoBumpin'));
			logoBl.antialiasing = PlayerSettings.prefs.get("Antialiasing");
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBl.animation.play('bump');
			logoBl.updateHitbox();

			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
			gfDance.frames = Assets.load(SPARROW, Paths.image('menus/title/gfDanceTitle'));
			gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			gfDance.antialiasing = PlayerSettings.prefs.get("Antialiasing");
			add(gfDance);
			add(logoBl);

			titleText = new FlxSprite(100, FlxG.height * 0.8);
			titleText.frames = Assets.load(SPARROW, Paths.image('menus/title/titleEnter'));
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
			titleText.antialiasing = PlayerSettings.prefs.get("Antialiasing");
			titleText.animation.play('idle');
			titleText.updateHitbox();
			add(titleText);

			credGroup = new FlxGroup();
			add(credGroup);
			textGroup = new FlxGroup();

			blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			credGroup.add(blackScreen);

			ngSpr = new FlxSprite(0, FlxG.height * 0.52);

			new FlxTimer().start(1, function(tmr:FlxTimer) {
				startIntro();
			});
		} else runDefaultCode = false;

		Conductor.onBeat.add(beatHit);
		Conductor.onStep.add(stepHit);

		script.event("onStateCreationPost", new StateCreationEvent(this));
	}

	public var logoBl:FlxSprite;
	public var gfDance:FlxSprite;
	public var danceLeft:Bool = false;
	public var titleText:FlxSprite;

	function startIntro() {
		startedIntro = true;

		if (!initialized) {
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
				FlxG.sound.playMusic(freakyMenu, 0);

			FlxG.sound.music.fadeIn(4, 0, 1);
		}

		Conductor.bpm = 102;
		persistentUpdate = true;

		ngSpr.loadGraphic(Assets.load(IMAGE, Paths.image('menus/title/newgrounds_logo')));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = PlayerSettings.prefs.get("Antialiasing");

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>> {
		var fullText:String = Assets.load(TEXT, Paths.txt('data/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray) {
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float) {
		for(func in ["onUpdate", "update"]) script.call(func, [elapsed]);

		super.update(elapsed);

		if(runDefaultCode) {
			if (FlxG.sound.music != null)
				Conductor.position = FlxG.sound.music.time;

			var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
			if (pressedEnter && startedIntro && !transitioning && skippedIntro) {
				if (titleText != null && prefs.get("Flashing Lights"))
					titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Assets.load(SOUND, Paths.sound('menus/confirmMenu')), 0.7);

				transitioning = true;

				new FlxTimer().start(2, function(tmr:FlxTimer) {
					FlxG.switchState(new MainMenuState());
				});
			}

			if (pressedEnter && startedIntro && !skippedIntro)
				skipIntro();
		}

		for(func in ["onUpdate", "update"]) script.call(func+"Post", [elapsed]);
	}

	function createCoolText(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			var money:Alphabet = new Alphabet(0, 0, Bold, textArray[i]);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String) {
		var coolText:Alphabet = new Alphabet(0, 0, Bold, text);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText() {
		while (textGroup.members.length > 0) {
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function beatHit(curBeat:Int) {
		for(func in ["onBeatHit", "beatHit"])
			script.call(func, [curBeat]);

		if(runDefaultCode) {
			logoBl.animation.play('bump', true);
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');

			FlxG.log.add(curBeat);

			switch (curBeat) {
				case 1:
					createCoolText(['swordcube', 'Leather128', 'Stilic', 'Raf']);
				case 3:
					addMoreText('present');
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(['You should', 'go check out']);
				case 7:
					addMoreText('newgrounds');
					ngSpr.visible = true;
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				case 9:
					createCoolText([curWacky[0]]);
				case 11:
					addMoreText(curWacky[1]);
				case 12:
					deleteCoolText();
				case 13:
					addMoreText('Friday');
				case 14:
					addMoreText('Night');
				case 15:
					addMoreText('Funkin');
				case 16:
					skipIntro();
			}
		}

		for(func in ["onBeatHit", "beatHit"])
			script.call(func+"Post", [curBeat]);
	}

	function stepHit(step:Int) {
		for(func in ["onStepHit", "stepHit"]) {
			script.call(func, [step]);
			script.call(func+"Post", [step]);
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void {
		if (!skippedIntro) {
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}

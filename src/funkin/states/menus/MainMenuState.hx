package funkin.states.menus;

import funkin.states.editors.toolbox.ToolboxModSelect;
import funkin.system.ModData.PackData;
import funkin.scripting.Script;
import flixel.FlxState;
import funkin.ui.MainMenuButton;
import funkin.system.FNFSprite;
import funkin.ui.MainMenuList;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class MainMenuState extends FNFState {
	public var curSelected:Int = 0;

	public var magenta:FlxSprite;
	public var list:MainMenuList;

	public var camFollow:FlxObject;

	public var script:ScriptModule;
	public var runDefaultCode:Bool = true;

	override function create() {
		super.create();

		// Updating Discord Rich Presence
		DiscordRPC.changePresence("In the Main Menu", null);

		enableTransitions();

		persistentUpdate = persistentDraw = true;

		script = Script.load(Paths.script('data/states/MainMenuState'));
		if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing)) {
			FlxG.sound.playMusic(Assets.load(SOUND, Paths.music('menuMusic')));
			Conductor.bpm = 102;
		}
		script.setParent(this);
		script.run();

		if(runDefaultCode) {
			var bg = new FNFSprite(-80).load(IMAGE, Paths.image('menus/menuBG'));
			bg.scrollFactor.set(0, 0.17);
			bg.scale.set(1.1, 1.1);
			bg.updateHitbox();
			bg.screenCenter();
			add(bg);

			magenta = new FNFSprite(-80).load(IMAGE, Paths.image('menus/menuBGDesat'));
			magenta.scrollFactor.copyFrom(bg.scrollFactor);
			magenta.scale.copyFrom(bg.scale);
			magenta.updateHitbox();
			magenta.screenCenter();
			magenta.visible = false;
			magenta.color = 0xFFfd719b;
			add(magenta);

			add(camFollow = new FlxObject(0,0,1,1));
			FlxG.camera.follow(camFollow, LOCKON, 0.06);

			list = new MainMenuList();
			add(list);

			// Add menu options here!
			list.addButton('story mode', function() {
				startExitState(new StoryMenuState());
			});
			list.addButton('freeplay', function() {
				startExitState(new FreeplayState());
			});
			list.addButton('credits', function() {
				startExitState(new PlaceholderState("No credits yet! Fuck you!"));
			});
			list.addButton('options', function() {
				startExitState(new funkin.options.OptionsMenu());
			});
			//

			list.centerList();
			list.onPreSelect.add(function() {
				var button:MainMenuButton = list.members[list.curSelected];
				button.playAnim("idle");
			});
			list.onSelect.add(function() {
				var button:MainMenuButton = list.members[list.curSelected];
				button.playAnim("select");
				camFollow.y = button.y;

				DiscordRPC.changePresence(
					"In the Main Menu",
					"Selecting "+CoolUtil.firstLetterUppercase(button.name)
				);
			});
			list.onAccept.add(function() {
				var button:MainMenuButton = list.members[list.curSelected];
				if(button.flickerBG && prefs.get("Flashing Lights")) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
				FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/confirmMenu")));
			});
			list.changeSelection();

			var versionStr:String = 'Plasma Engine v${Main.engineVersion} (Funkin\' v0.2.7.1)';
			var modJSON:PackData = Json.parse(Assets.load(TEXT, Paths.json('pack')));
			versionStr += '\nSelected Mod: ${modJSON.title} (Press TAB to switch)';
			
			var versionText:FlxText = new FlxText(5, 0, 0, versionStr, 12);
			versionText.scrollFactor.set();
			versionText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			versionText.y = FlxG.height - (versionText.height + 5);
			add(versionText);
		}

		script.createPostCall();
	}

	override function update(elapsed:Float) {
        script.updateCall(elapsed);
        super.update(elapsed);

		if(runDefaultCode) {
			if(controls.getP("BACK"))
				FlxG.switchState(new TitleState());

			if(FlxG.keys.justPressed.SEVEN)
				FlxG.switchState(new ToolboxModSelect());
		}

        script.updatePostCall(elapsed);
	}

	function beatHit(beat:Int) {
		for(func in ["onBeatHit", "beatHit"]) {
			script.call(func, [beat]);
			script.call(func+"Post", [beat]);
		}
	}

	function stepHit(step:Int) {
		for(func in ["onStepHit", "stepHit"]) {
			script.call(func, [step]);
			script.call(func+"Post", [step]);
		}
	}

	function startExitState(nextState:FlxState) {
		list.enabled = false;
		list.forEach(function(item:MainMenuButton) {
			if (list.curSelected != item.ID)
				FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
			else
				item.visible = false;
		});
		new FlxTimer().start(0.4, function(tmr:FlxTimer) {
			FlxG.switchState(nextState);
		});
	}

	override public function destroy() {
		script.call("onDestroy");
		script.call("destroy");
		script.destroy();
		super.destroy();
	}
}
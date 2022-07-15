package funkin.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.game.FunkinState;
import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import funkin.systems.UIControls;

class MainMenu extends FunkinState
{
    var menuBG:FlxSprite;
    var menuBGMagenta:FlxSprite;

	var menuButtons:FlxTypedGroup<FlxSprite>;

	static var curSelected:Int = 0;

	// add new shit here!
	// add images for new buttons in assets/images/ui/mainMenu
	// make sure they are the same name as in the array.
	var menuOptions:Array<String> = [
		"story-mode",
		"freeplay",
		#if MODS_ALLOWED "mods", #end
		"credits",
		"options"
	];
    
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var scrollMenu:Dynamic;
	var confirmMenu:Dynamic;
	var cancelMenu:Dynamic;

    override public function create()
    {
        super.create();
        
		if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			FlxG.sound.playMusic(FunkinAssets.getSound(Paths.music('freakyMenu')));

		persistentUpdate = true;
		persistentDraw = true;

		scrollMenu = FunkinAssets.getSound(Paths.sound('menus/scrollMenu'));
		confirmMenu = FunkinAssets.getSound(Paths.sound('menus/confirmMenu'));
		cancelMenu = FunkinAssets.getSound(Paths.sound('menus/cancelMenu'));

		menuBG = new FlxSprite().loadGraphic(FunkinAssets.getImage(Paths.image('menus/menuBG')));
		menuBG.scale.set(1.2, 1.2);
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.scrollFactor.set(0, 0.1);
		menuBG.antialiasing = Preferences.getOption("antiAliasing");
		add(menuBG);

		menuBGMagenta = new FlxSprite().loadGraphic(FunkinAssets.getImage(Paths.image('menus/menuBGDesat')));
		menuBGMagenta.scale.set(menuBG.scale.x, menuBG.scale.y);
		menuBGMagenta.updateHitbox();
		menuBGMagenta.screenCenter();
		menuBGMagenta.scrollFactor.set(menuBG.scrollFactor.x, menuBG.scrollFactor.y);
		menuBGMagenta.visible = false;
		menuBGMagenta.antialiasing = Preferences.getOption("antiAliasing");
		menuBGMagenta.color = 0xFFfd719b;
		add(menuBGMagenta);

		menuButtons = new FlxTypedGroup<FlxSprite>();
		add(menuButtons);

		for (i in 0...menuOptions.length)
		{
			var offset:Float = 78 - (Math.max(menuOptions.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 160) + offset);
			menuItem.frames = FunkinAssets.getSparrow('ui/mainMenu/${menuOptions[i]}');
			menuItem.animation.addByPrefix('idle', "basic", 24);
			menuItem.animation.addByPrefix('selected', "white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			var scr:Float = (menuOptions.length - 4) * 0.3;
			if (menuOptions.length < 5)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = Preferences.getOption("antiAliasing");
			menuItem.updateHitbox();
			menuButtons.add(menuItem);
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(5, 0, 0, "", 16);
		versionShit.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		versionShit.scrollFactor.set();

		versionShit.text = "Genesis Engine v" + lime.app.Application.current.meta.get("version");

		versionShit.y = FlxG.height - (versionShit.height + 5);
		add(versionShit);

        changeSelection();
    }

    var selected:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 1)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		var lerpVal:Float = delta * 7.5;
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selected)
		{
			#if debug
			if (FlxG.keys.justPressed.C)
				switchState(new CharacterEditor());
			#end
			
			if (UIControls.justPressed("BACK"))
			{
				FlxG.sound.play(cancelMenu);
				switchState(new TitleState());
			}

			if (UIControls.justPressed("UP"))
				changeSelection(-1);

			if (UIControls.justPressed("DOWN"))
				changeSelection(1);

			if (UIControls.justPressed("ACCEPT"))
			{
				FlxG.sound.play(confirmMenu);

				FlxFlicker.flicker(menuBGMagenta, 1.1, 0.15, false);

				selected = true;

				menuButtons.forEachAlive(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							new FlxTimer().start(0.15, function(tmr:FlxTimer)
							{
								var daChoice:String = menuOptions[curSelected];

								switch (daChoice)
								{
									case 'story-mode':
                                    //  switchState(new funkin.menus.StoryMenu());
										switchState(new funkin.game.PlayState());
									case 'freeplay':
										switchState(new funkin.menus.FreeplayMenu());
									#if MODS_ALLOWED
									case 'mods':
                                    //  switchState(new funkin.menus.ModsMenu());
										switchState(new funkin.game.PlayState());
									#end
									case 'credits':
                                    //  switchState(new funkin.menus.CreditsMenu());
										switchState(new funkin.game.PlayState());
									case 'options':
									//	switchState(new funkin.menus.OptionsMenu());
                                        switchState(new funkin.game.PlayState());
								}
							});
						});
					}
				});
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected >= menuButtons.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuButtons.length - 1;

		FlxG.sound.play(scrollMenu);

		menuButtons.forEachAlive(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if (menuButtons.length > 4)
				{
					add = menuButtons.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
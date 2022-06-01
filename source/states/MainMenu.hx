package states;

import base.Controls;
import base.MusicBeat.MusicBeatState;
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
import lime.app.Application;

class MainMenu extends MusicBeatState
{
    var menuBG:FlxSprite;
    var magenta:FlxSprite;
    
    var menuButtons:FlxTypedGroup<FlxSprite>;

    static var curSelected:Int = 0;

    // add new shit here!
    // add images for new buttons in assets/images/mainMenu
    // make sure they are the same name as in the array.
    var menuOptions:Array<String> = [
        "story-mode",
        "freeplay",
        #if MODS_ALLOWED "mods" #end,
        //"replays",
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

        persistentUpdate = true;
        persistentDraw = true;

        scrollMenu = GenesisAssets.getAsset('menus/scrollMenu', SOUND);
        confirmMenu = GenesisAssets.getAsset('menus/confirmMenu', SOUND);
        cancelMenu = GenesisAssets.getAsset('menus/cancelMenu', SOUND);
        
        menuBG = new FlxSprite().loadGraphic(GenesisAssets.getAsset('menuBG', IMAGE));
        menuBG.scale.set(1.2, 1.2);
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.scrollFactor.set(0, 0.1);
        menuBG.antialiasing = true;
        add(menuBG);

        magenta = new FlxSprite().loadGraphic(GenesisAssets.getAsset('menuBGDesat', IMAGE));
        magenta.scale.set(menuBG.scale.x, menuBG.scale.y);
        magenta.updateHitbox();
        magenta.screenCenter();
        magenta.scrollFactor.set(menuBG.scrollFactor.x, menuBG.scrollFactor.y);
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
        add(magenta);

        menuButtons = new FlxTypedGroup<FlxSprite>();
        add(menuButtons);

        for(i in 0...menuOptions.length)
        {
			var offset:Float = 108 - (Math.max(menuOptions.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 160)  + offset);
			menuItem.frames = GenesisAssets.getAsset('ui/mainMenu/${menuOptions[i]}', SPARROW);
			menuItem.animation.addByPrefix('idle', "basic", 24);
			menuItem.animation.addByPrefix('selected', "white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			var scr:Float = (menuOptions.length - 4) * 0.4;
			if(menuOptions.length < 5) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = true;
			menuItem.updateHitbox();
			menuButtons.add(menuItem);
        }

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

        FlxG.camera.follow(camFollowPos, null, 1);

        var versionShit:FlxText = new FlxText(5, 0, 0, "", 16);
        versionShit.setFormat(GenesisAssets.getAsset("vcr.ttf", FONT), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        versionShit.borderSize = 2;
        versionShit.scrollFactor.set();

        versionShit.text = "Genesis Engine v" + Application.current.meta.get("version");
        
        versionShit.y = FlxG.height - (versionShit.height + 5);
        add(versionShit);

        changeItem();
    }

    var selected:Bool = false;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.volume < 1)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		var lerpVal:Float = elapsed * 7.5;
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

        if(!selected)
        {
            if(Controls.isPressed("BACK", JUST_PRESSED))
            {
                FlxG.sound.play(cancelMenu);
                States.switchState(this, new TitleState());
            }

            if(Controls.isPressed("UI_UP", JUST_PRESSED))
                changeItem(-1);

            if(Controls.isPressed("UI_DOWN", JUST_PRESSED))
                changeItem(1);

            if(Controls.isPressed("ACCEPT", JUST_PRESSED))
            {
                FlxG.sound.play(confirmMenu);
                
                FlxFlicker.flicker(magenta, 1.1, 0.15, false);

                menuButtons.forEach(function(spr:FlxSprite)
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
                                        States.switchState(this, new PlayState());
                                    case 'freeplay':
                                        States.switchState(this, new FreeplayMenu());
                                    #if MODS_ALLOWED
                                    case 'mods':
                                        States.switchState(this, new PlayState());
                                    #end
                                    case 'credits':
                                        States.switchState(this, new PlayState());
                                    case 'options':
                                        States.switchState(this, new PlayState());
                                }
                            });
                        });
                    }
                });
            }
        }
    }

	function changeItem(change:Int = 0)
	{
		curSelected += change;

		if (curSelected >= menuButtons.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuButtons.length - 1;

        FlxG.sound.play(scrollMenu);

		menuButtons.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuButtons.length > 4) {
					add = menuButtons.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
package funkin.states;

import funkin.mainMenu.MainMenuItem;
import funkin.mainMenu.MainMenuList;
import flixel.effects.FlxFlicker;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.media.Sound;
import flixel.text.FlxText;

using StringTools;

class MainMenu extends FunkinState {
    var bg:Sprite;
    var magenta:Sprite;

    var menuButtons:MainMenuList;
    public static var curSelected:Int = 0;

    var cachedSounds:Map<String, Sound> = [
        "scroll"  => Assets.load(SOUND, Paths.sound("menus/scrollMenu")),
        "confirm" => Assets.load(SOUND, Paths.sound("menus/confirmMenu")),
        "cancel"  => Assets.load(SOUND, Paths.sound("menus/cancelMenu")),
    ];

    override function create() {
        super.create();

        if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
            FlxG.sound.playMusic(Assets.load(SOUND, Paths.music("menus/titleScreen")));

        persistentUpdate = true;
        persistentDraw = true;

        bg = new Sprite().load(IMAGE, Paths.image("menus/menuBG"));
        bg.scale.set(1.1, 1.1);
        bg.updateHitbox();
        bg.screenCenter();
        bg.scrollFactor.set(0, 0.125);
        add(bg);

        magenta = new Sprite().load(IMAGE, Paths.image("menus/menuBGDesat"));
        magenta.scale.set(bg.scale.x, bg.scale.y);
        magenta.updateHitbox();
        magenta.screenCenter();
        magenta.scrollFactor.set(bg.scrollFactor.x, bg.scrollFactor.y);
        magenta.color = 0xFFFD719B;
        magenta.visible = false;
        add(magenta);

        menuButtons = new MainMenuList();
        add(menuButtons);

        menuButtons.addItem("story mode", function() {
            Console.debug("going to story mode menu");
            startExitState(new TitleScreen());
        });
        menuButtons.addItem("freeplay", function() {
            Console.debug("going to freeplay");
            startExitState(new FreeplayMenu());
        });
        menuButtons.addItem("options", function() {
            Console.debug("going to options");
            startExitState(new TitleScreen());
        });

        var devwarningformat = new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED,  true), "<red>");
        var warnStringShit:String = Main.engineVersion.endsWith("-dev") ? '<red>[UNSTABLE]<red>' : '';
        var watermark:FlxText = new FlxText(5,0,0,'Plasma Engine v${Main.engineVersion} $warnStringShit');
        watermark.applyMarkup(watermark.text, [devwarningformat]);
        watermark.setFormat(Paths.font("vcr.ttf"), 17, LEFT, OUTLINE, FlxColor.BLACK);
        watermark.y = FlxG.height - (watermark.height + 5);
        watermark.scrollFactor.set();
        add(watermark);

        changeSelection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Controls.getP("ui_up"))
            changeSelection(-1);

        if(Controls.getP("ui_down"))
            changeSelection(1);

        if(Controls.getP("back")) {
            FlxG.sound.play(cachedSounds["cancel"]);
            Main.switchState(new TitleScreen());
        }
    }

    function startExitState(nextState:FlxState) {
        FlxG.sound.play(cachedSounds["confirm"]);
        FlxFlicker.flicker(magenta, 1.1, 0.15, false, true);
        menuButtons.enabled = false;
		menuButtons.forEach(function(item:MainMenuItem) {
			if (curSelected != item.ID)
				FlxTween.tween(item, { alpha: 0 }, 0.4, { ease: FlxEase.quadOut });
			else {
				item.visible = false;
                FlxFlicker.flicker(item, 1, 0.06, false, false);
            }
		});
		new FlxTimer().start(1.1, function(tmr:FlxTimer) {
			Main.switchState(nextState);
		});
	}

    function changeSelection(change:Int = 0) {
        curSelected += change;
        if(curSelected < 0)
            curSelected = menuButtons.length-1;
        if(curSelected > menuButtons.length-1)
            curSelected = 0;

        menuButtons.forEach(function(button:Sprite) {
            button.playAnim(curSelected == button.ID ? "selected" : "idle");
            button.updateHitbox();
            button.screenCenter(X);
        });

        FlxG.camera.follow(menuButtons.members[curSelected], null, 0.06);
        FlxG.sound.play(cachedSounds["scroll"]);
    }
}
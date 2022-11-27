package funkin.substates;

import funkin.system.DebugCode;
import flixel.text.FlxText;
import flixel.FlxSprite;

class ErrorSubState extends FNFSubState {
    var oldPersistUpdate:Bool = FlxG.state.persistentUpdate;
    var oldPersistDraw:Bool = FlxG.state.persistentDraw;

    public function new(debugCode:DebugCode, title:String, description:String) {
        super();
        FlxG.state.persistentUpdate = false;
        FlxG.state.persistentDraw = true;

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

        var box = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image("ui/modCardBG")));
        box.scale.set(0.7, 0.7);
        box.updateHitbox();
        box.screenCenter();
        box.antialiasing = PlayerSettings.prefs.get("Antialiasing");
        add(box);

        var icon = new FlxSprite(box.x + 10, box.y + 10).loadGraphic(Assets.load(IMAGE, Paths.image("ui/statusIcons")), true, 16, 16);
        icon.scale.set(6, 6);
        icon.updateHitbox();
        icon.animation.add("frames", [1, 0, 2, 3], 0, false);
        icon.animation.play("frames");
        icon.animation.frameIndex = debugCode;
        add(icon);

        var text = new FlxText(icon.x + (icon.width + 10), icon.y, 0, title+"\n  ", 48);
        text.setFormat(Paths.font("funkin.ttf"), 48);
        text.y += text.height / 4;
        text.antialiasing = PlayerSettings.prefs.get("Antialiasing");
        add(text);

        var text = new FlxText(icon.x, icon.y + (icon.height + 10), box.width - 10, description+"\n  ", 24);
        text.setFormat(Paths.font("funkin.ttf"), 24);
        text.antialiasing = PlayerSettings.prefs.get("Antialiasing");
        add(text);
    }

    override function update(elapsed:Float) {
		super.update(elapsed);

		if(controls.getP("BACK")) {
			FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
			close();
		}
	}

    override public function close() {
        FlxG.state.persistentUpdate = oldPersistUpdate;
        FlxG.state.persistentDraw = oldPersistDraw;
        super.close();
    }
}
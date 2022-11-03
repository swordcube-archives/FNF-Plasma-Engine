package funkin.states.options;

import funkin.states.substates.FunkinSubState;

class BaseOptionsPage extends FunkinSubState {
    override function create() {
        super.create();
        var bg = new Sprite().load(IMAGE, Paths.image("menus/menuBGDesat"));
        bg.color = 0xFFEA71FD;
        bg.setGraphicSize(Std.int(bg.width * 1.1));
        bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(Controls.getP("back")) {
            FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
            Settings.flush();
            close();
        }
    }
}
package scenes.options;

class ControlsMenu extends Subscene {
    var bg:Sprite = new Sprite();
    var baseBGColor:FlxColor = 0xFFEA71FD;

    override function start() {
        bg.load(IMAGE, Paths.image("menuBGDesat"));
        bg.color = baseBGColor;
        add(bg);
    }

    override function process(delta:Float) {
        if(Controls.BACK_P)
            close();
    }
}

package scenes.options;

class NoteColorsMenu extends Subscene {
    override function start() {
        var bg:Sprite = new Sprite().load(IMAGE, Paths.image("menuBGDesat"));
        bg.color = 0xFFEA71FD;
        add(bg);
    }

    override function process(delta:Float) {
        if(Controls.BACK_P)
            close();
    }
}
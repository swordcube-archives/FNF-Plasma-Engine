package funkin.states;

class MainMenu extends FunkinState {
    var bg:Sprite;

    override function create() {
        super.create();

        bg = new Sprite().load(IMAGE, Paths.image("menus/menuBG"));
        add(bg);
    }
}
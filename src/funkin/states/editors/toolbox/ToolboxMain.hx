package funkin.states.editors.toolbox;

import funkin.states.menus.MainMenuState;
import funkin.system.FNFSprite;

class ToolboxMain extends FNFState {
    override function create() {
        super.create();

        add(new FNFSprite().load(IMAGE, Paths.image("menus/menuBGNeo")));
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(controls.getP("BACK"))
            FlxG.switchState(new MainMenuState());
    }
}
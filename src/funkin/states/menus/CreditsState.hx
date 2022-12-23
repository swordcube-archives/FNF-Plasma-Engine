package funkin.states.menus;

import funkin.system.FNFSprite;

class CreditsState extends FNFState {
    override function create() {
        super.create();

        enableTransitions();

        var bg = new FNFSprite().load(IMAGE, Paths.image("menus/menuBGDesat"));
        bg.scrollFactor.set();
        add(bg);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(controls.getP("BACK")) {
            CoolUtil.playMenuSFX(2);
            FlxG.switchState(new funkin.states.menus.MainMenuState());
        }
    }
}
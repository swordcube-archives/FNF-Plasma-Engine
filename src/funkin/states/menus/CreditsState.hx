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
            FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
            FlxG.switchState(new funkin.states.menus.MainMenuState());
        }
    }
}
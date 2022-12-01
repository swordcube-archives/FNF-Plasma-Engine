package funkin.states.editors;

import funkin.states.menus.MainMenuState;
import flixel.util.FlxSignal.FlxTypedSignal;

class Editor extends FNFState {
    public var onBack:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();
    public var onAccept:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();

    override function create() {
        super.create();

        enableTransitions();

        onBack.add(function() {
            FlxG.switchState(new MainMenuState());
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(controls.getP("BACK"))
            onBack.dispatch();

        if(controls.getP("ACCEPT"))
            onAccept.dispatch();
    }
}
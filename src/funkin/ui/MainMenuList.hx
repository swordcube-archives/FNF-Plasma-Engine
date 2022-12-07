package funkin.ui;

import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;

@:dox(hide)
class MainMenuList extends FlxTypedGroup<MainMenuButton> {
    public var enabled:Bool = true;
    public var curSelected:Int = 0;
    public var onSelect:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();
    public var onPreSelect:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();
    public var onAccept:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();

    public function addButton(name:String, acceptCallback:Void->Void, ?flickerBG:Bool = true) {
        var button = new MainMenuButton(0, 0, name);
        button.onAccept.add(acceptCallback);
        button.ID = length;
        button.scrollFactor.set();
        button.flickerBG = flickerBG;
        add(button);
    }

    public function centerList() {
        var pos:Float = (FlxG.height - 160 * (length - 1)) / 2;
		for (i in 0...members.length) {
			var item:MainMenuButton = members[i];
			item.x = FlxG.width / 2;
			item.y = pos + (160 * i);
		}
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(!enabled) return;

        var prefs = PlayerSettings.prefs;
        var controls = PlayerSettings.controls;

        if(controls.getP("UI_UP")) changeSelection(-1);
        if(controls.getP("UI_DOWN")) changeSelection(1);
        if(controls.getP("ACCEPT")) {
            enabled = false;
            onAccept.dispatch();
            var button:MainMenuButton = members[curSelected];
            if(prefs.get("Flashing Lights")) {
                FlxFlicker.flicker(button, 1, 0.06, false, false, function(flick) {
                    button.onAccept.dispatch();
                });
            } else {
                new FlxTimer().start(1, function(tmr:FlxTimer) {
                    button.onAccept.dispatch();
                });
            }         
        }
    }

    public function changeSelection(change:Int = 0) {
        onPreSelect.dispatch();
        curSelected = FlxMath.wrap(curSelected + change, 0, length - 1);
        onSelect.dispatch();

        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/scrollMenu"))); 
    }
}
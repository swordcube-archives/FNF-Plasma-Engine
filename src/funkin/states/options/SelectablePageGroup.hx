package funkin.states.options;

import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;

class SelectablePageGroup extends FlxTypedGroup<SelectablePage> {
    public var enabled:Bool = true;

    public function addPage(name:String, callback:Void->Void) {
        var page = new SelectablePage(0, 100 + 100 * length, name);
        page.onAccept.add(function(name:String) {
            if(!enabled) return;
            enabled = false;
            Console.debug("SWITCHING TO PAGE: "+name);
            FlxFlicker.flicker(page, 1.1, 0.06, true, false, function(f:FlxFlicker) {
                callback();
                enabled = true;
            });
            FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/confirmMenu")));
        });
        page.screenCenter(X);
        add(page);
    }

    public function switchPage(c:Int = 0) {
        members[c].onAccept.dispatch(members[c].text);
    }
}
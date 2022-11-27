package funkin.options;

import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;

class CategoryGroup extends FlxTypedGroup<CategoryText> {
    public var disabled:Bool = false;
    public var curSelected:Int = 0;

    public function addCategory(name:String, acceptCallback:Void->Void) {
        var text = new CategoryText(0, 0, Bold, name);
        text.screenCenter();
        text.y += 90 * length;
        text.onAccept.add(acceptCallback);
        add(text);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(disabled) return;
        var prefs = PlayerSettings.prefs;
        var controls = PlayerSettings.controls;
        if(controls.getP("UI_UP")) changeSelection(-1);
        if(controls.getP("UI_DOWN")) changeSelection(1);
        if(controls.getP("ACCEPT")) {
            disabled = true;
            FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/confirmMenu")));
            var text:CategoryText = members[curSelected];
            if(prefs.get("Flashing Lights")) {
                FlxFlicker.flicker(text, 1, 0.06, true, false, function(f) {
                    text.onAccept.dispatch();
                    disabled = false;
                });
            } else {
                new FlxTimer().start(1, function(f) {
                    text.onAccept.dispatch();
                    disabled = false;
                });
            }
        }
    }

    public function changeSelection(change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, length - 1);
        for(i in 0...length) {
            members[i].alpha = curSelected == i ? 1 : 0.6;
        }
        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/scrollMenu")));
    }
}
package funkin.options;

import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.ui.Alphabet;

class CategoryText extends Alphabet {
    public var onAccept:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();
}
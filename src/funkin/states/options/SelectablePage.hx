package funkin.states.options;

import flixel.util.FlxSignal.FlxTypedSignal;

class SelectablePage extends Alphabet {
    public var onAccept:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();
    
    public function new(x:Float, y:Float, name:String) {
        super(x, y, Bold, name);
    }
}
package funkin.options.types;

class GameplayControl extends BaseOption {
    public var keyIndex:Int;

    public function new(name:String, parentOption:String, keyIndex:Int) {
        super(name, "", parentOption);
        this.keyIndex = keyIndex;
    }
}
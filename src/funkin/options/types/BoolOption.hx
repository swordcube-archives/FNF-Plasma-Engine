package funkin.options.types;

class BoolOption extends BaseOption {
    public var updateCallback:(Bool)->Void;

    public function new(title:String, description:String, saveData:String, ?updateCallback:(Bool)->Void) {
        super(title, description, saveData);
        this.updateCallback = updateCallback;
    }
}
package funkin.options.types;

class ListOption extends BaseOption {
    public var values:Array<Dynamic>;
    public var updateCallback:(Dynamic)->Void;

    public function new(title:String, description:String, saveData:String, values:Array<Dynamic>, ?updateCallback:(Dynamic)->Void) {
        super(title, description, saveData);

        this.values = values;
        this.updateCallback = updateCallback;
    }
}
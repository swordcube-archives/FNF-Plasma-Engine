package funkin.options.types;

class BaseOption {
    public var title:String;
    public var description:String;
    public var saveData:Null<String>;

    public function new(title:String, description:String, saveData:Null<String>) {
        this.title = title;
        this.description = description;
        this.saveData = saveData;
    }
}
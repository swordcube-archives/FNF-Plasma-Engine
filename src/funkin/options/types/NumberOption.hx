package funkin.options.types;

class NumberOption extends BaseOption {
    public var increment:Float;
    public var decimals:Int;
    public var limits:Array<Float>;
    public var updateCallback:(Float)->Void;

    public function new(title:String, description:String, saveData:String, increment:Float, decimals:Int, limits:Array<Float>, ?updateCallback:(Float)->Void) {
        super(title, description, saveData);
        
        this.increment = increment;
        this.decimals = decimals;
        this.limits = limits;
        this.updateCallback = updateCallback;
    }
}
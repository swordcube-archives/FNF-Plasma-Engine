package funkin.states.options;

class Option {
    public var type:SettingType = Checkbox;
    public var name:String = "";
    public var desc:String = "";
    public var locked:Bool = false;
    public var values:Array<Dynamic> = [];
    public var limits:Array<Float> = [];
    public var decimals:Null<Int> = 1;
    public var increment:Float = 1.0;

    public function new(type:SettingType, name:String, desc:String, ?values:Array<Dynamic>, ?limits:Array<Float>, ?decimals:Null<Int> = 1, ?increment:Null<Float> = 1.0) {
        this.type = type;
        this.name = name;
        this.desc = desc;
        this.values = values;
        this.limits = limits;
        this.decimals = decimals;
        this.increment = increment;
    }
}
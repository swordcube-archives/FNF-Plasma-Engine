package funkin.options.types;

/**
 * The option type for a number.
 */
class NumberOption extends BaseOption {
    public var increment:Float;
    public var decimals:Int;
    public var limits:Array<Float>;
    public var updateCallback:(Float)->Void;

    /**
     * Initializes this option.
     * @param title The title of this option.
     * @param description The description for this option.
     * @param saveData The save data name that this option uses.
     * @param increment The amount that the number increments by in Options.
     * @param decimals The amount of decimals this number should have.
     * @param limits The minimum and maximum values that this number has.
     * @param updateCallback The callback that gets executed when this option is modified in Options.
     */
    public function new(title:String, description:String, saveData:String, increment:Float, decimals:Int, limits:Array<Float>, ?updateCallback:(Float)->Void) {
        super(title, description, saveData);
        
        this.increment = increment;
        this.decimals = decimals;
        this.limits = limits;
        this.updateCallback = updateCallback;
    }
}
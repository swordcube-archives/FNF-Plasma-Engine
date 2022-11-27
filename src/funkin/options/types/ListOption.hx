package funkin.options.types;

/**
 * The option type for a list of values.
 */
class ListOption extends BaseOption {
    public var values:Array<Dynamic>;
    public var updateCallback:(Dynamic)->Void;

    /**
     * Initializes this option.
     * @param title The title of this option.
     * @param description The description for this option.
     * @param saveData The save data name that this option uses.
     * @param values The values that this list has.
     * @param updateCallback The callback that gets executed when this option is modified in Options.
     */
    public function new(title:String, description:String, saveData:String, values:Array<Dynamic>, ?updateCallback:(Dynamic)->Void) {
        super(title, description, saveData);

        this.values = values;
        this.updateCallback = updateCallback;
    }
}
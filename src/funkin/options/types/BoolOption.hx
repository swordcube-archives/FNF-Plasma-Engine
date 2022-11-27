package funkin.options.types;

/**
 * The option type for a boolean.
 */
class BoolOption extends BaseOption {
    public var updateCallback:(Bool)->Void;

    /**
     * Initializes this option.
     * @param title The title of this option.
     * @param description The description for this option.
     * @param saveData The save data name that this option uses.
     * @param updateCallback The callback that gets executed when this option is modified in Options.
     */
    public function new(title:String, description:String, saveData:String, ?updateCallback:(Bool)->Void) {
        super(title, description, saveData);
        this.updateCallback = updateCallback;
    }
}
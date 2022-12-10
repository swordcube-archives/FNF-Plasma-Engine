package funkin.options.types;

import flixel.FlxSubState;

/**
 * The option type for going to menus.
 */
class MenuOption extends BaseOption {
    public var menu:Class<FlxSubState>;
    public var args:Array<Dynamic> = [];

    public function new(title:String, description:String, menu:Class<FlxSubState>, ?args:Array<Dynamic>) {
        super(title, description, null);
        if(args == null) args = [];
        this.menu = menu;
        this.args = args;
    }
}
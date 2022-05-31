package;

@:enum abstract OptionType(String) to String
{
	var BOOL = "bool";
	var ARRAY = "array";
	var NUMBER = "number";
	var MENU = "menu";
}

class Option
{
	public var type:OptionType = BOOL; // Specifies if how the option is treated in the Options Menu.
	public var title:String = ""; // Specifies what the option shows up in the Options menu as.
	public var desc:String = ""; // A description for the option, used for the Options menu.
	public var defaultValue:Dynamic; // Specifies what the default value for the option is.
	public var minimum:Float = 0; // Specifies what the minimum value is for the NUMBER type.
	public var maximum:Float = 0; // Specifies what the maximum value is for the NUMBER type.
	public var values:Array<Dynamic> = []; // Specifies what values you can choose from for the ARRAY type.

	public function new(type:OptionType, title:String, desc:String, defaultValue:Dynamic, ?minimum:Null<Float>, ?maximum:Null<Float>, ?values:Array<Dynamic>)
	{
		this.type = type;
		this.title = title;
		this.desc = desc;
		this.defaultValue = defaultValue;
		this.minimum = minimum;
		this.maximum = maximum;
		this.values = values;
	}
}

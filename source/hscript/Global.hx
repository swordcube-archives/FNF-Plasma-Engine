package hscript;

class Global
{
    public static var variables:Map<String, Dynamic> = [];

    public static function reset()
        variables.clear();

    public static function set(variable:String, value:Dynamic)
        variables.set(variable, value);

    public static function get(variable:String)
        return variables.get(variable);

    public static function runFunction(func:String, args:Null<Array<Dynamic>> = null)
    {
		if (variables.exists(func))
		{
			var realFunc = variables.get(func);

			try
			{
				if (args == null)
					realFunc();
				else
					Reflect.callMethod(null, realFunc, args);
			}
			catch (e)
			{
				trace(e.details(), true);
			}
		}
    }
}
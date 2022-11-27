package funkin.system;

/**
 * A typedef for a Mod's config JSON.
 */
typedef PackData = {
    var title:String;
    var description:String;
    var engineVersion:String;
    var allowUnsafeScripts:Bool;
    var editable:Bool;
}

class ModData {
    public static var allowUnsafeScripts:Bool = false;
}
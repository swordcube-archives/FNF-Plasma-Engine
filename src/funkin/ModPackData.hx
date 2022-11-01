package funkin;

/**
 * A typedef for a Mod's config JSON.
 */
typedef ModPackData = {
    var name:String;
    var desc:String;
    var engineVersion:String;
    var allowUnsafeScripts:Bool;
    var editable:Bool;
}

class GlobalModShit {
    public static var allowUnsafeScripts:Bool = false;
}
package;

import sys.FileSystem;
import sys.io.File;

using StringTools;

class CoolUtil
{
    public static function range(max:Int, ?min = 0):Array<Int> {
        var a:Array<Int> = [];
        for(i in min...max) a.push(i);
        return a;
    }

	public static function listFromText(text:String):Array<String> {
        var a:Array<String> = text.trim().split('\n');
        for(i in 0...a.length) a[i] = a[i].trim();
		return a;
    }
}
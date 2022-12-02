package funkin.macros;

// haha i got this working fuck you
// but it updates when the haxe vs code haxe extension
// recompiles the game partially to update shit
// hlep
class BuildCounterMacro {
    public static macro function getBuildNumber() {
        #if (!display && debug)
        var buildNum:Int = Std.parseInt(File.getContent('./buildNumber.txt'));
        File.saveContent('./buildNumber.txt', Std.string(buildNum+1));
        return macro $v{buildNum+1};
        #else
        return macro $v{0};
        #end
    }
}
package funkin.macros;

// haha i got this working fuck you
// but it updates when the haxe vs code haxe extension
// recompiles the game partially to update shit
// hlep
class BuildCounterMacro {
    public static macro function getBuildNumber() {
        // Doesn't work on release because we don't show the number there
        // And also i don't want to get release counts mixed with debug counts
        #if (!display && debug)
        var buildNum:Int = Std.parseInt(File.getContent('./buildNumber.txt'));
        File.saveContent('./buildNumber.txt', Std.string(buildNum+1));
        return macro $v{buildNum+1};
        #else
        return macro $v{0};
        #end
    }
}
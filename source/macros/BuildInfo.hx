package macros;

class BuildInfo {
    public static function getBuildNumber():String {
        var oldNumber:String = File.getContent('${Sys.getCwd()}info/buildNumber.txt');
        var curNumber:String = Std.string(Std.parseInt(oldNumber)+1);
        File.saveContent('${Sys.getCwd()}info/buildNumber.txt', curNumber);
        return curNumber;
    }
}
package gameplay;

typedef PsychEvent = {
    var name:String;
    var time:Float;
    var value1:String;
    var value2:String;
};

typedef FunkinEvent = {
    var scriptToUse:String;
    var time:Float;
    var parameters:Array<String>;
};
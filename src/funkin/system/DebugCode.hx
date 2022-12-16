package funkin.system;

@:dox(hide)
enum abstract DebugCode(Int) from Int to Int {
    var SUCCESS = 0;
    var ERROR = 1;
    var INFO = 2;
    var WARN = 3;
}
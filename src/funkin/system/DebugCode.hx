package funkin.system;

@:dox(hide)
enum abstract DebugCode(Int) from Int to Int {
    var ERROR = 0;
    var SUCCESS = 1;
    var INFO = 2;
    var WARN = 3;
}
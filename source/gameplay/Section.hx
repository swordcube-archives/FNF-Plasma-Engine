package gameplay;

/**
    Typedef for Section Data.
**/
typedef Section = {
    // The notes for this section.
    var sectionNotes:Array<Dynamic>;
    // Stuff for charting.
    var lengthInSteps:Int;
    var mustHitSection:Bool;
    // Determines if the opponent/player should use alt anims for this section.
    var altAnim:Bool;
    // BPM Stuff
    var bpm:Null<Float>;
    var changeBPM:Null<Bool>;
}
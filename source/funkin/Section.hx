package funkin;

typedef Section = {
    var sectionNotes:Array<Dynamic>; // The notes for this section.
    var mustHitSection:Bool; // Determines if this section focuses on the player.
    var altAnim:Bool; // Determines if the opponent/player should use alt anims for this section.
    var bpm:Null<Float>; // The BPM for this section (Used when changeBPM is on)
    var changeBPM:Null<Bool>; // Determines if the section changes the BPM.
	var timeScale:Array<Int>; // The timescale for this section. (Used when changeTimeScale is on)
	var changeTimeScale:Bool; // Determines if the section changes the time scale.
    var lengthInSteps:Int;
}
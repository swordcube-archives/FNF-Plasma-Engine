package funkin.system;

typedef SectionNote = {
	var strumTime:Float;
	var direction:Int;
	var sustainLength:Float;
	var type:String;
	var altAnim:Bool;
}

typedef Section = {
	var notes:Array<SectionNote>;
	var lengthInSteps:Int;
	var playerSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

// Base Game
typedef LegacySection = {
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

// Psych
typedef PsychSection = {
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}
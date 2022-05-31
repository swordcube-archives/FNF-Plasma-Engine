package base;

typedef Song =
{
	var song:String;
	var notes:Array<Section>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;

	var stage:String;

	// the gf that's actually used is "gf", gfVersion and player3 are here
	// because compatibility with other charts
	var gf:String; // the one that's used

	var gfVersion:String;
	var player3:String;
}
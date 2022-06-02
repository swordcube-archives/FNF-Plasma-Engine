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

	var stage:Null<String>;

	// the gf that's actually used is "gf", gfVersion and player3 are here
	// because compatibility with other charts
	var gf:Null<String>; // the one that's used

	var gfVersion:Null<String>;
	var player3:Null<String>;

	var keyCount:Null<Int>;
	var mania:Null<Int>;

	var uiSkin:Null<String>;
}

typedef RawSong = {
	var song:Song;
}
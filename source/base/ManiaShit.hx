package base;

class ManiaShit
{
	public static var letterDirections:Map<Int, Array<String>> = [
		1 => ["E"],
		2 => ["A", "D"],
		3 => ["A", "E", "D"],
		4 => ["A", "B", "C", "D"],
		5 => ["A", "B", "E", "C", "D"],
		6 => ["A", "B", "D", "A", "C", "D"],
		7 => ["A", "B", "D", "E", "A", "C", "D"],
		8 => ["A", "B", "C", "D", "F", "G", "H", "I"],
		9 => ["A", "B", "C", "D", "E", "F", "G", "H", "I"],
	];

	public static var singAnims:Map<Int, Array<String>> = [
		1 => ["singUP"],
		2 => ["singLEFT", "singRIGHT"],
		3 => ["singLEFT", "singUP", "singRIGHT"],
		4 => ["singLEFT", "singDOWN", "singUP", "singRIGHT"],
		5 => ["singLEFT", "singDOWN", "singUP", "singUP", "singRIGHT"],
		6 => ["singLEFT", "singDOWN", "singRIGHT", "singLEFT", "singUP", "singRIGHT"],
		7 => ["singLEFT", "singDOWN", "singRIGHT", "singUP", "singLEFT", "singUP", "singRIGHT"],
		8 => [
			"singLEFT",
			"singDOWN",
			"singUP",
			"singRIGHT",
			"singLEFT",
			"singDOWN",
			"singUP",
			"singRIGHT"
		],
		9 => [
			"singLEFT",
			"singDOWN",
			"singUP",
			"singRIGHT",
			"singUP",
			"singLEFT",
			"singDOWN",
			"singUP",
			"singRIGHT"
		],
	];
}

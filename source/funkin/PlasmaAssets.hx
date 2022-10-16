package funkin;

import flixel.graphics.FlxGraphic;

class PlasmaAssets {
   	public static function getRatingCache(ratingPath:String = "ratings/default"):Map<String, FlxGraphic> {
		return [
			"marvelous"  => Assets.get(IMAGE, Paths.image(ratingPath+"/marvelous")),
			"sick"       => Assets.get(IMAGE, Paths.image(ratingPath+"/sick")),
			"good"       => Assets.get(IMAGE, Paths.image(ratingPath+"/good")),
			"bad"        => Assets.get(IMAGE, Paths.image(ratingPath+"/bad")),
			"shit"       => Assets.get(IMAGE, Paths.image(ratingPath+"/shit")),
		];
	}

	public static function getComboCache(comboPath:String = "combo/default"):Map<String, Map<String, FlxGraphic>> {
		return [
			"marvelous"  => [
				"combo"  => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/combo")),
				"num0"   => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/num0")),
				"num1"   => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/num1")),
				"num2"   => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/num2")),
				"num3"   => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/num3")),
				"num4"   => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/num4")),
				"num5"   => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/num5")),
				"num6"   => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/num6")),
				"num7"   => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/num7")),
				"num8"   => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/num8")),
				"num9"   => Assets.get(IMAGE, Paths.image(comboPath+"/marvelous/num9")),
			],
			"default"    => [
				"combo"  => Assets.get(IMAGE, Paths.image(comboPath+"/combo")),
				"num0"   => Assets.get(IMAGE, Paths.image(comboPath+"/num0")),
				"num1"   => Assets.get(IMAGE, Paths.image(comboPath+"/num1")),
				"num2"   => Assets.get(IMAGE, Paths.image(comboPath+"/num2")),
				"num3"   => Assets.get(IMAGE, Paths.image(comboPath+"/num3")),
				"num4"   => Assets.get(IMAGE, Paths.image(comboPath+"/num4")),
				"num5"   => Assets.get(IMAGE, Paths.image(comboPath+"/num5")),
				"num6"   => Assets.get(IMAGE, Paths.image(comboPath+"/num6")),
				"num7"   => Assets.get(IMAGE, Paths.image(comboPath+"/num7")),
				"num8"   => Assets.get(IMAGE, Paths.image(comboPath+"/num8")),
				"num9"   => Assets.get(IMAGE, Paths.image(comboPath+"/num9")),
			],
		];
	} 
}
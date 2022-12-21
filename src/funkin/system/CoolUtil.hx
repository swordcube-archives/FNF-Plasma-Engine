package funkin.system;

import funkin.states.PlayState;
import funkin.system.ChartParser.ChartType;
import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimation;

using StringTools;

/**
 * A class full of cool utilities.
 */
class CoolUtil {
	public static function fixWorkingDirectory() {
		var curDir = Sys.getCwd();
		var execPath = Sys.programPath();
		var p = execPath.replace("\\", "/").split("/");
		var execName = p.pop(); // interesting
		Sys.setCwd(p.join("\\") + "\\");
	}

	/**
	 * Gets the last item in `array` and returns it.
	 * @param array The array to get the item from.
	 */
	public static function lastInArray(array:Array<Dynamic>):Dynamic {
		if(array.length < 1) return null;
		return array[array.length-1];
	}

	/**
	 * Converts bytes into a human-readable format `(Examples: 1b, 256kb, 1024mb, 2048gb, 4096tb)
	 * @param num The bytes to convert.
	 * @return String
	 */
	 public inline static function getSizeLabel(num:Int):String {
		var size:Float = Math.abs(num) != num ? Math.abs(num) + 2147483648 : num;
		var data = 0;
		var dataTexts = ["b", "kb", "mb", "gb", "tb", "pb"];

		while (size > 1024 && data < dataTexts.length - 1) {
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		return size + dataTexts[data].toUpperCase();
	}

	/**
		Splits `text` into an array of multiple strings.
		@param text    The string to split
		@author swordcube
	**/
	public inline static function listFromText(text:String):Array<String> {
		var daList:Array<String> = text.trim().split('\n');
		for (i in 0...daList.length) daList[i] = daList[i].trim();
		return daList;
	}

	/**
	 * Trims everything in an array of strings and returns it.
	 * @param a The array to modify.
	 * @return Array<String>
	 */
	 public inline static function trimArray(a:Array<String>):Array<String> {
		var f:Array<String> = [];
		for(i in a) f.push(i.trim());
		return f;
	}

	/**
	 * Opens a instance of your default browser and navigates to `url`.
	 * @param url The URL to open.
	 */
	public inline static function openURL(url:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	/**
	 * Splits `string` using `delimeter` and then converts all items in the array into an `Int` and returns it.
	 * @param string The string to split.
	 * @param delimeter The character to use for splitting.
	 * @return Array<Int>
	 * @author Leather128
	 */
	public inline static function splitInt(string:String, delimeter:String):Array<Int> {
		string = string.trim();
		var splitReturn:Array<Int> = [];
		if(string.length > 0) {
			var splitString:Array<String> = string.split(delimeter);
			for (string in splitString) splitReturn.push(Std.parseInt(string.trim()));
		}
		return splitReturn;
	}

	/**
	 * Instantly loads a week and goes into gameplay.
	 * @param name The name of the week to load.
	 * @param difficulty The difficulty to load.
	 */
	public inline static function loadWeek(name:String, ?difficulty:String = "normal") {
		var weekList = WeekUtil.getWeekListMap();

		// copy pasted bullshit from StoryMenuState
		PlayState.storyPlaylist = weekList[name].songs;
		PlayState.isStoryMode = true;
		PlayState.storyScore = 0;
		PlayState.weekName = weekList[name].name;
		var diffNum:Int = weekList[name].difficulties.indexOf(difficulty);
		if(diffNum < 0) diffNum = 0;
		PlayState.curDifficulty = weekList[name].difficulties[diffNum];
		Conductor.rate = 1.0;
		var initialSong = PlayState.storyPlaylist[0];
		PlayState.SONG = ChartParser.loadSong(initialSong.chartType, initialSong.name, PlayState.curDifficulty);
		FlxG.switchState(new PlayState());
	}

	public inline static function switchAnimFrames(anim1:FlxAnimation, anim2:FlxAnimation) {
		if (anim1 == null || anim2 == null) return;
		var old = anim1.frames;
		anim1.frames = anim2.frames;
		anim2.frames = old;
	}

	/**
		Makes the first letter of each word in `s` uppercase.
		@param s       The string to modify
		@author swordcube
	**/
	public inline static function firstLetterUppercase(s:String):String {
		var strArray:Array<String> = s.split(' ');
		var newArray:Array<String> = [];
		
		for (str in strArray)
			newArray.push(str.charAt(0).toUpperCase()+str.substring(1));
	
		return newArray.join(' ');
	}

	/**
	 * Loads into a song.
	 * @param chartType The chart's type, AUTO is recommended.
	 * @param name The name of the song to load.
	 * @param diff The difficulty to load.
	 */
	public static function loadSong(chartType:ChartType, name:String, diff:String) {
		if(!FileSystem.exists(Paths.json('songs/${name.toLowerCase()}/$diff')))
			return Console.error('The chart for $name on $diff difficulty doesn\'t exist!');
		
		Conductor.rate = PlayerSettings.prefs.get("Playback Rate");
		PlayState.isStoryMode = false;
		PlayState.SONG = ChartParser.loadSong(chartType, name, diff);
		PlayState.curDifficulty = diff;
		FlxG.switchState(new PlayState());
	}

	/**
	 * Converts an `FlxKey` to a string representation.
	 * @param key The key to convert.
	 * @return String
	 */
	public inline static function keyToString(key:Null<FlxKey>):String {
		return switch(key) {
			case null | 0 | NONE:	"---";
			case LEFT: 				"←";
			case DOWN: 				"↓";
			case UP: 				"↑";
			case RIGHT:				"→";
			case ESCAPE:			"ESC";
			case BACKSPACE:			"[←]";
			case SPACE:             "[_]";
			case NUMPADZERO:		"#0";
			case NUMPADONE:			"#1";
			case NUMPADTWO:			"#2";
			case NUMPADTHREE:		"#3";
			case NUMPADFOUR:		"#4";
			case NUMPADFIVE:		"#5";
			case NUMPADSIX:			"#6";
			case NUMPADSEVEN:		"#7";
			case NUMPADEIGHT:		"#8";
			case NUMPADNINE:		"#9";
			case NUMPADPLUS:		"#+";
			case NUMPADMINUS:		"#-";
			case NUMPADPERIOD:		"#.";
			case ZERO:				"0";
			case ONE:				"1";
			case TWO:				"2";
			case THREE:				"3";
			case FOUR:				"4";
			case FIVE:				"5";
			case SIX:				"6";
			case SEVEN:				"7";
			case EIGHT:				"8";
			case NINE:				"9";
			case PERIOD:			".";
			case SEMICOLON:         ";";
			default:				key.toString();
		}
	}

	/**
	 * A helper function for loading a UI skin in `PlayState`.
	 * @param generalSkin The skin used for the countdown, ratings, and combo.
	 * @param noteSkin The skin used for notes.
	 * @param countdownScale The scale of the countdown images.
	 * @param judgementScale The scale of the ratings and combo.
	 * @param countdownAntialiasing The antialiasing for the countdown images.
	 * @param ratingAntialiasing The antialiasing for the rating images.
	 * @param comboAntialiasing The antialiasing for the combo images.
	 */
	public inline static function loadUISkin(generalSkin:String, noteSkin:String, countdownScale:Array<Float>, judgementScale:Array<Float>, countdownAntialiasing:Bool = true, ratingAntialiasing:Bool = true, comboAntialiasing:Bool = true) {
		var game = PlayState.current;

		game.countdownSkin = generalSkin;
		game.ratingSkin = generalSkin;
		game.comboSkin = generalSkin;
		game.noteSkin = noteSkin;
	
		for(sprite in [game.countdownReady, game.countdownSet, game.countdownGo]) {
			sprite.scale.set(countdownScale[0], countdownScale[1]);
			sprite.antialiasing = countdownAntialiasing ? PlayerSettings.prefs.get("Antialiasing") : false;
			sprite.updateHitbox();
		}
		game.ratingScale = judgementScale[0];
		game.comboScale = judgementScale[1];
	
		game.ratingAntialiasing = ratingAntialiasing;
		game.comboAntialiasing = comboAntialiasing;
	
		for(line in [game.UI.opponentStrums, game.UI.playerStrums]) {
			line.skin = noteSkin;
			line.generateReceptors();
		}
	}

	/**
	 * A helper function for loading a variant of the currently selected UI skin in `PlayState`.
	 * @param generalSkin The skin used for the countdown, ratings, and combo.
	 * @param noteSkin The skin used for notes.
	 * @param countdownScale The scale of the countdown images.
	 * @param judgementScale The scale of the ratings and combo.
	 * @param countdownAntialiasing The antialiasing for the countdown images.
	 * @param ratingAntialiasing The antialiasing for the rating images.
	 * @param comboAntialiasing The antialiasing for the combo images.
	 */
	public inline static function loadUISkinVariant(generalSkin:String, noteSkin:String, countdownScale:Array<Float>, judgementScale:Array<Float>, countdownAntialiasing:Bool = true, ratingAntialiasing:Bool = true, comboAntialiasing:Bool = true) {
		var game = PlayState.current;

		game.countdownSkin = generalSkin;
		game.ratingSkin = generalSkin;
		game.comboSkin = generalSkin;
		game.noteSkin = PlayerSettings.prefs.get("Note Skin")+"-"+noteSkin;
	
		for(sprite in [game.countdownReady, game.countdownSet, game.countdownGo]) {
			sprite.scale.set(countdownScale[0], countdownScale[1]);
			sprite.antialiasing = countdownAntialiasing ? PlayerSettings.prefs.get("Antialiasing") : false;
			sprite.updateHitbox();
		}
		game.ratingScale = judgementScale[0];
		game.comboScale = judgementScale[1];
	
		game.ratingAntialiasing = ratingAntialiasing;
		game.comboAntialiasing = comboAntialiasing;
	
		for(line in [game.UI.opponentStrums, game.UI.playerStrums]) {
			line.skin = PlayerSettings.prefs.get("Note Skin")+"-"+noteSkin;
			line.generateReceptors();
		}
	}

	public inline static function readDirectory(dir:String, ?mod:Null<String>) {
		var arrayToReturn:Array<String> = [];
		var basePath:String = '${Sys.getCwd()}mods/';
		if(FileSystem.exists(basePath)) {
			if(mod != null) {
				if(FileSystem.exists(basePath+mod+"/"+dir) && FileSystem.isDirectory(basePath+mod)) {
					for(item in FileSystem.readDirectory(basePath+mod+"/"+dir)) {
						if(!arrayToReturn.contains(item))
							arrayToReturn.push(item);
					}
				}
			} else {
				for(folder in FileSystem.readDirectory(basePath)) {
					if(FileSystem.exists(basePath+folder+"/"+dir) && FileSystem.isDirectory(basePath+folder)) {
						for(item in FileSystem.readDirectory(basePath+folder+"/"+dir)) {
							if(!arrayToReturn.contains(item))
								arrayToReturn.push(item);
						}
					}
				}
			}
		}
		var basePath:String = '${Sys.getCwd()}assets/';
		if(FileSystem.exists(basePath)) {
			if(FileSystem.exists(basePath+dir) && FileSystem.isDirectory(basePath+dir)) {
				for(item in FileSystem.readDirectory(basePath+dir)) {
					if(!arrayToReturn.contains(item))
						arrayToReturn.push(item);
				}
			}
		}
		var basePath:String = '${Sys.getCwd()}../../../../assets/';
		if(FileSystem.exists(basePath)) {
			if(FileSystem.exists(basePath+dir) && FileSystem.isDirectory(basePath+dir)) {
				for(item in FileSystem.readDirectory(basePath+dir)) {
					if(!arrayToReturn.contains(item))
						arrayToReturn.push(item);
				}
			}
		}
		var basePath:String = '${Sys.getCwd()}../../../../mods/';
		if(FileSystem.exists(basePath)) {
			if(mod != null) {
				if(FileSystem.exists(basePath+mod+"/"+dir) && FileSystem.isDirectory(basePath+mod)) {
					for(item in FileSystem.readDirectory(basePath+mod+"/"+dir)) {
						if(!arrayToReturn.contains(item))
							arrayToReturn.push(item);
					}
				}
			} else {
				for(folder in FileSystem.readDirectory(basePath)) {
					if(FileSystem.exists(basePath+folder+"/"+dir) && FileSystem.isDirectory(basePath+folder)) {
						for(item in FileSystem.readDirectory(basePath+folder+"/"+dir)) {
							if(!arrayToReturn.contains(item))
								arrayToReturn.push(item);
						}
					}
				}
			}
		}
		return arrayToReturn;
	}

	public inline static function readDirectoryFoldersOnly(dir:String, ?mod:Null<String>) {
		var arrayToReturn:Array<String> = [];
		var basePath:String = '${Sys.getCwd()}mods/';
		if(FileSystem.exists(basePath)) {
			if(mod != null) {
				if(FileSystem.isDirectory(basePath+mod) && FileSystem.exists(basePath+mod+"/"+dir)) {
					for(item in FileSystem.readDirectory(basePath+mod+"/"+dir)) {
						if(!arrayToReturn.contains(item) && FileSystem.isDirectory(basePath+mod+"/"+dir+"/"+item))
							arrayToReturn.push(item);
					}
				}
			} else {
				for(folder in FileSystem.readDirectory(basePath)) {
					if(FileSystem.isDirectory(basePath+folder) && FileSystem.exists(basePath+folder+"/"+dir)) {
						for(item in FileSystem.readDirectory(basePath+folder+"/"+dir)) {
							if(!arrayToReturn.contains(item) && FileSystem.isDirectory(basePath+folder+"/"+dir+"/"+item))
								arrayToReturn.push(item);
						}
					}
				}
			}
		}
		var basePath:String = '${Sys.getCwd()}assets/';
		if(FileSystem.exists(basePath)) {
			if(FileSystem.exists(basePath+dir) && FileSystem.isDirectory(basePath+dir)) {
				for(item in FileSystem.readDirectory(basePath+dir)) {
					if(!arrayToReturn.contains(item) && FileSystem.isDirectory(basePath+dir+"/"+item))
						arrayToReturn.push(item);
				}
			}
		}
		var basePath:String = '${Sys.getCwd()}../../../../assets/';
		if(FileSystem.exists(basePath)) {
			if(FileSystem.exists(basePath+dir) && FileSystem.isDirectory(basePath+dir)) {
				for(item in FileSystem.readDirectory(basePath+dir)) {
					if(!arrayToReturn.contains(item) && FileSystem.isDirectory(basePath+dir+"/"+item))
						arrayToReturn.push(item);
				}
			}
		}
		var basePath:String = '${Sys.getCwd()}../../../../mods/';
		if(FileSystem.exists(basePath)) {
			if(mod != null) {
				if(FileSystem.isDirectory(basePath+mod) && FileSystem.exists(basePath+mod+"/"+dir)) {
					for(item in FileSystem.readDirectory(basePath+mod+"/"+dir)) {
						if(!arrayToReturn.contains(item) && FileSystem.isDirectory(basePath+mod+"/"+dir+"/"+item))
							arrayToReturn.push(item);
					}
				}
			} else {
				for(folder in FileSystem.readDirectory(basePath)) {
					if(FileSystem.isDirectory(basePath+folder) && FileSystem.exists(basePath+folder+"/"+dir)) {
						for(item in FileSystem.readDirectory(basePath+folder+"/"+dir)) {
							if(!arrayToReturn.contains(item) && FileSystem.isDirectory(basePath+folder+"/"+dir+"/"+item))
								arrayToReturn.push(item);
						}
					}
				}
			}
		}
		return arrayToReturn;
	}
}

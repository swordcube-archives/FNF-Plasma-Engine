package ui;

import flixel.util.FlxColor;
import flash.media.Sound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup {
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Float = 0;
	public var yMult:Float = 120;

	public var snapX:Bool = false;
	public var snapY:Bool = false;

	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var isMenuItem:Bool = false;
	public var textSize:Float = 1.0;

	public var text:String = "";

	var _finalText:String = "";
	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;

	var splitWords:Array<String> = [];

	public var isBold:Bool = false;
	public var lettersArray:Array<AlphaCharacter> = [];

	public var finishedText:Bool = false;
	public var typed:Bool = false;

	public var typingSpeed:Float = 0.05;
	public var textColor:FlxColor;

	/**
		Creates a new alphabet text at `x`, `y`

		@param x              The x position of the text.
		@param y              The y position of the text.
		@param text           The text that the alphabet says.
		@param bold           Choose whether or not the text has white text and a black outline or just white text.
		@param color          Change what color the text is.
		@param typed          Choose if the text is typed out over time.
		@param typingSpeed    Choose the speed the text gets typed at (only used if `typed` is enabled.)
		@param textSize       Change the size of the text.
	**/
	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, color:FlxColor = FlxColor.BLACK, typed:Bool = false, ?typingSpeed:Float = 0.05, ?textSize:Float = 1)
	{
		super(x, y);
		forceX = Math.NEGATIVE_INFINITY;
		this.textSize = textSize;

		_finalText = text;
		this.text = text;
		this.typed = typed;
		textColor = color;
		isBold = bold;

		if (text != "")
		{
			if (typed)
			{
				startTypedText(typingSpeed);
			}
			else
			{
				addText();
			}
		} else {
			finishedText = true;
		}
	}

	public function changeText(newText:String, newTypingSpeed:Float = -1)
	{
		for (i in 0...lettersArray.length) {
			var letter = lettersArray[0];
			remove(letter);
			letter.kill();
			letter.destroy();
			lettersArray.remove(letter);
		}
		lettersArray = [];
		splitWords = [];
		loopNum = 0;
		xPos = 0;
		curRow = 0;
		consecutiveSpaces = 0;
		xPosResetted = false;
		finishedText = false;
		lastSprite = null;

		var lastX = x;
		x = 0;
		_finalText = newText;
		text = newText;
		if(newTypingSpeed != -1) {
			typingSpeed = newTypingSpeed;
		}

		if (text != "") {
			if (typed)
			{
				startTypedText(typingSpeed);
			} else {
				addText();
			}
		} else {
			finishedText = true;
		}
		x = lastX;
	}

	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;
		for (character in splitWords)
		{
			// if (character.fastCodeAt() == " ")
			// {
			// }

			var spaceChar:Bool = (character == " " || (isBold && character == "_"));
			if (spaceChar)
			{
				consecutiveSpaces++;
			}

			var isNumber:Bool = AlphaCharacter.numbers.indexOf(character) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(character) != -1;
			var isAlphabet:Bool = AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1;
			if ((isAlphabet || isSymbol || isNumber) && (!isBold || !spaceChar))
			{
				if (lastSprite != null)
				{
					xPos = lastSprite.x + lastSprite.width;
				}

				if (consecutiveSpaces > 0)
				{
					xPos += 40 * consecutiveSpaces * textSize;
				}
				consecutiveSpaces = 0;

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0, textSize);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0, textSize, textColor);

				if (isBold)
				{
					if (isNumber)
					{
						letter.createBoldNumber(character);
					}
					else if (isSymbol)
					{
						letter.createBoldSymbol(character);
					}
					else
					{
						letter.createBoldLetter(character);
					}
				}
				else
				{
					if (isNumber)
					{
						letter.createNumber(character);
					}
					else if (isSymbol)
					{
						letter.createSymbol(character);
					}
					else
					{
						letter.createLetter(character);
					}
				}

				add(letter);
				lettersArray.push(letter);

				lastSprite = letter;
			}

			// loopNum += 1;
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	var loopNum:Int = 0;
	var xPos:Float = 0;
	public var curRow:Int = 0;
	var dialogueSound:FlxSound = null;
	private static var soundDialog:Sound = null;
	var consecutiveSpaces:Int = 0;
	public static function setDialogueSound(name:String = '')
	{
		if (name == null || name.trim() == '') name = 'dialogue';
		soundDialog = FNFAssets.returnAsset(SOUND, AssetPaths.sound(name));
		if(soundDialog == null) soundDialog = FNFAssets.returnAsset(SOUND, AssetPaths.sound('dialogue'));
	}

	var typeTimer:FlxTimer = null;
	public function startTypedText(speed:Float):Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		if(soundDialog == null)
		{
			Alphabet.setDialogueSound();
		}

		if(speed <= 0) {
			while(!finishedText) { 
				timerCheck();
			}
			if(dialogueSound != null) dialogueSound.stop();
			dialogueSound = FlxG.sound.play(soundDialog);
		} else {
			typeTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer) {
				typeTimer = new FlxTimer().start(speed, function(tmr:FlxTimer) {
					timerCheck(tmr);
				}, 0);
			});
		}
	}

	var LONG_TEXT_ADD:Float = -24; //text is over 2 rows long, make it go up a bit
	public function timerCheck(?tmr:FlxTimer = null) {
		var autoBreak:Bool = false;
		if ((loopNum <= splitWords.length - 2 && splitWords[loopNum] == "\\" && splitWords[loopNum+1] == "n") ||
			((autoBreak = true) && xPos >= FlxG.width * 0.65 && splitWords[loopNum] == ' ' ))
		{
			if(autoBreak) {
				if(tmr != null) tmr.loops -= 1;
				loopNum += 1;
			} else {
				if(tmr != null) tmr.loops -= 2;
				loopNum += 2;
			}
			yMulti += 1;
			xPosResetted = true;
			xPos = 0;
			curRow += 1;
			if(curRow == 2) y += LONG_TEXT_ADD;
		}

		if(loopNum <= splitWords.length && splitWords[loopNum] != null) {
			var spaceChar:Bool = (splitWords[loopNum] == " " || (isBold && splitWords[loopNum] == "_"));
			if (spaceChar)
			{
				consecutiveSpaces++;
			}

			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			var isAlphabet:Bool = AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1;

			if ((isAlphabet || isSymbol || isNumber) && (!isBold || !spaceChar))
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (consecutiveSpaces > 0)
				{
					xPos += 20 * consecutiveSpaces * textSize;
				}
				consecutiveSpaces = 0;

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0, textSize);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti, textSize, textColor);
				letter.row = curRow;
				if (isBold)
				{
					if (isNumber)
					{
						letter.createBoldNumber(splitWords[loopNum]);
					}
					else if (isSymbol)
					{
						letter.createBoldSymbol(splitWords[loopNum]);
					}
					else
					{
						letter.createBoldLetter(splitWords[loopNum]);
					}
				}
				else
				{
					if (isNumber)
					{
						letter.createNumber(splitWords[loopNum]);
					}
					else if (isSymbol)
					{
						letter.createSymbol(splitWords[loopNum]);
					}
					else
					{
						letter.createLetter(splitWords[loopNum]);
					}
				}
				letter.x += 90;

				if(tmr != null) {
					if(dialogueSound != null) dialogueSound.stop();
					dialogueSound = FlxG.sound.play(soundDialog);
				}

				add(letter);

				lastSprite = letter;
			}
		}

		loopNum++;
		if(loopNum >= splitWords.length) {
			if(tmr != null) {
				typeTimer = null;
				tmr.cancel();
				tmr.destroy();
			}
			finishedText = true;
		}
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			var lerpVal:Float = FlxMath.bound(FlxG.elapsed * 9.6, 0, 1);
			var finalY:Float = (scaledY * yMult) + (FlxG.height * 0.48) + yAdd;
			y = snapY ? finalY : FlxMath.lerp(y, finalY, lerpVal);
			if(forceX != Math.NEGATIVE_INFINITY) {
				x = forceX;
			} else {
				var finalX:Float = (targetY * 20) + 90 + xAdd;
				x = snapX ? finalX : FlxMath.lerp(x, finalX, lerpVal);
			}
			snapX = false;
			snapY = false;
		}

		super.update(elapsed);
	}

	public function killTheTimer() {
		if(typeTimer != null) {
			typeTimer.cancel();
			typeTimer.destroy();
		}
		typeTimer = null;
	}
}

class AlphaCharacter extends FlxSprite {
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var row:Int = 0;

	private var textSize:Float = 1;

	var textColor:FlxColor;

	public function new(x:Float, y:Float, textSize:Float, color:FlxColor)
	{
		super(x, y);
		var tex = FNFAssets.returnAsset(SPARROW, 'alphabet');
		frames = tex;

		setGraphicSize(Std.int(width * textSize));
		updateHitbox();
		this.textSize = textSize;
		textColor = color;
		antialiasing = Settings.get("Antialiasing");
	}

	public function createBoldLetter(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createBoldNumber(letter:String):Void
	{
		animation.addByPrefix(letter, "bold" + letter, 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createBoldSymbol(letter:String)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'PERIOD bold', 24);
			case "'":
				animation.addByPrefix(letter, 'APOSTRAPHIE bold', 24);
			case "?":
				animation.addByPrefix(letter, 'QUESTION MARK bold', 24);
			case "!":
				animation.addByPrefix(letter, 'EXCLAMATION POINT bold', 24);
			case "(":
				animation.addByPrefix(letter, 'bold (', 24);
			case ")":
				animation.addByPrefix(letter, 'bold )', 24);
			default:
				animation.addByPrefix(letter, 'bold ' + letter, 24);
		}
		animation.play(letter);
		updateHitbox();
		switch (letter)
		{
			case "'":
				y -= 20 * textSize;
			case '-':
				//x -= 35 - (90 * (1.0 - textSize));
				y += 20 * textSize;
			case '(':
				x -= 65 * textSize;
				y -= 5 * textSize;
				offset.x = -58 * textSize;
			case ')':
				x -= 20 / textSize;
				y -= 5 * textSize;
				offset.x = 12 * textSize;
			case '.':
				y += 45 * textSize;
				x += 5 * textSize;
				offset.x += 3 * textSize;
		}
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		updateHitbox();

		color = textColor;

		y = (110 - height);
		y += row * 60;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();

		color = textColor;

		y = (110 - height);
		y += row * 60;
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '#':
				animation.addByPrefix(letter, 'hashtag', 24);
			case '.':
				animation.addByPrefix(letter, 'period', 24);
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				y -= 50;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
			case ",":
				animation.addByPrefix(letter, 'comma', 24);
			default:
				animation.addByPrefix(letter, letter, 24);
		}
		animation.play(letter);

		color = textColor;

		updateHitbox();

		y = (110 - height);
		y += row * 60;
		switch (letter)
		{
			case "'":
				y -= 20;
			case '-':
				//x -= 35 - (90 * (1.0 - textSize));
				y -= 16;
		}
	}
}

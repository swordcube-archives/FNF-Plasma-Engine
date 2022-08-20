package ui;

import flixel.FlxG;
import flixel.group.FlxGroup;
import gameplay.StrumLine;
import hscript.HScript;
import shaders.ColorShader;
import systems.FNFSprite;

class NoteSplash extends FNFSprite
{
	public var started:Bool = false;

	public var noteData:Int = 0;
	public var keyCount:Int = 4;

	public var parent:StrumLine;
	public var colorSwap:ColorShader;

	var script:HScript;

	public function new(x:Float, y:Float, noteData:Int = 0, skin:String = "splashes/NOTE_splashes")
	{
		super(x, y);

		this.noteData = noteData;
		
		frames = FNFAssets.returnAsset(SPARROW, skin);
		animation.addByPrefix("splash1", "splash 1", 24, false);
		animation.addByPrefix("splash2", "splash 2", 24, false);
	
		scale.set(0.7, 0.7);
		updateHitbox();
	
		offset.x = frameWidth / 2;
		offset.y = frameHeight / 2;
	
		offset.x -= 156 * (scale.x / 2);
		offset.y -= 156 * (scale.y / 2);
	
		animation.play("splash"+FlxG.random.int(1, 2));
		if(animation.curAnim != null) animation.curAnim.frameRate *= 1.35;

		colorSwap = new ColorShader(255, 255, 255);
		shader = colorSwap;
		setColor();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(animation.curAnim != null && animation.curAnim.finished) {
			kill();
			destroy();
		}
	}

	public function setColor()
	{
		var colorArray:Array<Int> = Init.arrowColors[parent != null ? parent.keyCount - 1 : keyCount - 1][noteData];
		
		if (colorSwap != null && colorArray != null) // haxeflixel
			colorSwap.setColors(colorArray[0], colorArray[1], colorArray[2]);
	}

	public function resetColor()
	{
		if (colorSwap != null) // haxeflixel
			colorSwap.setColors(255, 255, 255);
	}
}

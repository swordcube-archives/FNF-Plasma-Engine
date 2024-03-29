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

	public var parent:StrumLine;
	public var colorSwap:ColorShader;

	public function new(x:Float, y:Float, colors:Array<Int>, direction:String = "", funny_scale:Float, skin:String = "splashes/NOTE_splashes", useShader:Bool = true)
	{
		super(x, y);
		
		frames = FNFAssets.returnAsset(SPARROW, skin);
		animation.addByPrefix("splash1", direction+" splash 1", 24, false);
		animation.addByPrefix("splash2", direction+" splash 2", 24, false);
	
		scale.set(0.7 * funny_scale, 0.7 * funny_scale);
		updateHitbox();
	
		offset.x = frameWidth / 2;
		offset.y = frameHeight / 2;

		var sex:Float = 0.7 * funny_scale;
	
		offset.x -= 156 * (sex / 2);
		offset.y -= 156 * (sex / 2);
	
		animation.play("splash"+FlxG.random.int(1, 2));
		if(animation.curAnim != null) animation.curAnim.frameRate *= 1.35;

		if(useShader) {
			colorSwap = new ColorShader(255, 255, 255);
			shader = colorSwap;
			colorSwap.setColors(colors[0], colors[1], colors[2]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(animation.curAnim != null && animation.curAnim.finished) {
			kill();
			destroy();
		}
	}

	public function resetColor()
	{
		if (colorSwap != null) // haxeflixel
			colorSwap.setColors(255, 255, 255);
	}
}

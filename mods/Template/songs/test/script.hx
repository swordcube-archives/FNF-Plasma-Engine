import ("flixel.math.FlxMath");
import("flixel.tweens.FlxTween");

var noBitches = 0;

function update(elapsed)
{
	noBitches += 180 * elapsed;
	PlayState.instance.camHUD.alpha = 1 - Math.sin((Math.PI * noBitches) / 180);
	PlayState.instance.camHUD.angle = FlxMath.lerp(PlayState.instance.camHUD.angle, 0, elapsed * 5);
}

function beatHit(curBeat)
{
	if(curBeat % 16 == 0)
	{
		PlayState.instance.camHUD.angle = -180;
		PlayState.instance.camHUD.zoom += 0.1;
	}
}

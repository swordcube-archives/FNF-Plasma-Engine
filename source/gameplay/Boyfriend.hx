package gameplay;

using StringTools;

class Boyfriend extends Character {
	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed * (FlxG.state == PlayState.current ? PlayState.songMultiplier : 1.0);
			else
				holdTimer = 0;

			if (animation.curAnim != null && animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				playAnim('idle', true, false, 10);
		}

		super.update(elapsed);
	}
}
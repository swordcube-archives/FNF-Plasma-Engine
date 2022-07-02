package funkin.game;

import funkin.systems.Conductor;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;
	public var startedDeath:Bool = false;

	public function new(x:Float, y:Float, ?character:String = 'bf')
	{
		super(x, y, character, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				playAnim('idle', true, false, 10);

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
				playAnim('deathLoop');

			if(!PlayState.UI.playerStrums.pressed.contains(true) && holdTimer > Conductor.stepCrochet * 0.001 * singDuration && animation.curAnim.name.startsWith('sing') && !animation.curAnim.name.endsWith('miss'))
				dance();
		}

		super.update(elapsed);
	}
}
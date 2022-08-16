package ui;

import flixel.group.FlxGroup;
import hscript.HScript;

class JudgementUI extends FlxGroup
{
	var script:HScript;

	public function new(judgement:String, combo:Int, ratingScale:Float, comboScale:Float)
	{
		super();
		
		script = new HScript("scripts/Judgement");

		// Set some variables
		script.set("ratingScale", ratingScale);
		script.set("comboScale", comboScale);

		script.set("this", this);
		script.set("add", this.add);
		script.set("remove", this.remove);
		script.set("kill", this.kill);
		script.set("destroy", this.destroy);

		// Start the script
		script.start(false); // Make the script function but don't automatically call the create function
		script.callFunction("create", [judgement, combo]);
		script.callFunction("createPost", [judgement, combo]);
		// because we call it down here
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		script.update(elapsed);
		script.callFunction("updatePost", [elapsed]);
	}
}

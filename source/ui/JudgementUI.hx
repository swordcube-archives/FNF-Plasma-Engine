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
        script.setVariable("ratingScale", ratingScale);
        script.setVariable("comboScale", comboScale);

        script.setVariable("this", this);
        script.setVariable("add", this.add);
        script.setVariable("remove", this.remove);
        script.setVariable("kill", this.kill);
        script.setVariable("destroy", this.destroy);

        // Start the script
        script.start(false); // Make the script function but don't automatically call the create function
        script.callFunction("create", [judgement, combo]);
        script.callFunction("createPost", [judgement, combo]);
        // because we call it down here
    }
}
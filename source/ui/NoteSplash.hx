package ui;

import flixel.group.FlxGroup;
import gameplay.StrumLine;
import hscript.HScript;
import shaders.ColorSwap;
import systems.FNFSprite;

class NoteSplash extends FNFSprite
{
    public var started:Bool = false;
    
    public var noteData:Int = 0;
    public var keyCount:Int = 4;
    
    public var parent:StrumLine;
    public var colorSwap:ColorSwap;

    var script:HScript;

    public function new(x:Float, y:Float, noteData:Int = 0)
    {
        super(x, y);
        script = new HScript("scripts/NoteSplash");

        // Set some variables
        script.setVariable("noteData", noteData);

        script.setVariable("sprite", this);
        script.setVariable("kill", this.kill);
        script.setVariable("destroy", this.destroy);

        // Start the script
        script.start(false);
    }

    public function setupNoteSplash(x:Float, y:Float, skin:String = "splashes/NOTE_splashes", noteData:Int)
    {
        started = true;
        this.noteData = noteData;
        setPosition(x, y);

        colorSwap = new ColorSwap(255, 255, 255);
        shader = colorSwap;
        setColor();

        script.callFunction("create", [skin]);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        // I love when my brain goes "why no update work?" then i realize i'm not even calling
        // the function that makes the script update
        // I am the dumbass ever.
        script.update(elapsed);
        script.callFunction("updatePost", [elapsed]);
    }

    public function setColor()
    {
        var colorArray:Array<Int> = Init.arrowColors[parent != null ? parent.keyCount-1 : keyCount-1][noteData];
        if(colorSwap != null && colorArray != null) // haxeflixel
            colorSwap.setColors(colorArray[0], colorArray[1], colorArray[2]);
    }

    public function resetColor()
    {
        if(colorSwap != null) // haxeflixel
            colorSwap.setColors(255, 255, 255);
    }
}
package states;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameplay.Note;
import shaders.ColorSwap;
import systems.MusicBeat;

/**
    A state that is for debugging.
**/
class NoteColorDebug extends MusicBeatState
{
    var colorSwap:ColorSwap;
    var note:Note;

    var state:Int = 0; // 0 = hue, 1 = sat, 2 = brt
    
    var hue:Int = 0;
    var sat:Int = 0;
    var brt:Int = 0;

    var text:FlxText;

    override function create()
    {
        super.create();

        colorSwap = new ColorSwap();

        note = new Note(0, 0, 3);
        note.keyCount = 4;
        note.loadSkin("arrows");
        note.shader = colorSwap.shader;
        note.screenCenter();
        add(note);

        text = new FlxText(0, note.y + 150, 0, "0", 32);
        text.setFormat(AssetPaths.font("vcr"), 32, FlxColor.WHITE, CENTER);
        text.screenCenter(X);
        add(text);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.LEFT)
        {
            var mult:Int = !FlxG.keys.pressed.SHIFT ? -10 : -1;
            switch(state)
            {
                case 0:
                    colorSwap.hue += mult/360;
                    
                case 1:
                    colorSwap.saturation += mult/100;
                    
                case 2:
                    colorSwap.brightness += mult/100;
            }
            text.text = Std.string(Math.round(colorSwap.hue*360));
            text.text += "\n" + Std.string(Math.round(colorSwap.saturation*100));
            text.text += "\n" + Std.string(Math.round(colorSwap.brightness*100));
            text.screenCenter(X);
        }

        if(FlxG.keys.justPressed.RIGHT)
        {
            var mult:Int = !FlxG.keys.pressed.SHIFT ? 10 : 1;
            switch(state)
            {
                case 0:
                    colorSwap.hue += mult/360;
                    
                case 1:
                    colorSwap.saturation += mult/100;
                    
                case 2:
                    colorSwap.brightness += mult/100;
            }
            text.text = Std.string(Math.round(colorSwap.hue*360));
            text.text += "\n" + Std.string(Math.round(colorSwap.saturation*100));
            text.text += "\n" + Std.string(Math.round(colorSwap.brightness*100));
            text.screenCenter(X);
        }

        if(FlxG.keys.justPressed.SPACE)
        {
            state += 1;
            if(state > 2)
                state = 0;
            
            switch(state)
            {
                case 0:
                    trace("switched to hue");
                case 1:
                    trace("switched to sat");
                case 2:
                    trace("switched to brt");
            }
        }
    }
}
package gameplay;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import states.PlayState;
import systems.Conductor;

class StrumLine extends FlxTypedSpriteGroup<StrumNote>
{
    public var hasInput:Bool = true;
    
    public var keyCount:Int = 4;
    public var notes:FlxTypedGroup<Note>;

    public function new(x:Float, y:Float, keyCount:Int = 4)
    {
        super(x, y);

        this.keyCount = keyCount;

        notes = new FlxTypedGroup<Note>();

        generateArrows();
    }

    public function generateArrows()
    {
        while(members.length > 0)
        {
            var bemb:StrumNote = members[0];
            remove(bemb, true);
            bemb.kill();
            bemb.destroy();
        }

        for(i in 0...keyCount)
        {
            var strum:StrumNote = new StrumNote(Note.swagWidth * i, -10, i);
            strum.parent = this;
            strum.alpha = 0;
            strum.loadSkin("arrows");
            add(strum);
            FlxTween.tween(strum, { y: strum.y + 10, alpha: 0.75 }, 0.5, { ease: FlxEase.circOut, startDelay: i * 0.3 }).start();
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(hasInput)
        {
            var i:Int = 0;
            for(strum in members)
            {
                var key:FlxKey = Init.keyBinds[keyCount-1][i];
                if(FlxG.keys.checkStatus(key, JUST_PRESSED))
                {
                    strum.setColor();
                    strum.playAnim("press", true);
                    strum.alpha = 1;
                }

                if(FlxG.keys.checkStatus(key, JUST_RELEASED))
                {
                    strum.resetColor();
                    strum.playAnim("static", true);
                    strum.alpha = Init.trueSettings.get("Opaque Strums") ? 1 : 0.75;
                }

                i++;
            }
        }

        var possibleNotes:Array<Note> = [];
        notes.forEachAlive(function(note:Note) {
            note.x = members[note.noteData].x;
            note.y = members[note.noteData].y - (0.45 * (Conductor.position - note.strumTime) * PlayState.current.scrollSpeed);
            
            if(hasInput)
            {
                if((Conductor.position - note.strumTime) > Conductor.safeZoneOffset)
                {
                    notes.remove(note, true);
                    note.kill();
                    note.destroy();
                }

                // Make the note possible to hit if it's in the safe zone to be hit.
                if((Conductor.position - note.strumTime) > -Conductor.safeZoneOffset)
                    possibleNotes.push(note);
            }
            else
            {
                if((Conductor.position - note.strumTime) >= 0.0)
                {
                    notes.remove(note, true);
                    note.kill();
                    note.destroy();
                }
            }
        });

        if(hasInput)
        {
            var justPressed:Array<Bool> = [];
            var pressed:Array<Bool> = [];

            for(i in 0...keyCount)
            {
                justPressed.push(FlxG.keys.checkStatus(Init.keyBinds[keyCount-1][i], JUST_PRESSED));
                pressed.push(FlxG.keys.checkStatus(Init.keyBinds[keyCount-1][i], PRESSED));
            }

            if(possibleNotes.length > 0)
            {
                possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
                
                for (note in possibleNotes) {
                    // Check if we just pressed the keybind the note has and if we're allowed to hit the note
                    // If both are true, then we delete the note.
                    
                    if(justPressed[note.noteData])
                    {
                        justPressed[note.noteData] = false;
                        members[note.noteData].playAnim("confirm", true);
                        goodNoteHit(note);
                    }
                }
            }
        }
    }

    function goodNoteHit(note:Note)
    {
        notes.remove(note, true);
        note.kill();
        note.destroy();
    }
}
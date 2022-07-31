package gameplay;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxRect;
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
                    strum.colorSwap.enabled.value = [true];
                    strum.playAnim("press", true);
                    strum.alpha = 1;
                }

                if(FlxG.keys.checkStatus(key, JUST_RELEASED))
                {
                    strum.colorSwap.enabled.value = [false];
                    strum.resetColor();
                    strum.playAnim("static", true);
                    strum.alpha = Init.trueSettings.get("Opaque Strums") ? 1 : 0.75;
                }

                i++;
            }
        }
        else
        {
            for(strum in members)
            {
                if(strum.animation.curAnim != null && strum.animation.curAnim.name == "confirm" && strum.animation.curAnim.finished)
                {
                    strum.resetColor();
                    strum.colorSwap.enabled.value = [false];
                    strum.alpha = Init.trueSettings.get("Opaque Strums") ? 1 : 0.75;
                    strum.playAnim("static");
                }
            }
        }

        var stepHeight = (0.45 * Conductor.stepCrochet * PlayState.current.scrollSpeed);

        var possibleNotes:Array<Note> = [];
        notes.forEachAlive(function(note:Note) {
            note.x = members[note.noteData].x;
            
            var scrollAmount:Float = (note.isDownScroll ? -1 : 1) * 0.45;
            note.y = members[note.noteData].y - (scrollAmount * (Conductor.position - note.strumTime) * PlayState.current.scrollSpeed);
            
            if(hasInput)
            {
                if((Conductor.position - note.strumTime) > Conductor.safeZoneOffset)
                {
                    PlayState.current.vocals.volume = 0;
                    notes.forEachAlive(function(deezNote:Note) {
                        if(deezNote.isSustain && deezNote.sustainParent == note)
                            deezNote.canBeHit = false;
                    });
                    notes.remove(note, true);
                    note.kill();
                    note.destroy();
                }

                // Make the note possible to hit if it's in the safe zone to be hit.
                if(note.canBeHit && ((Conductor.position - note.strumTime) > -Conductor.safeZoneOffset))
                    possibleNotes.push(note);
            }
            else
            {
                if((Conductor.position - note.strumTime) >= 0.0)
                {
                    PlayState.current.vocals.volume = 1;
                    members[note.noteData].alpha = 1;
                    members[note.noteData].setColor();
                    members[note.noteData].colorSwap.enabled.value = [true];
                    members[note.noteData].playAnim("confirm", true);
                    notes.remove(note, true);
                    note.kill();
                    note.destroy();
                }
            }
        });

        var justPressed:Array<Bool> = [];
        var pressed:Array<Bool> = [];

        if(hasInput)
        {
            justPressed = [];
            pressed = [];

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
                    
                    if(justPressed[note.noteData] && !note.isSustain)
                    {
                        PlayState.current.vocals.volume = 1;
                        justPressed[note.noteData] = false;
                        members[note.noteData].playAnim("confirm", true);
                        goodNoteHit(note);
                    }

                    if(pressed[note.noteData] && note.isSustain && (Conductor.position - note.strumTime) >= 0.0)
                    {
                        PlayState.current.vocals.volume = 1;
                        members[note.noteData].setColor();
                        members[note.noteData].colorSwap.enabled.value = [true];
                        members[note.noteData].playAnim("confirm", true);
                        notes.remove(note, true);
                        note.kill();
                        note.destroy();
                    }
                }
            }
        }

        notes.forEachAlive(function(note:Note) {
            if(note.isDownScroll)
            {
                if(note.isSustain)
                {
                    note.y -= note.height - stepHeight;
                    note.y += 10;
                    
                    if ((PlayState.current.botPlay
                        || !hasInput
                        || (hasInput && note.canBeHit && pressed[note.noteData]))
                        && note.y - note.offset.y * note.scale.y + note.height >= (this.y + Note.swagWidth / 2))
                    {
                        // Clip to strumline
                        var swagRect = new FlxRect(0, 0, note.frameWidth * 2, note.frameHeight * 2);
                        swagRect.height = (members[note.noteData].y
                            + Note.swagWidth / 2
                            - note.y) / note.scale.y;
                        swagRect.y = note.frameHeight - swagRect.height;

                        note.clipRect = swagRect;
                    }
                }
            }
            else
            {
                if(note.isSustain)
                {
                    note.y += 10;
                    
                    if ((PlayState.current.botPlay
                        || !hasInput
                        || (hasInput && note.canBeHit && pressed[note.noteData]))
                        && note.y + note.offset.y * note.scale.y <= (this.y + Note.swagWidth / 2))
                    {
                        // Clip to strumline
                        var swagRect = new FlxRect(0, 0, note.width / note.scale.x, note.height / note.scale.y);
                        swagRect.y = (members[note.noteData].y
                            + Note.swagWidth / 2
                            - note.y) / note.scale.y;
                        swagRect.height -= swagRect.y;

                        note.clipRect = swagRect;
                    }
                }
            }
        });
    }

    function goodNoteHit(note:Note)
    {
        notes.remove(note, true);
        note.kill();
        note.destroy();
    }
}
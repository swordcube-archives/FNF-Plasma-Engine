package funkin.ui.playstate;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxRect;
import funkin.game.Note;
import funkin.game.PlayState;
import funkin.systems.Conductor;
import funkin.systems.Ranking;

class StrumLine extends FlxTypedSpriteGroup<StrumNote>
{
    public var justPressed:Array<Bool> = [];
    public var pressed:Array<Bool> = [];
    public var released:Array<Bool> = [];
    public var justReleased:Array<Bool> = [];

    public var noteDataTimes:Array<Float> = [];
    public var dontHit:Array<Bool> = [];
    
    /**
        The group of notes you can hit or miss.
    **/
    public var notes:FlxTypedGroup<Note>;

    public var hasInput:Bool = false;
    
    /**
        The function that makes the strum line.

        @param x         The X Position.
        @param y         The Y Position.
        @param skin      The skin to use for each strum.
        @param keyCount  The amount of strums there should be.
        @param hasInput  Allows each strum to handle inputs when set to true.
    **/
    public function new(x:Float, y:Float, skin:String = "default", keyCount:Int, hasInput:Bool = false)
    {
        super(x, y);

        this.hasInput = hasInput;

        for(i in 0...keyCount)
        {
            var newStrum:StrumNote = new StrumNote(x + (Note.swagWidth * i), 0, keyCount, i, skin);
            add(newStrum);
        }

        notes = new FlxTypedGroup<Note>();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var stepHeight = (0.45 * Conductor.stepCrochet * PlayState.scrollSpeed);
        
        var possibleNotes:Array<Note> = [];

        notes.forEachAlive(function(note:Note) {
            var strumNote:StrumNote = members[note.noteData];
            note.x = strumNote.x;
            
            if(note.downScroll)
                note.y = this.y + (0.45 * (Conductor.position - note.strumTime) * PlayState.scrollSpeed) - note.noteYOff;
            else
                note.y = this.y - (0.45 * (Conductor.position - note.strumTime) * PlayState.scrollSpeed) + note.noteYOff;
            
            if(hasInput)
            {
                if(Conductor.position >= note.strumTime - Conductor.safeZoneOffset)
                    possibleNotes.push(note);

                // sort the notes so input actually functions correctly
                possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
            }
            else
            {
                if(Conductor.position >= note.strumTime)
                {
                    PlayState.voices.volume = 1;

                    PlayState.dad.holdTimer = 0.0;
                    PlayState.dad.playAnim(Note.singAnims[PlayState.SONG.keyCount][note.noteData], true);
                    
                    notes.remove(note, true);
                    note.kill();
                    note.destroy();
                }
            }
        });

        justPressed = [];
        pressed = [];
        released = [];
        justReleased = [];

        noteDataTimes = [];
        dontHit = [];

        if(hasInput)
        {
            // REPLACE WITH BINDS FROM OPTIONS WHEN OPTIONS GET ADDED!
            var binds:Array<FlxKey> = Preferences.getOption("binds4k")[0];
            var bindsAlt:Array<FlxKey> = Preferences.getOption("binds4k")[1];

            for(i in 0...PlayState.SONG.keyCount)
            {
                justPressed.push(FlxG.keys.checkStatus(binds[i], JUST_PRESSED) || FlxG.keys.checkStatus(bindsAlt[i], JUST_PRESSED));
                pressed.push(FlxG.keys.checkStatus(binds[i], PRESSED) || FlxG.keys.checkStatus(bindsAlt[i], PRESSED));
                released.push(FlxG.keys.checkStatus(binds[i], RELEASED) || FlxG.keys.checkStatus(bindsAlt[i], RELEASED));
                justReleased.push(FlxG.keys.checkStatus(binds[i], JUST_RELEASED) || FlxG.keys.checkStatus(bindsAlt[i], JUST_RELEASED));

                noteDataTimes.push(-1);
                dontHit.push(false);
            }

            // if justPressed[i] is true, then play press anim forcefully
            // if justReleased[i] is true, then play static anim forcefully
            for(i in 0...justPressed.length)
            {
                if(justPressed[i])
                    members[i].playAnim("press", true);
                
                if(justReleased[i])
                    members[i].playAnim("static", true);
            }

            if(possibleNotes.length > 0)
            {
                // go through each note, check if justPressed[note.noteData] is true and dontHit[note.noteData] is false
                // then it makes the note go bye bye
                // and also do wacky clip rect sustain shit i guess
                for(note in possibleNotes)
                {                    
                    if(!note.isSustain)
                    {
                        if(justPressed[note.noteData] && !dontHit[note.noteData])
                        {
                            noteDataTimes[note.noteData] = note.strumTime;
                            dontHit[note.noteData] = true;

                            PlayState.bf.holdTimer = 0.0;
                            PlayState.bf.playAnim(Note.singAnims[PlayState.SONG.keyCount][note.noteData], true);
                            members[note.noteData].playAnim("confirm", true);

                            PlayState.instance.health += 0.023;
                            PlayState.instance.refreshHealth();

                            var rating:String = Ranking.judgeNote(note.strumTime);
                            PlayState.instance.totalHit += Ranking.judgements[rating].mod;
                            PlayState.instance.totalNotes++;

                            PlayState.instance.songScore += Ranking.judgements[rating].score;

                            if(Ranking.judgements[rating].health != null)
                            {
                                PlayState.instance.health += Ranking.judgements[rating].health;
                                PlayState.instance.refreshHealth();
                            }

                            PlayState.instance.calculateAccuracy();
                            PlayState.UI.updateScoreText();

                            PlayState.voices.volume = 1;

                            notes.remove(note, true);
                            note.kill();
                            note.destroy();
                        }
                    }
                    else
                    {
                        if(pressed[note.noteData] && Conductor.position >= note.strumTime)
                        {
                            PlayState.bf.holdTimer = 0.0;
                            PlayState.bf.playAnim(Note.singAnims[PlayState.SONG.keyCount][note.noteData], true);
                            members[note.noteData].playAnim("confirm", true);
                            
                            PlayState.instance.health += 0.023;
                            PlayState.instance.refreshHealth();
                            PlayState.UI.updateScoreText();

                            PlayState.voices.volume = 1;

                            notes.remove(note, true);
                            note.kill();
                            note.destroy();
                        }
                    }

                    if(Conductor.position >= note.strumTime + Conductor.safeZoneOffset)
                    {
                        PlayState.bf.holdTimer = 0.0;
                        PlayState.bf.playAnim(Note.singAnims[PlayState.SONG.keyCount][note.noteData]+"miss", true);
                        PlayState.instance.songScore -= 10;
                        
                        PlayState.instance.totalNotes++;
                        PlayState.instance.songMisses++;

                        PlayState.instance.health -= 0.0475;
                        PlayState.instance.refreshHealth();
                        
                        PlayState.instance.calculateAccuracy();
                        PlayState.UI.updateScoreText();

                        PlayState.voices.volume = 0;
                        
                        notes.remove(note, true);
                        note.kill();
                        note.destroy();   
                    }
                }

                // remove stacked notes
                for(note in possibleNotes)
                {
                    if(Math.floor(note.strumTime) == Math.floor(noteDataTimes[note.noteData]))
                    {
                        notes.remove(note, true);
                        note.kill();
                        note.destroy();
                    }
                }
            }
        }

        // clipRect shit!!
        // (taken from kade engine because fuck you!)
        notes.forEachAlive(function(note:Note) {         
            if(note.isSustain)
            {
                if(note.downScroll)
                {
                    if(note.isSustain)
                    {
                        note.y -= note.height - stepHeight;
                        
                        if ((PlayState.instance.botPlay
                            || !hasInput
                            || hasInput && pressed[note.noteData])
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
                        if ((PlayState.instance.botPlay
                            || !hasInput
                            || hasInput && pressed[note.noteData])
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
            }
        });
    }
}
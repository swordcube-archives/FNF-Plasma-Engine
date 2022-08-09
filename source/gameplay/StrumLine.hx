package gameplay;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import states.PlayState;
import systems.Conductor;
import systems.ExtraKeys;
import systems.Ranking;
import ui.JudgementUI;
import ui.NoteSplash;

using StringTools;

class StrumLine extends FlxTypedSpriteGroup<StrumNote>
{
    public var hasInput:Bool = true;
    
    public var keyCount:Int = 4;
    public var notes:FlxTypedGroup<Note>;

    public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

    function getSingAnimation(noteData:Int):String
    {
        var dir:String = ExtraKeys.arrowInfo[keyCount-1][0][noteData];
        switch(dir)
        {
            case "space":
                dir = "up";
        }

        return "sing"+dir.toUpperCase();
    }

    public function new(x:Float, y:Float, keyCount:Int = 4)
    {
        super(x, y);

        this.keyCount = keyCount;

        notes = new FlxTypedGroup<Note>();

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
        splash.kill();
		grpNoteSplashes.add(splash);

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
            var strum:StrumNote = new StrumNote((Note.swagWidth * ExtraKeys.arrowInfo[keyCount-1][2]) * i, -10, i);
            strum.parent = this;
            strum.alpha = 0;
            var arrowSkin:String = (PlayState.current != null && PlayState.current.currentSkin != "default") ? PlayState.current.currentSkin : Init.trueSettings.get("Arrow Skin").toLowerCase();
            strum.loadSkin(arrowSkin);
            add(strum);
            FlxTween.tween(strum, { y: strum.y + 10, alpha: Init.trueSettings.get("Opaque Strums") ? 1 : 0.75 }, 0.5, { ease: FlxEase.circOut, startDelay: i * 0.3 }).start();
        }
    }

    public function reloadSkin()
    {
        var arrowSkin:String = PlayState.current.currentSkin != "default" ? PlayState.current.currentSkin : Init.trueSettings.get("Arrow Skin").toLowerCase();
        for(bemb in members)
            bemb.loadSkin(arrowSkin);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var inCutscene:Bool = PlayState.current != null ? PlayState.current.inCutscene : false;

        grpNoteSplashes.forEachDead(function(cock:NoteSplash) {
            if(grpNoteSplashes.length > 1)
            {
                grpNoteSplashes.remove(cock, true);
                cock.destroy();
            }
        });

        if(hasInput)
        {
            var i:Int = 0;
            for(strum in members)
            {
                var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;

                var key:FlxKey = Init.keyBinds[keyCount-1][i];
                if(FlxG.keys.checkStatus(key, JUST_PRESSED) && !inCutscene && !botPlay)
                {
                    strum.setColor();
                    strum.colorSwap.enabled.value = [true];
                    strum.playAnim("press", true);
                    strum.alpha = 1;
                }

                if((FlxG.keys.checkStatus(key, JUST_RELEASED) && !inCutscene && !botPlay) || (botPlay && strum.animation.curAnim != null && strum.animation.curAnim.name == "confirm" && strum.animation.curAnim.finished))
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
                if(PlayState.current != null && strum.animation.curAnim != null && strum.animation.curAnim.name == "confirm" && strum.animation.curAnim.finished)
                {
                    strum.resetColor();
                    strum.colorSwap.enabled.value = [false];
                    strum.alpha = Init.trueSettings.get("Opaque Strums") ? 1 : 0.75;
                    strum.playAnim("static");
                }
            }
        }

        if(PlayState.current != null)
        {
            var stepHeight = (0.45 * Conductor.stepCrochet * PlayState.current.scrollSpeed);

            var possibleNotes:Array<Note> = [];
            notes.forEachAlive(function(note:Note) {
                note.x = members[note.noteData].x;
                
                var scrollAmount:Float = (note.isDownScroll ? -1 : 1) * 0.45;
                note.y = members[note.noteData].y - (scrollAmount * (Conductor.position - note.strumTime) * PlayState.current.scrollSpeed);
                
                if(hasInput)
                {
                    var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;
                    if(!botPlay && (Conductor.position - note.strumTime) > Conductor.safeZoneOffset)
                    {
                        PlayState.current.vocals.volume = 0;
                        PlayState.current.health -= PlayState.current.healthLoss;
                        boundHealth();

                        if(!note.isSustain)
                        {
                            PlayState.current.combo = 0;
                            PlayState.current.songMisses++;

                            PlayState.current.totalNotes++;
                            PlayState.current.calculateAccuracy();
                        }
                        
                        if(note.canBeHit && PlayState.current.bf != null)
                            PlayState.current.bf.playAnim(getSingAnimation(note.noteData)+"miss", true);
                        
                        notes.forEachAlive(function(deezNote:Note) {
                            if(deezNote.isSustain && deezNote.sustainParent == note)
                                deezNote.canBeHit = false;
                        });
                        notes.remove(note, true);
                        note.kill();
                        note.destroy();
                    }

                    // Make the note possible to hit if it's in the safe zone to be hit.
                    var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;
                    if(note.canBeHit && ((Conductor.position - note.strumTime) >= (botPlay ? 0.0 : -Conductor.safeZoneOffset)))
                        possibleNotes.push(note);
                }
                else
                {
                    if((Conductor.position - note.strumTime) >= 0.0)
                    {
                        if(PlayState.current.dad != null)
                        {
                            PlayState.current.dad.holdTimer = 0.0;
                            PlayState.current.dad.playAnim(getSingAnimation(note.noteData), true);
                        }
                        
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

                var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;
                for(i in 0...keyCount)
                {
                    justPressed.push(!inCutscene ? (botPlay ? false : FlxG.keys.checkStatus(Init.keyBinds[keyCount-1][i], JUST_PRESSED)) : false);
                    pressed.push(!inCutscene ? (botPlay ? false : FlxG.keys.checkStatus(Init.keyBinds[keyCount-1][i], PRESSED)) : false);
                }

                if(possibleNotes.length > 0)
                {
                    possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
                    
                    for (note in possibleNotes) {
                        // Check if we just pressed the keybind the note has and if we're allowed to hit the note
                        // If both are true, then we delete the note.
                        
                        if((justPressed[note.noteData] || botPlay) && !note.isSustain)
                        {
                            PlayState.current.vocals.volume = 1;
                            justPressed[note.noteData] = false;
                            members[note.noteData].alpha = 1;
                            members[note.noteData].setColor();
                            members[note.noteData].colorSwap.enabled.value = [true];
                            members[note.noteData].playAnim("confirm", true);
                            goodNoteHit(note);
                        }

                        if((pressed[note.noteData] || botPlay) && note.isSustain && (Conductor.position - note.strumTime) >= 0.0)
                        {
                            PlayState.current.vocals.volume = 1;
                            PlayState.current.health += PlayState.current.healthGain;
                            boundHealth();
                            members[note.noteData].alpha = 1;
                            members[note.noteData].setColor();
                            members[note.noteData].colorSwap.enabled.value = [true];
                            members[note.noteData].playAnim("confirm", true);
                            notes.remove(note, true);
                            note.kill();
                            note.destroy();
                            if(PlayState.current.bf != null && !PlayState.current.bf.specialAnim)
                            {
                                PlayState.current.bf.holdTimer = 0.0;
                                PlayState.current.bf.playAnim(getSingAnimation(note.noteData), true);
                            }
                        }
                    }
                }

                if (PlayState.current.bf != null && PlayState.current.bf.animation.curAnim != null && PlayState.current.bf.holdTimer > Conductor.stepCrochet * PlayState.current.bf.singDuration * 0.001 && !pressed.contains(true))
                {
                    if (PlayState.current.bf.animation.curAnim.name.startsWith('sing') && !PlayState.current.bf.animation.curAnim.name.endsWith('miss'))
                        PlayState.current.bf.dance();
                }
            }

            var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;
            notes.forEachAlive(function(note:Note) {
                if(note.isDownScroll)
                {
                    if(note.isSustain)
                    {
                        note.y -= note.height - stepHeight;
                        note.y += 10;
                        
                        if ((botPlay
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
                        
                        if ((botPlay
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
    }

    function goodNoteHit(note:Note)
    {
        var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;

        notes.remove(note, true);
        note.kill();
        note.destroy();

        PlayState.current.health += PlayState.current.healthGain;

        PlayState.current.totalNotes++;

        var judgement:String = Ranking.judgeNote(note.strumTime);
        var judgeData:Judgement = Ranking.getInfo(botPlay ? "marvelous" : judgement);
        
        if(!botPlay)
            PlayState.current.songScore += judgeData.score;
        
        PlayState.current.totalHit += judgeData.mod;
        PlayState.current.health += judgeData.health;
        boundHealth();

        if(Init.trueSettings.get("Note Splashes") && judgeData.noteSplash)
        {
            var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
            splash.alpha = 1;
			splash.setupNoteSplash(members[note.noteData].x, members[note.noteData].y, members[note.noteData].json.splash_assets, note.noteData);
			grpNoteSplashes.add(splash);
        }

        PlayState.current.calculateAccuracy();
        
        PlayState.current.combo++;

        var judgeUI:JudgementUI = new JudgementUI(judgement, PlayState.current.combo, PlayState.current.ratingScale, PlayState.current.comboScale);
        PlayState.current.add(judgeUI);

        PlayState.current.UI.healthBarScript.callFunction("updateScoreText");

        if(PlayState.current.bf != null && !PlayState.current.bf.specialAnim)
        {
            PlayState.current.bf.holdTimer = 0.0;
            PlayState.current.bf.playAnim(getSingAnimation(note.noteData), true);
        }
    }

    function boundHealth()
        PlayState.current.health = FlxMath.bound(PlayState.current.health, PlayState.current.minHealth, PlayState.current.maxHealth);
}
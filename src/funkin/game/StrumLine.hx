package funkin.game;

import funkin.scripting.Script;
import openfl.display.Bitmap;
import flixel.math.FlxRect;
import funkin.scripting.events.SimpleNoteEvent;
import funkin.scripting.events.NoteHitEvent;
import funkin.states.PlayState;
import funkin.shaders.ColorShader;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.game.Note;
import funkin.system.FNFSprite;
import flixel.group.FlxSpriteGroup;

class StrumLine extends FlxSpriteGroup {
    public var isOpponent:Bool = false;
    public var input:NoteInput;
    public var receptors:FlxTypedSpriteGroup<Receptor>;

    // All notes
    public var notes:NoteGroup;
    // Sustains only
    public var sustainGroup:NoteGroup;
    // Notes only
    public var noteGroup:NoteGroup;

    public var noteSplashes:FlxTypedSpriteGroup<NoteSplash>;

    public var noteSpeed:Float = 0;

    public var skin:String = "Arrows";
    public var keyAmount(default, set):Int;

	function set_keyAmount(v:Int):Int {
        generateReceptors(v);
		return keyAmount = v;
	}

    public function generateReceptors(?keyAmount:Null<Int>) {
        if(keyAmount == null) keyAmount = this.keyAmount;

        // Removes the old receptors
        var i:Int = receptors.members.length;
		while (i > 0) {
			--i;
			var receptor:Receptor = receptors.members[i];
			if(receptor != null) {
				receptor.kill();
				receptors.members.remove(receptor);
				receptor.destroy();
			}
		}
        receptors.clear();

        // Generates the new receptors
        for(i in 0...keyAmount) {
            var receptor = new Receptor(((Note.spacing * Note.keyInfo[keyAmount].scale) * i) * Note.keyInfo[keyAmount].spacing, -10, keyAmount, i, skin);
            receptor.alpha = 0;
            FlxTween.tween(receptor, {y: y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
            receptors.add(receptor);
        }

        input.pressed = [for(i in 0...keyAmount) false];
    }

    public function new(x:Float, y:Float, keyAmount:Int = 4, skin:String = "Arrows") {
        super(x, y);

        noteSpeed = PlayState.SONG.scrollSpeed;
        
        var prefs = PlayerSettings.prefs;
        switch(prefs.get("Scroll Type")) {
            case "Multiplier":
                if(prefs.get("Scroll Speed") > 0)
                    noteSpeed *= prefs.get("Scroll Speed");

            default:
                if(prefs.get("Scroll Speed") > 0)
                    noteSpeed = prefs.get("Scroll Speed");
        }

        notes = new NoteGroup();

        if(prefs.get("Sustain Layering") == "Behind") addSustains();
        add(receptors = new FlxTypedSpriteGroup<Receptor>());
        if(prefs.get("Sustain Layering") == "Above") addSustains();
        add(noteGroup = new NoteGroup());
        add(noteSplashes = new FlxTypedSpriteGroup<NoteSplash>());

        input = new NoteInput(this);
        
        this.skin = skin;
        this.keyAmount = keyAmount;
    }

    function addSustains() {
        add(sustainGroup = new NoteGroup());
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var fakeCrochet:Float = (60 / PlayState.SONG.bpm) * 1000;
        
        notes.forEach(function(note:Note) {
            // Stop the function if the note has an invalid direction.
            if(note.direction < 0) return;

            note.x = receptors.members[note.direction].x;
            note.y = receptors.members[note.direction].y + ((PlayerSettings.prefs.get("Downscroll") ? 0.45 : -0.45) * (Conductor.position - note.strumTime) * (noteSpeed / FlxG.sound.music.pitch));
            
            // sustain positioning copy pasted from psych
            // why psych? well before i copied from kade and that worked
            // but sometimes it still broke, but psych has it perfect so uhhhhhh fhwkje
            // just realized this looks a bit weird on EK
            // i need help with that
            if(PlayerSettings.prefs.get("Downscroll") && noteSpeed == Math.abs(noteSpeed) && note.isSustainNote) {
                var adjustedSpeed:Float = noteSpeed / FlxG.sound.music.pitch;
                if (note.isSustainTail) {
                    note.y += 10.5 * (fakeCrochet / 400) * 1.5 * adjustedSpeed + (46 * (adjustedSpeed - 1));
                    note.y -= (46 * (1 - (fakeCrochet / 600)) * adjustedSpeed) * Note.keyInfo[keyAmount].scale;
                    if(note.skinJSON.isPixel)
                        note.y += 8 + (6 - note.ogHeight) * 6;
                }
                note.y += ((Note.spacing) / 2) - (60.5 * (adjustedSpeed - 1));
                note.y += 27.5 * ((PlayState.SONG.bpm / 100) - 1) * (adjustedSpeed - 1);
            }

            // Clip rect bull shit
            if (note.isSustainNote) {
                if (PlayerSettings.prefs.get("Downscroll") && noteSpeed == Math.abs(noteSpeed)) {
                    if ((!note.mustPress || (note.mustPress && !note.tooLate && (input.pressed[note.direction] || PlayerSettings.prefs.get("Botplay"))))
                        && note.y - note.offset.y * note.scale.y + note.height >= (this.y + Note.spacing / 2))
                    {
                        // Clip to strumline
                        var swagRect = new FlxRect(0, 0, note.frameWidth * 2, note.frameHeight * 2);
                        swagRect.height = (receptors.members[note.direction].y + Note.spacing / 2 - note.y) / note.scale.y;
                        swagRect.y = note.frameHeight - swagRect.height;

                        note.clipRect = swagRect;
                    }
                } else {
                    if (!note.mustPress || ((note.mustPress && !note.tooLate && (input.pressed[note.direction] || PlayerSettings.prefs.get("Botplay"))))
                        && note.y + note.offset.y * note.scale.y <= (this.y + Note.spacing / 2))
                    {
                        // Clip to strumline
                        var swagRect = new FlxRect(0, 0, note.width / note.scale.x, note.height / note.scale.y);
                        swagRect.y = (receptors.members[note.direction].y + Note.spacing / 2 - note.y) / note.scale.y;
                        swagRect.height -= swagRect.y;

                        note.clipRect = swagRect;
                    }
                }
            }
            
            if(!note.mustPress) {
                if(note.strumTime <= Conductor.position && !note.wasGoodHit) {
                    var funcName:String = (PlayerSettings.prefs.get("Play As Opponent") && !PlayState.isStoryMode) ? "onPlayerHit" : "onOpponentHit";
                    var eventGlobal = PlayState.current.scripts.event(funcName, new NoteHitEvent(note, Ranking.judgements[0].name));
                    var event = PlayState.current.noteScriptMap[note.type].event("onOpponentHit", new NoteHitEvent(note, Ranking.judgements[0].name));
                    var eventCock = PlayState.current.scripts.event("onNoteHit", new NoteHitEvent(note, Ranking.judgements[0].name));

                    if(!eventGlobal.cancelled && !event.cancelled && !eventCock.cancelled) {
                        PlayState.current.vocals.volume = 1;
                        if(note.doSingAnim) {
                            var chars:Array<Character> = (PlayerSettings.prefs.get("Play As Opponent") && !PlayState.isStoryMode) ? PlayState.current.bfs : PlayState.current.dads;
                            for(c in chars) {
                                if(c != null && !c.specialAnim) {
                                    c.holdTimer = 0;
                                    var suffix:String = note.altAnim ? "-alt" : "";
                                    var anim:String = c.getSingAnim(keyAmount, note.direction)+suffix;
                                    if(!c.animation.exists(anim)) anim = c.getSingAnim(keyAmount, note.direction);
                                    c.playAnim(anim, true);
                                }
                            }
                        }
                        note.wasGoodHit = true;
                        var receptor:Receptor = receptors.members[note.direction];
                        var rgb = PlayerSettings.prefs.get('NOTE_COLORS_$keyAmount')[note.direction];
                        receptor.colorShader.setColors(rgb[0], rgb[1], rgb[2]);
                        receptor.animation.finishCallback = function(name:String) {
                            if(name == "confirm") {
                                receptor.colorShader.setColors(255, 0, 0);
                                receptor.playAnim("static");
                            }
                        }
                        receptor.playAnim("confirm", true);
                        if(!note.isSustainNote) {
                            note.kill();
                            notes.remove(note, true);
                            note.destroy();
                        }
                    } else note.wasGoodHit = true;
                }

                if(note.strumTime <= Conductor.position && note.wasGoodHit) {
                    deleteLateNote(note);
                }
            } else {
                if(PlayerSettings.prefs.get("Botplay") && !note.isSustainNote && note.shouldHit && note.strumTime <= Conductor.position && !note.wasGoodHit)
                    input.goodNoteHit(note);

                if(note.isSustainNote && (input.pressed[note.direction] || (PlayerSettings.prefs.get("Botplay") && note.shouldHit)) && note.strumTime <= Conductor.position && !note.wasGoodHit && !note.tooLate) {
                    var funcName:String = !(PlayerSettings.prefs.get("Play As Opponent") && !PlayState.isStoryMode) ? "onPlayerHit" : "onOpponentHit";
                    var eventGlobal = PlayState.current.scripts.event(funcName, new NoteHitEvent(note, Ranking.judgeNote(note.strumTime)));
                    var event = PlayState.current.noteScriptMap[note.type].event("onPlayerHit", new NoteHitEvent(note, Ranking.judgeNote(note.strumTime)));
                    var eventCock = PlayState.current.scripts.event("onNoteHit", new NoteHitEvent(note, Ranking.judgements[0].name));

                    if(!event.cancelled && !eventGlobal.cancelled && !eventCock.cancelled) {
                        PlayState.current.health += PlayState.current.healthGain;
                        if(PlayState.current.health > PlayState.current.maxHealth)
                            PlayState.current.health = PlayState.current.maxHealth;
                        note.wasGoodHit = true;
                        PlayState.current.vocals.volume = 1;
                        if(note.doSingAnim) {
                            var chars:Array<Character> = (PlayerSettings.prefs.get("Play As Opponent") && !PlayState.isStoryMode) ? PlayState.current.dads : PlayState.current.bfs;
                            for(c in chars) {
                                if(c != null && !c.specialAnim) {
                                    c.holdTimer = 0;
                                    var suffix:String = note.altAnim ? "-alt" : "";
                                    var anim:String = c.getSingAnim(keyAmount, note.direction)+suffix;
                                    if(!c.animation.exists(anim)) anim = c.getSingAnim(keyAmount, note.direction);
                                    c.playAnim(anim, true);
                                }
                            }
                        }
                        var receptor:Receptor = receptors.members[note.direction];
                        var rgb = PlayerSettings.prefs.get('NOTE_COLORS_$keyAmount')[note.direction];
                        receptor.colorShader.setColors(rgb[0], rgb[1], rgb[2]);
                        receptor.playAnim("confirm", true);
                    }
                }
                deleteLateNote(note);
            }
        });
    }

    function deleteLateNote(note:Note) {
        var game = PlayState.current;
        if (note.strumTime < Conductor.position - 244) {
            if(note.mustPress && !note.wasGoodHit) {
                var event = game.scripts.event("onPlayerMiss", new SimpleNoteEvent(note));
                if(note.shouldHit && !PlayerSettings.prefs.get("Botplay")) {
                    if(!note.isSustainTail) {
                        PlayState.current.vocals.volume = 0;
                        if(note.doSingAnim) {
                            var chars:Array<Character> = (PlayerSettings.prefs.get("Play As Opponent") && !PlayState.isStoryMode) ? PlayState.current.dads : PlayState.current.bfs;
                            for(c in chars) {
                                if(c != null && !c.specialAnim) {
                                    c.holdTimer = 0;
                                    c.playAnim(c.getSingAnim(keyAmount, note.direction)+"miss", true);
                                }
                            }
                        }
                    }
                    noteMissShit(note);

                    if(note.sustainPieces.length > 0) {
                        for(piece in note.sustainPieces)
                            piece.tooLate = true;
                    }
                }
                if(event.cancelled) return;
            }

            if(!note.mustPress)
                game.scripts.event("onOpponentMiss", new SimpleNoteEvent(note));

            note.kill();
            notes.remove(note, true);
            note.destroy();
        }
    }

    function noteMissShit(note:Note) {
        var game = PlayState.current;
        if(!note.isSustainTail) {
            game.health -= game.healthLoss;
            if(game.health < game.minHealth) game.health = game.minHealth;
        }

        if(!note.isSustainNote) {
            game.combo = 0;
            game.misses++;
            if(PlayerSettings.prefs.get("Miss Sounds"))
                FlxG.sound.play(Assets.load(SOUND, Paths.sound('game/missnote${FlxG.random.int(1,3)}')), FlxG.random.float(0.1,0.2));
        }
        else game.sustainMisses++;

        game.UI.updateScoreText();
    }

    override public function destroy() {
        input.destroy();
        super.destroy();
    }
}

class Receptor extends FNFSprite {
    public var noteScale:Float = 0.7;

    // DON'T USE THIS!! USE THE SKIN VARIABLE!!!
    @:dox(hide) var skinJSON:NoteSkin;

    public var keyAmount:Int = 4;

    public var skin(default, set):String;
    public var directionName:String = "left";
    public var direction(default, set):Int = 0;

    public var colorShader:ColorShader = new ColorShader(255, 0, 0);

    function set_direction(v:Int):Int {
        directionName = Note.keyInfo[keyAmount].directions[v];
		return direction = v;
	}

    function set_skin(v:String) {
        switch(v) {
            default:
                skinJSON = Note.skinJSONs[v];

                // Crash prevention?!?! Psych take notes
                if(skinJSON == null) skinJSON = Note.skinJSONs["Arrows"];

                noteScale = skinJSON.strumScale * Note.keyInfo[keyAmount].scale;
                this.load(SPARROW, Paths.image(skinJSON.strumTextures));
                animation.addByPrefix("static", directionName+" static0", skinJSON.staticFrameRate);
                animation.addByPrefix("press", directionName+" press0", skinJSON.pressedFrameRate, false);
                animation.addByPrefix("confirm", directionName+" confirm0", skinJSON.confirmFrameRate, false);
                scale.set(noteScale, noteScale);
                updateHitbox();
                playAnim("static");

                antialiasing = skinJSON.isPixel ? false : PlayerSettings.prefs.get("Antialiasing");

                shader = skinJSON.noteColorsAllowed ? colorShader : null;
        }
        return skin = v;
    }

    public function new(x:Float = 0, y:Float = 0, keyAmount:Int, direction:Int, ?skin:String = "Arrows") {
        super(x, y);
        this.keyAmount = keyAmount;
        this.direction = direction;
        this.skin = skin;
    }

    override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
        super.playAnim(name, force, reversed, frame);

        centerOrigin();
        if (!skinJSON.isPixel) {
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;

			offset.x -= 156 * (noteScale / 2);
			offset.y -= 156 * (noteScale / 2);
		} else centerOffsets();
    }
}
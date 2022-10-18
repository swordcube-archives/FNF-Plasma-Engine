package funkin.gameplay;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.Ranking.Judgement;
import misc.Keybinds;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;
import openfl.utils.Function;
import scenes.PlayState;

using StringTools;

class StrumLine extends FlxTypedSpriteGroup<StrumNote> {
    public var missSounds:Map<String, Sound> = [
		"miss1" => Assets.get(SOUND, Paths.sound("missnote1")),
		"miss2" => Assets.get(SOUND, Paths.sound("missnote2")),
		"miss3" => Assets.get(SOUND, Paths.sound("missnote3")),
	];
    
    /**
        Changes how fast any notes for this strum line are.
    **/
    public var noteSpeed:Float = Settings.get("Scroll Speed") > 0 ? Settings.get("Scroll Speed") : PlayState.SONG.speed;

    /**
        Changes if notes get hit automatically or if notes in this strum line have to be hit by you.
    **/
    public var isOpponent(default, set):Bool = true;

	function set_isOpponent(v:Bool):Bool {
        if(PlayState.current != null) {
            if(v) {
                FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
                FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
            } else {
                FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
                FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
            }
        }
		return isOpponent = v;
	}

    public function getSingDirection(data:Int) {
        var direction:String = Note.noteDirections[keyAmount-1][data];
        return "sing"+(direction == "space" ? "up" : direction).toUpperCase();
    }

    public var initialized:Bool = false;

    /**
        The amounts of arrows this `StrumLine` has.

        Automatically regenerates this `StrumLine` when changed.
    **/
    public var keyAmount(default, set):Int;

	function set_keyAmount(v:Int):Int {
        keyAmount = v;
        if(!initialized)
            initialized = true;
        else
            generateStrums();
		return keyAmount = v;
	}

    /**
        The group of notes that get displayed on screen.
    **/
    public var notes:FlxTypedGroup<Note> = new FlxTypedGroup<Note>();

    // /**
    //     The group of note splashes that get displayed on screen.
    // **/
    // public var noteSplashes:FlxTypedSpriteGroup<NoteSplash> = new FlxTypedSpriteGroup<NoteSplash>();

    public function new(x:Float, y:Float, keyAmount:Int, isOpponent:Bool = true) {
        super(x, y);
        this.keyAmount = keyAmount;
        this.isOpponent = isOpponent;

        if(!isOpponent && PlayState.current != null) {
            FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
            FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
        }
    }

    public var pressed:Array<Bool> = [];

    // I basically copy pasted this from kade
    // i don't know how openfl keyboard events work
    
    public function handleInput(evt:KeyboardEvent) {
        // Don't do input while paused or when the player is stunned
        if(PlayState.paused) return;
        if((PlayState.current != null && PlayState.current.bf != null && PlayState.current.bf.stunned)) return;
        
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);
		var binds:Array<String> = Keybinds.binds[keyAmount];
		var data = -1;

		switch (evt.keyCode) { // arrow keys
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) { // binds 
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
			return;
		if (pressed[data])
			return;

        pressed[data] = true;

        if(members[data] != null) {
            members[data].playAnim("press");
            members[data].colorShader.enabled.value = [true];
            members[data].setColors();
        }

		var closestNotes = [];

		notes.forEachAlive(function(daNote:Note) {
			if (Conductor.position - daNote.strumTime >= -Conductor.safeZoneOffset*1.5)
				closestNotes.push(daNote);
		}); // Collect notes that can be hit

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data && !i.isSustain)
				dataNotes.push(i);

		if (dataNotes.length != 0){
			var coolNote = null;
			for (i in dataNotes) {
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1) { // stacked notes or really close ones
				for (i in 0...dataNotes.length) {
					if (i == 0) continue; // skip the first note

					var note = dataNotes[i];
                    // remove that damn stacked note >:(((((((( and destroy it too >:(((((((((
					if (!note.isSustain && ((note.strumTime - coolNote.strumTime) < 5) && note.noteData == data) {
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
		}
    }

    public function releaseInput(evt:KeyboardEvent) {
        // Don't do input while paused
        if(PlayState.paused) return;
        if((PlayState.current != null && PlayState.current.bf != null && PlayState.current.bf.stunned)) return;
        
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);
		var binds:Array<String> = Keybinds.binds[keyAmount];
		var data = -1;

		switch (evt.keyCode) { // arrow keys
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) { // binds
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

        pressed[data] = false;

        if(members[data] != null) {
            members[data].playAnim("static");
            members[data].colorShader.enabled.value = [false];
            members[data].setColors();
        }
    }

    function boundHealth()
		PlayState.current.health = FlxMath.bound(PlayState.current.health, PlayState.current.minHealth, PlayState.current.maxHealth);

    public function goodNoteHit(note:Note) {
		var botPlay:Bool = PlayState.current != null ? PlayState.current.botPlay : false;

        PlayState.current.combo++;
		PlayState.current.totalNotes++;

		var judgement:String = Ranking.judgeNote(note.strumTime);
		var judgeData:Judgement = Ranking.getInfo(botPlay ? "marvelous" : judgement);

        var mult:Float = PlayState.songMultiplier > 1 ? 1 : PlayState.songMultiplier;
        if(!Settings.get("Anti Mash")) mult *= 0.75;
        
		if (!botPlay)
			PlayState.current.songScore += Math.floor(judgeData.score * mult);

		PlayState.current.totalHit += judgeData.mod;
		if (judgement != "bad" && !PlayState.current.customHealth)
			PlayState.current.health += PlayState.current.healthGain;

		if(!PlayState.current.customHealth) {
            if((judgeData.health < 0 && Settings.get("Anti Mash")) || judgeData.health > 0) 
			    PlayState.current.health += judgeData.health;
			boundHealth();
		}

		PlayState.current.calculateAccuracy();

        PlayState.current.vocals.volume = 1;

        for(c in PlayState.current.bfs) {
            if(c != null && !c.specialAnim) {
                c.holdTimer = 0;
                if (note.altAnim && c.animation.exists(getSingDirection(note.noteData) + "-alt"))
                    c.playAnim(getSingDirection(note.noteData) + "-alt", true);
                else
                    c.playAnim(getSingDirection(note.noteData), true);
            }
        }

        PlayState.current.scripts.call("goodNoteHit", [note.noteData, note.strumTime, note.isSustain, judgeData.name, judgeData], true, [note, judgeData.name, judgeData]);
        PlayState.current.scripts.call("playerNoteHit", [note.noteData, note.strumTime, note.isSustain, judgeData.name, judgeData], true, [note, judgeData.name, judgeData]);
        PlayState.current.scripts.call("popUpScore", [judgeData.name, PlayState.current.combo, PlayState.current.ratingScale, PlayState.current.comboScale]);

        members[note.noteData].playAnim("confirm");
        members[note.noteData].colorShader.enabled.value = [true];
        members[note.noteData].setColors();

        PlayState.current.scripts.call("goodNoteHitPost", [note.noteData, note.strumTime, note.isSustain, judgeData.name, judgeData], true, [note, judgeData.name, judgeData]);
        PlayState.current.scripts.call("playerNoteHitPost", [note.noteData, note.strumTime, note.isSustain, judgeData.name, judgeData], true, [note, judgeData.name, judgeData]);
        PlayState.current.scripts.call("popUpScorePost", [judgeData.name, PlayState.current.combo, PlayState.current.ratingScale, PlayState.current.comboScale]);

        PlayState.current.scripts.call("updateScoreText");
        PlayState.current.scripts.call("onUpdateScoreText");
        
        if(!note.preventDeletion) {
            notes.remove(note, true);
            note.destroy();
        }
    }

	public function reloadSkin() {
		var arrowSkin:String = PlayState.current.currentSkin.replace("default", Settings.get("Note Skin").toLowerCase());
		for (bemb in members)
			bemb.loadSkin(arrowSkin);
	}

    public function generateStrums() {
        for(i in cast([this/*, noteSplashes*/], Array<Dynamic>)) {
            i.forEach(function(s) {
                i.remove(s, true);
                s.destroy();
                s = null;
            });
        }

        for(i in 0...keyAmount) {
			var strum:StrumNote = new StrumNote(((Note.swagWidth * Note.noteScales[keyAmount-1]) * Note.noteSpacing[keyAmount-1]) * i, -10, i);
			strum.parent = this;
			strum.alpha = 0;
            var arrowSkin:String = PlayState.current.currentSkin.replace("default", Settings.get("Note Skin").toLowerCase());
			strum.loadSkin(arrowSkin);
			add(strum);

			// var splash:NoteSplash = new NoteSplash(strum.x, 0, Note.noteDirections[keyAmount-1][i], this, strum.json.splash_image_location);
            // splash.framerate = strum.json.splash_framerate;
			// noteSplashes.add(splash);

            if(isOpponent)
                strum.animation.finishCallback = function(name:String) {
                    if(name == "confirm") {
                        strum.playAnim("static");

                        strum.colorShader.enabled.value = [false];
                        strum.setColors();
                    }
                };
            
			FlxTween.tween(
                strum, 
                {y: strum.y + 10, alpha: 1}, 
                0.5, 
                {
                    ease: FlxEase.circOut, 
                    startDelay: i * (0.3 / FlxMath.bound(keyAmount-3, 0, Math.POSITIVE_INFINITY))
                }
            ).start();
        }

        screenCenter(X);
        if(!Settings.get("Centered Notes")) {
            var spacing:Float = FlxG.width / 4;
            x += isOpponent ? -spacing : spacing;
        } else {
            if(isOpponent)
                x -= 9999;
        }
        //noteSplashes.setPosition(x, y);

        pressed = [for(i in 0...keyAmount) false];
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(PlayState.current != null) {
            if(isOpponent) {
                notes.forEachAlive(function(note:Note) {
                    if(Conductor.position - note.strumTime >= 0) {
                        for(c in PlayState.current.dads) {
                            if(c != null) {
                                c.holdTimer = 0;
                                if (note.altAnim && c.animation.exists(getSingDirection(note.noteData) + "-alt"))
                                    c.playAnim(getSingDirection(note.noteData) + "-alt", true);
                                else
                                    c.playAnim(getSingDirection(note.noteData), true);
                            }
                        }
                        PlayState.current.vocals.volume = 1;
                        PlayState.current.scripts.call("enemyNoteHit", [note.noteData, note.strumTime, note.isSustain], true, [note]);
                        PlayState.current.scripts.call("opponentNoteHit", [note.noteData, note.strumTime, note.isSustain], true, [note]);
                        members[note.noteData].playAnim("confirm", true);
                        members[note.noteData].colorShader.enabled.value = [true];
                        members[note.noteData].setColors();
                        PlayState.current.scripts.call("enemyNoteHitPost", [note.noteData, note.strumTime, note.isSustain], true, [note]);
                        PlayState.current.scripts.call("opponentNoteHitPost", [note.noteData, note.strumTime, note.isSustain], true, [note]);
                        if(!note.preventDeletion) {
                            notes.remove(note, true);
                            note.destroy();
                        }
                    }
                });
            } else {
                notes.forEachAlive(function(note:Note) {
                    if(note.isSustain && pressed[note.noteData] && Conductor.position - note.strumTime >= 0) {
                        for(c in PlayState.current.bfs) {
                            if(c != null && !c.specialAnim) {
                                c.holdTimer = 0;
                                if (note.altAnim && c.animation.exists(getSingDirection(note.noteData) + "-alt"))
                                    c.playAnim(getSingDirection(note.noteData) + "-alt", true);
                                else
                                    c.playAnim(getSingDirection(note.noteData), true);
                            }
                        }
                        if(!PlayState.current.customHealth)
			                PlayState.current.health += PlayState.current.healthGain*0.5;
                        PlayState.current.vocals.volume = 1;
                        members[note.noteData].playAnim("confirm", true);
                        members[note.noteData].colorShader.enabled.value = [true];
                        members[note.noteData].setColors();
                        if(!note.preventDeletion) {
                            notes.remove(note, true);
                            note.destroy();
                        }
                    }

                    if(Conductor.position - note.strumTime >= Conductor.safeZoneOffset) {
                        PlayState.current.vocals.volume = 0;
                        PlayState.current.totalNotes++;
                        if(!PlayState.current.customHealth) {
                            PlayState.current.health -= PlayState.current.healthLoss;
                            boundHealth();
                        }
                        var ret:Dynamic = PlayState.current.scripts.call("onNoteMiss", [note.strumTime, note.noteData, note.isSustain], true, [note]);
                        var ret2:Dynamic = PlayState.current.scripts.call("noteMiss", [note.strumTime, note.noteData, note.isSustain], true, [note]);
                        if(!note.isSustain && ret != false && ret2 != false) {
                            if(PlayState.current.combo >= 10)
                                PlayState.current.gf.playAnim("sad");
                            
                            PlayState.current.combo = 0;
                            PlayState.current.songMisses++;
                            
                            if(Settings.get("Miss Sounds"))
                                FlxG.sound.play(missSounds["miss" + FlxG.random.int(1, 3)], FlxG.random.float(0.1, 0.2));
                            
                            for(c in PlayState.current.bfs) {
                                if(c != null && !c.specialAnim) {
                                    c.holdTimer = 0;
                                    if (note.altAnim && c.animation.exists(getSingDirection(note.noteData) + "miss-alt"))
                                        c.playAnim(getSingDirection(note.noteData) + "miss-alt", true);
                                    else
                                        c.playAnim(getSingDirection(note.noteData) + "miss", true);
                                }
                            }
                        }
                        PlayState.current.scripts.call("onNoteMissPost", [note.strumTime, note.noteData, note.isSustain], true, [note]);
                        PlayState.current.scripts.call("noteMissPost", [note.strumTime, note.noteData, note.isSustain], true, [note]);
                        
                        PlayState.current.calculateAccuracy();
                        PlayState.current.scripts.call("updateScoreText");
                        PlayState.current.scripts.call("onUpdateScoreText");

                        if(!note.preventDeletion) {
                            notes.remove(note, true);
                            note.destroy();
                        }
                    }
                });
            }
        }
    }

    override function destroy() {
        if(!isOpponent) {
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
        }
        super.destroy();
    }
}
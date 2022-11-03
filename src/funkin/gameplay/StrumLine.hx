package funkin.gameplay;

import funkin.gameplay.Note.NoteSkin;
import funkin.Ranking.Judgement;
import flixel.text.FlxText;
import flixel.math.FlxRect;
import funkin.states.PlayState;
import shaders.ColorShader;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import openfl.ui.Keyboard;

using StringTools;

class StrumLine extends FlxSpriteGroup {
    /**
     * The amount of strums this `StrumLine` has.
     */
    public var keyCount(default, set):Int;
    public var strums:FlxTypedSpriteGroup<StrumNote>;
    public var notes:FlxTypedSpriteGroup<Note>;

    /**
     * The skin the strums of this `StrumLine` use.
     */
    public var skin(default, set):String;

    public var initialized:Bool = false;

    /**
     * Controls whether or not the notes get hit automatically and control the opponent.
     */
    public var isOpponent:Bool = false;

    /**
     * The speed that the notes go at in gameplay.
     */
    public var noteSpeed:Float = Settings.get("Scroll Speed") > 0 ? Settings.get("Scroll Speed") : PlayState.songData.speed;

    function set_keyCount(v:Int):Int {
        pressed = [for(i in 0...v) false];
        if(initialized) generateStrums(v);
		return keyCount = v;
	}
    function set_skin(v:String):String {
        skin = v;
        if(initialized) generateStrums(keyCount);
		return skin = v;
	}

    public function new(x:Float = 0, y:Float = 0, keyCount:Int = 4, skin:String = "Arrows") {
        super(x, y);
        scrollFactor.set();
        strums = new FlxTypedSpriteGroup<StrumNote>();
        strums.scrollFactor.set();
        add(strums);
        notes = new FlxTypedSpriteGroup<Note>();
        notes.scrollFactor.set();
        add(notes);
        this.keyCount = keyCount;
        initialized = true;
        this.skin = skin;
        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
    }

    public var pressed = [];

    /**
     * The function used for handling when you press a key.
     */
    function handleInput(evt:KeyboardEvent):Void {
        if (isOpponent || PlayState.paused) return;

        @:privateAccess
        var key = FlxKey.toStringMap.get(evt.keyCode);

        var binds:Array<String> = Controls.gameplayList[keyCount];

		var data = -1;
		switch (evt.keyCode) {
			case Keyboard.LEFT:
				data = 0;
			case Keyboard.DOWN:
				data = 1;
			case Keyboard.UP:
				data = 2;
			case Keyboard.RIGHT:
				data = 3;
		}

		for (i in 0...binds.length) {
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
			return;
        if (pressed[data])
			return;

		pressed[data] = true;
        strums.members[data].playAnim("press");
        var rgb:Array<Int> = Note.keyInfo[keyCount].colors[data];
        strums.members[data].colorShader.setColors(rgb[0], rgb[1], rgb[2]);

        var closestNotes:Array<Note> = [];

        notes.forEachAlive(function(note:Note) {
            if(Conductor.position - note.strumTime >= -((Conductor.safeZoneOffset*2)*FlxG.sound.music.pitch))
                closestNotes.push(note);
        });

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for (i in closestNotes)
			if (i.direction == data && !i.isSustain)
				dataNotes.push(i);

		if (dataNotes.length > 0) {
			var coolNote = null;
			for (i in dataNotes) {
				coolNote = i;
				break;
			}

            var event = new funkin.events.NoteHitEvent();
            event.rating = Ranking.judgeNote(coolNote.strumTime);
            event.note = coolNote;
            coolNote.script.call("onPlayerNoteHit", [event]);
            PlayState.current.scripts.call("onPlayerNoteHit", [event]);
            if(!event.cancelled) {
                // stacked notes
                if (dataNotes.length > 1) {
                    for (i in 0...dataNotes.length) {
                        if (i == 0) continue;
                        var note = dataNotes[i];
                        if (!note.isSustain && ((note.strumTime - coolNote.strumTime) < 5) && note.direction == data) {
                            remove(note, true);
                            note.destroy();
                        }
                    }
                }
                playerNoteHit(coolNote);
            }
            strums.members[data].playAnim("confirm");
        }
    }

    function playerNoteHit(note:Note) {
        PlayState.current.combo++;
        popUpScore(note.strumTime, PlayState.current.combo);
        for(c in PlayState.current.bfs) {
            if(c != null && !c.specialAnim) {
                var alt:String = note.altAnim ? "-alt" : "";
                c.holdTimer = 0;
                c.playAnim("sing"+getSingDirection(note.direction)+alt, true);
            }
        }
        PlayState.current.health += PlayState.current.healthGain;
        if(PlayState.current.health > PlayState.current.maxHealth)
            PlayState.current.health = PlayState.current.maxHealth;
        PlayState.current.vocals.volume = 1;
        remove(note, true);
        note.destroy();
    }

    function popUpScore(strumTime:Float, combo:Int) {
        var judgement:String = Ranking.judgeNote(strumTime);
        var judgeData:Judgement = Ranking.getInfo(judgement);
        var placement:String = Std.string(combo);

        PlayState.current.score += Math.floor(judgeData.score * (Conductor.rate < 1 ? Conductor.rate : 1));
        PlayState.current.health += judgeData.health;

        PlayState.current.totalNotes++;
        PlayState.current.totalHit += judgeData.mod;
        PlayState.current.UI.updateScoreText();

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

        var rating:Sprite = new Sprite(0, 0);
        var size:Array<Int> = PlayState.current.judgementProperties.ratingSize;
        rating.loadGraphic(Assets.load(IMAGE, Paths.image(PlayState.current.judgementProperties.ratingPath)), true, size[0], size[1]);
        rating.antialiasing = PlayState.current.judgementProperties.ratingAntialiasing ? Settings.get("Antialiasing") : false;
        rating.animation.add("marvelous", [0], 0);
        rating.animation.add("sick", [1], 0);
        rating.animation.add("good", [2], 0);
        rating.animation.add("bad", [3], 0);
        rating.animation.add("shit", [4], 0);
        rating.animation.play(judgement);
        rating.screenCenter();
        rating.x = coolText.x - 40;
        rating.y -= 60;
        
        var mmm:Float = PlayState.current.judgementProperties.ratingScale;
        rating.scale.set(mmm,mmm);
        rating.updateHitbox();

        rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
        PlayState.current.insert(PlayState.current.members.length-1, rating);

        var seperatedScore:Array<String> = placement.split("");
        while(seperatedScore.length < 3) seperatedScore.insert(0, "0");
		var daLoop:Int = 0;
		for (i in seperatedScore) {
			var numScore:Sprite = new Sprite();
            var size:Array<Int> = PlayState.current.judgementProperties.comboSize;
            numScore.loadGraphic(Assets.load(IMAGE, Paths.image(PlayState.current.judgementProperties.comboPath)), true, size[0], size[1]);
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;
            numScore.antialiasing = PlayState.current.judgementProperties.comboAntialiasing ? Settings.get("Antialiasing") : false;
            numScore.animation.add("normal", [0,1,2,3,4,5,6,7,8,9], 0);
            numScore.animation.add("marvelous", [10,11,12,13,14,15,16,17,18,19], 0);
            numScore.animation.play(judgement == "marvelous" ? "marvelous" : "normal");
            numScore.animation.curAnim.curFrame = Std.parseInt(i);

            var mmm:Float = PlayState.current.judgementProperties.comboScale;
            numScore.scale.set(mmm,mmm);
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			PlayState.current.insert(PlayState.current.members.length-1, numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});
			daLoop++;
		}
        
		FlxTween.tween(rating, {alpha: 0}, 0.2, {
            onComplete: function(twn:FlxTween) {
                rating.destroy();
            },
            startDelay: Conductor.crochet * 0.001
		});
    }

    /**
     * The function used for handling when you release a key.
     */
    function releaseInput(evt:KeyboardEvent):Void {
        if (isOpponent || PlayState.paused) return;

        @:privateAccess
        var key = FlxKey.toStringMap.get(evt.keyCode);

        var binds:Array<String> = Controls.gameplayList[keyCount];

		var data = -1;
		switch (evt.keyCode) {
			case Keyboard.LEFT:
				data = 0;
			case Keyboard.DOWN:
				data = 1;
			case Keyboard.UP:
				data = 2;
			case Keyboard.RIGHT:
				data = 3;
		}

		for (i in 0...binds.length) {
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
			return;

		pressed[data] = false;
        strums.members[data].playAnim("static");
        strums.members[data].colorShader.setColors(255, 0, 0);
    }

    function getSingDirection(direction:Int = 0) {
        var direction:String = Note.keyInfo[keyCount].directions[direction];
        switch(direction) {
            case "space":
                direction = "up";
        }
        return direction.toUpperCase();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        notes.forEachAlive(function(note:Note) {
            note.x = strums.members[note.direction].x;
            note.y = strums.members[note.direction].y + ((Settings.get("Downscroll") ? 0.45 : -0.45) * (Conductor.position - note.strumTime) * (noteSpeed/FlxG.sound.music.pitch)) - (Settings.get("Downscroll") ? note.noteYOff : -note.noteYOff);
            if(note.isSustain) {
                var stepHeight = (0.45 * note.stepCrochet * (noteSpeed/FlxG.sound.music.pitch));
                if(Settings.get("Downscroll")) {
                    note.y -= note.height - stepHeight;
                    if ((isOpponent || (!isOpponent && pressed[note.direction])) && note.y - note.offset.y * note.scale.y + note.height >= (y + Note.spacing / 2)) {
                        // Clip to strumline
                        var swagRect = new FlxRect(0, 0, note.frameWidth * 2, note.frameHeight * 2);
                        swagRect.height = (strums.members[note.direction].y + Note.spacing / 2 - note.y) / note.scale.y;
                        swagRect.y = note.frameHeight - swagRect.height;

                        note.clipRect = swagRect;
                    }
                } else {
                    note.y += 5;
                    if ((isOpponent || (!isOpponent && pressed[note.direction])) && note.y + note.offset.y * note.scale.y <= (y + Note.spacing / 2)) {
                        // Clip to strumline
                        var swagRect = new FlxRect(0, 0, note.width / note.scale.x, note.height / note.scale.y);
                        swagRect.y = (strums.members[note.direction].y + Note.spacing / 2 - note.y) / note.scale.y;
                        swagRect.height -= swagRect.y;

                        note.clipRect = swagRect;
                    }
                }
            }
            if(isOpponent) {
                if(Conductor.position - note.strumTime >= 0) {
                    for(c in PlayState.current.dads) {
                        if(c != null && !c.specialAnim) {
                            var alt:String = note.altAnim ? "-alt" : "";
                            c.holdTimer = 0;
                            c.playAnim("sing"+getSingDirection(note.direction)+alt, true);
                        }
                    }
                    PlayState.current.vocals.volume = 1;
                    remove(note, true);
                    note.destroy();
                }
            } else {
                if(Conductor.position - note.strumTime >= 0 && note.isSustain && pressed[note.direction]) {
                    for(c in PlayState.current.bfs) {
                        if(c != null && !c.specialAnim) {
                            var alt:String = note.altAnim ? "-alt" : "";
                            c.holdTimer = 0;
                            c.playAnim("sing"+getSingDirection(note.direction)+alt, true);
                        }
                    }
                    // you get half the health because fuck you i guess, lmao!
                    PlayState.current.health += PlayState.current.healthGain*0.5;
                    if(PlayState.current.health > PlayState.current.maxHealth)
                        PlayState.current.health = PlayState.current.maxHealth;
                    strums.members[note.direction].playAnim("confirm", true);
                    var event = new funkin.events.NoteHitEvent();
                    event.note = note;
                    note.script.call("onPlayerNoteHit", [event]);
                    PlayState.current.scripts.call("onPlayerNoteHit", [event]);
                    if(!event.cancelled) {
                        PlayState.current.vocals.volume = 1;
                        var rgb:Array<Int> = Note.keyInfo[keyCount].colors[note.direction];
                        strums.members[note.direction].colorShader.setColors(rgb[0], rgb[1], rgb[2]);
                        remove(note, true);
                        note.destroy();
                    }
                }
                if(Conductor.position - note.strumTime >= Conductor.safeZoneOffset*FlxG.sound.music.pitch) {
                    PlayState.current.combo = 0;
                    PlayState.current.misses++;
                    PlayState.current.UI.updateScoreText();
                    for(c in PlayState.current.bfs) {
                        if(c != null && !c.specialAnim) {
                            c.holdTimer = 0;
                            c.playAnim("sing"+getSingDirection(note.direction)+"miss", true);
                        }
                    }
                    PlayState.current.health -= PlayState.current.healthLoss;
                    if(PlayState.current.health < PlayState.current.minHealth)
                        PlayState.current.health = PlayState.current.minHealth;
                    PlayState.current.vocals.volume = 0;
                    remove(note, true);
                    note.destroy();
                }
            }
        });
    }

    /**
     * Regenerates the strum notes.
     * @param keyCount 
     */
    public function generateStrums(keyCount:Int) {
        pressed = [for(i in 0...keyCount) false];
        for(s in strums.members) {
            strums.remove(s, true);
            s.destroy();
        }
        for(i in 0...keyCount) {
            var noteSkin:String = PlayState.current.currentSkin.replace("Default", Settings.get("Note Skin"));
            var keySpacing:Float = Note.keyInfo[keyCount].spacing;
            var strum:StrumNote = new StrumNote(Note.spacing * (keySpacing * i), -10, this, i, noteSkin);
            strum.alpha = 0.001;
            FlxTween.tween(strum, {alpha: 1, y: y+10}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
            strums.add(strum);
        }
    }

    override function destroy() {
        FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
        FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
        super.destroy();
    }
}

class StrumNote extends Sprite {
    public var direction:Int = 0;
    public var parent:StrumLine;
    /**
     * The skin used for this strum note.
     */
    public var skin(default, set):String;
    @:noCompletion public var skinData:NoteSkin; // DON'T USE!!! USE THE SKIN VAR!!
    public var strumScale:Float = 0.7;

    public var colorShader:ColorShader = new ColorShader(255, 0, 0);

    function set_skin(v:String):String {
        skin = v;
        reloadSkin();
		return skin = v;
	}

    public function reloadSkin() {
        // switch case if you wanna hardcode for some reason
        // ..lmao!
        switch(skin) {
            default:
                skinData = Note.skinJSONs[skin];
                frames = Assets.load(SPARROW, Paths.image(skinData.strumTexturePath));
                var dir:String = Note.keyInfo[parent.keyCount].directions[direction];
                addAnim("static", dir+" static0");
                addAnim("press", dir+" press0");
                addAnim("confirm", dir+" confirm0");
                strumScale = skinData.noteScale * Note.keyInfo[parent.keyCount].scale;
                scale.set(strumScale, strumScale);
                updateHitbox();
                playAnim("static");
        }
    }

    public function new(x:Float = 0, y:Float = 0, parent:StrumLine, direction:Int = 0, skin:String = "Arrows") {
        super(x, y);
        this.direction = direction;
        this.parent = parent;
        this.skin = skin;
        shader = colorShader;
    }

    override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
        super.playAnim(name, force, reversed, frame);

		centerOrigin();

		if (skin != "pixel") {
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;

			offset.x -= 156 * (strumScale / 2);
			offset.y -= 156 * (strumScale / 2);
		} else
			centerOffsets();
    }
}
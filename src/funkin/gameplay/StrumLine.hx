package funkin.gameplay;

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

    var pressed = [];

    /**
     * The function used for handling when you press a key.
     */
    function handleInput(evt:KeyboardEvent):Void {
        if (isOpponent) return;

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
            if(Conductor.position - note.strumTime >= -Conductor.safeZoneOffset*1.5)
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
            remove(coolNote, true);
            coolNote.destroy();
            strums.members[data].playAnim("confirm");
        }
    }

    /**
     * The function used for handling when you release a key.
     */
    function releaseInput(evt:KeyboardEvent):Void {
        if (isOpponent) return;

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

    override function update(elapsed:Float) {
        super.update(elapsed);
        notes.forEachAlive(function(note:Note) {
            note.x = strums.members[note.direction].x;
            note.y = strums.members[note.direction].y + (0.45 * (Conductor.position - note.strumTime) * (noteSpeed/PlayState.current.songSpeed));
            if(isOpponent) {
                if(Conductor.position - note.strumTime >= 0) {
                    remove(note, true);
                    note.destroy();
                }
            } else {
                if(Conductor.position - note.strumTime >= 0 && note.isSustain && pressed[note.direction]) {
                    strums.members[note.direction].playAnim("confirm", true);
                    var rgb:Array<Int> = Note.keyInfo[keyCount].colors[note.direction];
                    strums.members[note.direction].colorShader.setColors(rgb[0], rgb[1], rgb[2]);
                    remove(note, true);
                    note.destroy();
                }
                if(Conductor.position - note.strumTime >= Conductor.safeZoneOffset) {
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
    public var skin(default, set):String;
    public var strumScale:Float = 0.7;

    public var colorShader:ColorShader = new ColorShader(255, 0, 0);

    function set_skin(v:String):String {
        skin = v;
        reloadSkin();
		return skin = v;
	}

    public function reloadSkin() {
        switch(skin) {
            case "Arrows":
                frames = Assets.load(SPARROW, Paths.image("ui/notes/NOTE_assets"));
                var dir:String = Note.keyInfo[parent.keyCount].directions[direction];
                addAnim("static", dir+" static0");
                addAnim("press", dir+" press0");
                addAnim("confirm", dir+" confirm0");
                strumScale = 0.7 * Note.keyInfo[parent.keyCount].scale;
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
package funkin.gameplay;

import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import openfl.ui.Keyboard;

class StrumLine extends FlxSpriteGroup {
    /**
     * The amount of strums this `StrumLine` has.
     */
    public var keyCount(default, set):Int;
    public var strums:FlxTypedSpriteGroup<StrumNote>;
    /**
     * The skin the strums of this `StrumLine` use.
     */
    public var skin(default, set):String;

    public var initialized:Bool = false;

    /**
     * Controls whether or not the notes get hit automatically and control the opponent.
     */
    public var isOpponent:Bool = true;

    function set_keyCount(v:Int):Int {
        pressed = [for(i in 0...v) false];
        if(initialized) generateStrums(v);
		return keyCount = v;
	}
    function set_skin(v:String):String {
        if(initialized) generateStrums(keyCount);
		return skin = v;
	}

    public function new(x:Float = 0, y:Float = 0, keyCount:Int = 4, skin:String = "default") {
        super(x, y);
        scrollFactor.set();
        strums = new FlxTypedSpriteGroup<StrumNote>();
        strums.scrollFactor.set();
        add(strums);
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
		if (data == -1 || pressed[data])
			return;


		pressed[data] = true;
    }

    /**
     * The function used for handling when you release a key.
     */
    function releaseInput(evt:KeyboardEvent):Void {
        if (isOpponent) return;

        @:privateAccess
        var key = FlxKey.toStringMap.get(evt.keyCode);

        var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;
		switch (evt.keyCode) {
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) {
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
			return;

		pressed[data] = false;
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
            var keySpacing:Float = Note.keyInfo[keyCount].spacing;
            var strum:StrumNote = new StrumNote(Note.spacing * (keySpacing * i), -10, this, i, "default");
            strum.alpha = 0.001;
            FlxTween.tween(strum, {alpha: 1, y: y+10}, 0.5, {ease: FlxEase.circOut, startDelay: 0.3 * i});
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
    public var skin(default, set):String = "";
    public var strumScale:Float = 0.7;

    function set_skin(v:String):String {
        switch(v) {
            case "default":
                frames = Assets.load(SPARROW, Paths.image("ui/notes/NOTE_assets"));
                var dir:String = Note.keyInfo[parent.keyCount].directions[direction];
                addAnim("static", dir+" static");
                addAnim("press", dir+" press");
                addAnim("confirm", dir+" confirm");
                strumScale = 0.7 * Note.keyInfo[parent.keyCount].scale;
                scale.set(strumScale, strumScale);
                updateHitbox();
                playAnim("static");
        }
		return skin = v;
	}

    public function new(x:Float = 0, y:Float = 0, parent:StrumLine, direction:Int = 0, skin:String = "default") {
        super(x, y);
        this.direction = direction;
        this.parent = parent;
        this.skin = skin;
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
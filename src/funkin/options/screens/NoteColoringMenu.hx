package funkin.options.screens;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxSprite;
import funkin.substates.FNFSubState;
import funkin.ui.ColorPicker;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.scripting.Script;
import funkin.game.Note;

class NoteColoringMenu extends FNFSubState {
    public var notes:FlxTypedSpriteGroup<Note>;
    public var colorPicker:ColorPicker;

    public var noteColors:Array<Array<Int>> = [];
    public var keyAmount:Int = 4;

    public var selected:Int = 0;

    public var bg:FlxSprite;
    public var script:ScriptModule;

    public var selectedText:FlxText;
    
    override function create() {
        var balls:Array<Array<Int>> = cast PlayerSettings.prefs.get('NOTE_COLORS_$keyAmount');
        noteColors = balls.copy();
        script = Script.load(Paths.script('data/substates/options/NoteColoringMenu'));
		script.setParent(this);
		script.run();

        super.create();

        FlxG.state.persistentUpdate = false;
        FlxG.state.persistentDraw = true;

        persistentUpdate = persistentDraw = false;
        
		bg = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image('menus/menuBGDesat')));
        bg.color = 0xFFea71fd;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
        bg.scrollFactor.set();
		add(bg);

        add(notes = new FlxTypedSpriteGroup<Note>());
        for(i in 0...keyAmount) {
            var note:Note = new Note(0, keyAmount, i);
            note.setPosition(((Note.spacing * Note.keyInfo[keyAmount].scale) * i) * Note.keyInfo[keyAmount].spacing, 70);
            notes.add(note);

            var coolScale:Float = note.noteScale;
            if (selected == i)
                note.scale.set(coolScale,coolScale);
            else
                note.scale.set(coolScale * 0.9, coolScale * 0.9);
        }
        notes.scrollFactor.set();
        notes.screenCenter(X);
        colorPicker = new ColorPicker(
            FlxG.width/2-175, 300,
            350, 200,
            function() {
                noteColors = Note.keyInfo[keyAmount].colors.copy();
                for(i in 0...keyAmount)
                    notes.members[i].colorShader.setColors(noteColors[i][0], noteColors[i][1], noteColors[i][2]);
                
                colorPicker.setColor({
                    'r': noteColors[selected][0],
                    'g': noteColors[selected][1],
                    'b': noteColors[selected][2]
                }, false);
                prefs.set('NOTE_COLORS_$keyAmount', noteColors);
                prefs.flush();
            }
        );
        colorPicker.onChange = function(h,s,b) {
            var thecolor = FlxColor.fromHSB(h,s,b);
            notes.members[selected].colorShader.setColors(
                (thecolor >> 16) & 0xff,
                (thecolor >> 8) & 0xff,
                thecolor & 0xff
            );
            noteColors[selected] = [
                (thecolor >> 16) & 0xff,
                (thecolor >> 8) & 0xff,
                thecolor & 0xff
            ];
        }
        colorPicker.setColor({
            'r': noteColors[selected][0],
            'g': noteColors[selected][1],
            'b': noteColors[selected][2]
        }, false);
        colorPicker.scrollFactor.set();
        add(colorPicker);

        selectedText = new FlxText(0,FlxG.height - 90,0,'< $keyAmount >');
        selectedText.size = 32;
        selectedText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        selectedText.scrollFactor.set();
        selectedText.antialiasing = prefs.get("Antialiasing");
        selectedText.screenCenter(X);
        add(selectedText);

        script.createPostCall();
    }

    public function goBack() {
        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
        close();
    }

    override function update(elapsed:Float) {
        script.updateCall(elapsed);
        super.update(elapsed);

        FlxG.mouse.visible = true;

        if(controls.getP("BACK")) {
            FlxG.mouse.visible = false;
            prefs.set('NOTE_COLORS_$keyAmount', noteColors);
            prefs.flush();
            goBack();
        }
        if(controls.getP("UI_LEFT")) changeKeyAmount(-1);
        if(controls.getP("UI_RIGHT")) changeKeyAmount(1);

        if(FlxG.mouse.justPressed) {
            for (i in 0...notes.members.length) {
                if (FlxG.mouse.overlaps(notes.members[i])) {
                    selected = i;
                    colorPicker.setColor({
                        'r': noteColors[selected][0],
                        'g': noteColors[selected][1],
                        'b': noteColors[selected][2]
                    }, false);
                }
            }
            for (i in 0...notes.members.length) {
                var coolScale:Float = notes.members[i].noteScale;
                if (selected == i)
                    notes.members[i].scale.set(coolScale,coolScale);
                else
                    notes.members[i].scale.set(coolScale * 0.9, coolScale * 0.9);
            }
        }

        script.updatePostCall(elapsed);
    }

    function changeKeyAmount(change:Int = 0) {
        // Save the colors for the current key amount
        prefs.set('NOTE_COLORS_$keyAmount', noteColors);
        prefs.flush();

        // Change the key amount
        keyAmount = Std.int(FlxMath.wrap(keyAmount + change, 1, Lambda.count(Note.keyInfo)));
        selected = 0;

        // Reset the colors
        var balls:Array<Array<Int>> = cast PlayerSettings.prefs.get('NOTE_COLORS_$keyAmount');
        noteColors = balls.copy();

        // Remove previously displayed notes
        for(note in notes.members) {
            note.kill();
            note.destroy();
            notes.remove(note, true);
        }
        notes.clear();

        // Display the notes for the current key count
        for(i in 0...keyAmount) {
            var note:Note = new Note(0, keyAmount, i);
            note.setPosition(((Note.spacing * Note.keyInfo[keyAmount].scale) * i) * Note.keyInfo[keyAmount].spacing, 70);
            notes.add(note);

            var coolScale:Float = note.noteScale;
            if (selected == i)
                note.scale.set(coolScale,coolScale);
            else
                note.scale.set(coolScale * 0.9, coolScale * 0.9);
        }
        notes.screenCenter(X);

        // Set the color picker's color
        colorPicker.setColor({
            'r': noteColors[selected][0],
            'g': noteColors[selected][1],
            'b': noteColors[selected][2]
        }, false);

        selectedText.text = '< $keyAmount >';
        selectedText.screenCenter(X);
    }
}
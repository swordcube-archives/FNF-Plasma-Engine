package funkin.options.screens;

import flixel.FlxSprite;
import funkin.substates.FNFSubState;
import funkin.ui.ColorPicker;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.scripting.events.SubStateCreationEvent;
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
    
    override function create() {
        var balls:Array<Array<Int>> = cast PlayerSettings.prefs.get('NOTE_COLORS_$keyAmount');
        noteColors = balls.copy();
        script = Script.load(Paths.script('data/substates/options/NoteColoringMenu'));
		script.setParent(this);
		script.run(false);
		script.event("onSubStateCreation", new SubStateCreationEvent(this));

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
            note.setPosition(((Note.spacing * Note.keyInfo[keyAmount].scale) * i) * Note.keyInfo[keyAmount].spacing, 50);
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

        script.event("onSubStateCreationPost", new SubStateCreationEvent(this));
    }

    public function goBack() {
        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
        close();
    }

    override function update(elapsed:Float) {
        for(func in ["onUpdate", "update"]) script.call(func, [elapsed]);

        super.update(elapsed);

        FlxG.mouse.visible = true;

        if(controls.getP("BACK")) {
            FlxG.mouse.visible = false;
            prefs.set('NOTE_COLORS_$keyAmount', noteColors);
            prefs.flush();
            goBack();
        }

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

        for(func in ["onUpdate", "update"]) script.call(func+"Post", [elapsed]);
    }
}
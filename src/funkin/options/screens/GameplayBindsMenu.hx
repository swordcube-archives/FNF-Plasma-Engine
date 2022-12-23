package funkin.options.screens;

import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import funkin.scripting.Script;
import flixel.FlxSprite;
import funkin.game.Note;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.substates.FNFSubState;

// FUCK YEAH!!! REUSING CODE FROM NOTECOLORINGMENU!!
// SO AWESOME!!!
class GameplayBindsMenu extends FNFSubState {
    public var notes:FlxTypedSpriteGroup<Note>;
    public var keybinds:FlxTypedGroup<FlxText>;

    public var keyAmount:Int = 4;

    public var selected:Int = 0;

    public var bg:FlxSprite;
    public var script:ScriptModule;

    public var selectedText:FlxText;

    public var changingBind:Bool = false;

    override function create() {
        script = Script.load(Paths.script('data/substates/options/GameplayBindsMenu'));
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
        add(keybinds = new FlxTypedGroup<FlxText>());

        var ballsText = new FlxText(0,FlxG.height - 140,0,'Click a note to change the bind for it!\n');
        ballsText.setFormat(Paths.font("funkin.ttf"), 32, FlxColor.WHITE, CENTER);
        ballsText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        ballsText.scrollFactor.set();
        ballsText.antialiasing = prefs.get("Antialiasing");
        ballsText.screenCenter(X);
        add(ballsText);

        selectedText = new FlxText(0,FlxG.height - 90,0,'< $keyAmount >');
        selectedText.setFormat(Paths.font("funkin.ttf"), 32, FlxColor.WHITE, CENTER);
        selectedText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        selectedText.scrollFactor.set();
        selectedText.antialiasing = prefs.get("Antialiasing");
        selectedText.screenCenter(X);
        add(selectedText);

        changeKeyAmount();

        script.createPostCall();
    }

    public function goBack() {
        CoolUtil.playMenuSFX(2);
        close();
    }

    override function update(elapsed:Float) {
        script.updateCall(elapsed);
        super.update(elapsed);

        FlxG.mouse.visible = true;

        if(!changingBind) {
            if(controls.getP("BACK")) {
                FlxG.mouse.visible = false;
                controls.flush();
                goBack();
            }
            if(controls.getP("UI_LEFT")) changeKeyAmount(-1);
            if(controls.getP("UI_RIGHT")) changeKeyAmount(1);

            if(FlxG.mouse.justPressed) {
                changingBind = true;
                for (i in 0...notes.members.length) {
                    if (FlxG.mouse.overlaps(notes.members[i]))
                        selected = i;
                }
                for (i in 0...notes.members.length) {
                    var coolScale:Float = notes.members[i].noteScale;
                    if (selected == i)
                        notes.members[i].scale.set(coolScale,coolScale);
                    else
                        notes.members[i].scale.set(coolScale * 0.85, coolScale * 0.85);

                    notes.members[i].alpha = selected == i ? 1 : 0.6;
                }
                notes.members[selected].visible = false;
            }
        } else {
            if(FlxG.keys.justPressed.ANY) {
                var key:FlxKey = FlxG.keys.getIsDown()[0].ID;
                controls.list['GAME_$keyAmount'][selected] = key;

                var bindText:FlxText = keybinds.members[selected];
                bindText.text = CoolUtil.keyToString(key);
                
                var note:Note = notes.members[selected];
                note.visible = true;

                bindText.x = note.x + (note.width / 2);
                bindText.x -= bindText.width / 2;

                changingBind = false;
                CoolUtil.playMenuSFX(1);
            }
        }

        script.updatePostCall(elapsed);
    }

    function changeKeyAmount(change:Int = 0) {
        // Save the current controls
        controls.flush();

        // Change the key amount
        keyAmount = Std.int(FlxMath.wrap(keyAmount + change, 1, Lambda.count(Note.keyInfo)));
        selected = 0;

        // Remove previously displayed notes
        for(note in notes.members) {
            note.kill();
            note.destroy();
            notes.remove(note, true);
        }
        notes.clear();

        // Remove previously displayed keybinds
        for(bind in keybinds.members) {
            bind.kill();
            bind.destroy();
            keybinds.remove(bind, true);
        }
        keybinds.clear();

        // Display the notes for the current key count
        for(i in 0...keyAmount) {
            var note:Note = new Note(0, keyAmount, i);
            note.setPosition(((Note.spacing * Note.keyInfo[keyAmount].scale) * i) * Note.keyInfo[keyAmount].spacing, 0);
            notes.add(note);

            var coolScale:Float = note.noteScale;
            if (selected == i)
                note.scale.set(coolScale,coolScale);
            else
                note.scale.set(coolScale * 0.85, coolScale * 0.85);

            note.alpha = selected == i ? 1 : 0.6;
        }
        notes.scrollFactor.set();
        notes.screenCenter();
        for(i in 0...keyAmount) {
            var note:Note = notes.members[i];
            var fontSize:Int = Std.int(64 * Note.keyInfo[keyAmount].scale);
            var toasterBath:String = CoolUtil.keyToString(controls.list["GAME_"+keyAmount][i]);
            var bindText = new FlxText(note.x + (note.width / 2),0,0,toasterBath+"\n   ");
            bindText.setFormat(Paths.font("funkin.ttf"), fontSize, FlxColor.WHITE, CENTER);
            bindText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
            bindText.scrollFactor.set();
            bindText.screenCenter(Y);
            bindText.x -= bindText.width / 2;
            bindText.y -= Note.spacing * 0.9;
            keybinds.add(bindText);
        }

        selectedText.text = '< $keyAmount >';
        selectedText.screenCenter(X);

        CoolUtil.playMenuSFX(0);
    }
}
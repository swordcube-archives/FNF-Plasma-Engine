package funkin.substates.editors.character_editor;

import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import funkin.states.editors.CharacterEditor;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.input.keyboard.FlxKey;
import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxSprite;

class ConfirmAnimMenu extends FNFSubState {
    var isAddMenu:Bool = true;

    var inputFields:Array<FlxUIInputText> = [];

    public function new(isAddMenu:Bool) {
        super();
        this.isAddMenu = isAddMenu;
    }

    override function create() {
        super.create();

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];

        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x6B000000));

        var box = new FlxUITabMenu(null, [], true);
        box.resize(400, 140);
        box.screenCenter();
        add(box);

        if(isAddMenu) {
            var title = new FlxText(0, box.y + 8, "Add an animation");
            title.screenCenter(X);
            add(title);

            var editor = CharacterEditor.current;
            var nameInput = new FlxUIInputText(0, title.y + 40, Std.int(box.width - 15), editor.characterToModify.animation.name, 8); 
            nameInput.screenCenter(X);
            nameInput.cameras = this.cameras;
            var infoThing = new FlxText(nameInput.x, nameInput.y - 15, "Anim name (ex: idle, danceLeft, danceRight, singLEFT, singLEFTmiss)");
            add(infoThing);
            add(nameInput);
            inputFields.push(nameInput);

            var nameInputAtlas = new FlxUIInputText(0, title.y + 70, Std.int(box.width - 15), "", 8); 
            nameInputAtlas.screenCenter(X);
            nameInputAtlas.cameras = this.cameras;
            var infoThing = new FlxText(nameInputAtlas.x, nameInputAtlas.y - 15, "Anim name from spritesheet (ex: \"bf idle dance\", \"bf up note\")");
            add(infoThing);
            add(nameInputAtlas);
            inputFields.push(nameInputAtlas);

            // i give up on actual naming right about here
            var blalsText = new FlxText(nameInputAtlas.x, nameInputAtlas.y + 30, "Pick an anim");
            add(blalsText);

            var hairyNuts = new FlxUIDropDownMenu(blalsText.x + (blalsText.width + 10), blalsText.y, FlxUIDropDownMenu.makeStrIdLabelArray(CharacterEditor.current.availableAnims, true), function(animation:String) {
                nameInputAtlas.text = CharacterEditor.current.availableAnims[Std.parseInt(animation)];
            }, new FlxUIDropDownHeader(220));
            hairyNuts.cameras = this.cameras;
            add(hairyNuts);

            var addButton = new FlxButton(box.x + (box.width - 10), blalsText.y, "Add", function() {
                var editor = CharacterEditor.current;
                editor.characterToModify.addAnim(nameInput.text, nameInputAtlas.text+"0", 24, false, FlxPoint.get(0, 0));
                editor.characterToModify.playAnim(nameInput.text, true);
                editor.animationDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(editor.characterToModify.animation.getNameList(), true));
                editor.animationDropDown.selectedLabel = nameInput.text;
                close();
            });
            addButton.x -= addButton.width;
            addButton.cameras = this.cameras;
            add(addButton);
        } else {
            var title = new FlxText(0, box.y + 30, "Are you sure you want to remove\nthe currently selected animation?", 16);
            title.screenCenter(X);
            add(title);

            var removeButton = new FlxButton(0, title.y + 50, "Yes", function() {
                var editor = CharacterEditor.current;
                editor.characterToModify.animation.remove(editor.characterToModify.animation.name);
                editor.characterToModify.playAnim(editor.characterToModify.animation.getNameList()[0], true);
                editor.animationDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(editor.characterToModify.animation.getNameList(), true));
                editor.animationDropDown.selectedLabel = editor.characterToModify.animation.getNameList()[0];
                close();
            });
            removeButton.screenCenter(X);
            removeButton.x -= removeButton.width + 10;
            removeButton.cameras = this.cameras;
            add(removeButton);

            var removeButLikeNoFuckYouButton = new FlxButton(0, title.y + 50, "No", function() {
                var editor = CharacterEditor.current;
                editor.characterToModify.animation.remove(editor.characterToModify.animation.name);
                editor.characterToModify.playAnim(editor.characterToModify.animation.getNameList()[0], true);
                editor.animationDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(editor.characterToModify.animation.getNameList(), true));
                editor.animationDropDown.selectedLabel = editor.characterToModify.animation.getNameList()[0];
                close();
            });
            removeButLikeNoFuckYouButton.screenCenter(X);
            removeButLikeNoFuckYouButton.x += removeButLikeNoFuckYouButton.width + 10;
            removeButLikeNoFuckYouButton.cameras = this.cameras;
            add(removeButLikeNoFuckYouButton);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(isTyping()) return;

        if(controls.getP("BACK"))
            close();
    }

    function isTyping() {
        FlxG.sound.muteKeys = [FlxKey.ZERO, FlxKey.NUMPADZERO];
        FlxG.sound.volumeDownKeys = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
        FlxG.sound.volumeUpKeys = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
        var finalResult:Bool = false;
        for(input in inputFields) {
            if(input.hasFocus) {
                FlxG.sound.muteKeys = [];
                FlxG.sound.volumeDownKeys = [];
                FlxG.sound.volumeUpKeys = [];

                if(FlxG.keys.justPressed.ENTER)
                    input.hasFocus = false;

                finalResult = true;
            } else continue;
        }
        return finalResult;
    }
}
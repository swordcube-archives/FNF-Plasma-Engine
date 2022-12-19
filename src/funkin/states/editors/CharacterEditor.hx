package funkin.states.editors;

import flixel.math.FlxMath;
import flixel.ui.FlxButton;
import funkin.ui.HealthIcon;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUI;
import base.Size;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxCamera;
import flixel.FlxObject;
import funkin.game.Character;
import funkin.game.Stage;

using StringTools;

class CharacterEditor extends Editor {
    public static var current:CharacterEditor;

    // Character & Stage
    public var curCharacter:String = "bf";
    public var stage:Stage;

    public var availableAnims:Array<String> = [];

    public var characterToModify:Character;

    // Camera
    public var camFollow:FlxObject;
    public var camHUD:FlxCamera;

    // UI
    public var UI_box:FlxUITabMenu;
    public var UI_animBox:FlxUITabMenu;

    public var inputFields:Array<FlxUIInputText> = [];

    public var healthBarBG:FlxSprite;
	public var healthBar:FlxSprite;

    public var healthIcon:HealthIcon;

    public var animationDropDown:FlxUIDropDownMenu;

    public function new(character:String = "bf") {
        super();
        curCharacter = character;
        current = this;
    }

    override function create() {
        super.create();

        current = this;

        persistentUpdate = false;
        persistentDraw = true;

        // Update Discord RPC
        DiscordRPC.changePresence(
            "In the Character Editor",
            'Editing $curCharacter'
        );

        onBack.removeAll();

        // Add the stage
        add(stage = new Stage().load("default"));

        // Add the character
        characterToModify = new Character(0, 0).loadCharacter(curCharacter);
        characterToModify.isPlayer = characterToModify.playerOffsets;
        characterToModify.loadCharacter(curCharacter);
        characterToModify.debugMode = true;

        var pos = characterToModify.isPlayer ? stage.characterPositions["bf"] : stage.characterPositions["dad"];
        characterToModify.setPosition(pos.x, pos.y);
        add(characterToModify);

        var list:Array<String> = characterToModify.animation.getNameList();
        characterToModify.playAnim(list[0], true);

        // Setup cameras
        camFollow = new FlxObject(0,0,1,1);
        trackCharacter();
        add(camFollow);

        FlxG.camera.follow(camFollow, LOCKON, 1);

        camHUD = new FlxCamera();
        camHUD.bgColor = 0x0;
        FlxG.cameras.add(camHUD, false);

        // Setup UI
        var tabs = [
            {name: "General",   label: "General"},
            {name: "Animation", label: "Animation"},
        ];
        UI_box = new FlxUITabMenu(null, tabs, true);

        var size = new Size(400, 300);
        UI_box.resize(size.width, size.height);
        UI_box.setPosition(FlxG.width - (size.width + 20), 20);
        UI_box.scrollFactor.set();
        add(UI_box);

        for(tab in tabs)
            initTab(tab.name, tab.label);

        UI_box.selected_tab = 1;

        var tabs = [
            {name: "Animations",  label: "Animations"}
        ];
        UI_animBox = new FlxUITabMenu(null, tabs, true);

        var size = new Size(330, 60);
        UI_animBox.resize(size.width, size.height);
        UI_animBox.setPosition(20, 20);
        UI_animBox.scrollFactor.set();
        add(UI_animBox);

        initTab("Animation_box", "Animations");

        healthBarBG = new FlxSprite(30, FlxG.height * 0.9).loadGraphic(Assets.load(IMAGE, Paths.image('ui/healthBar')));
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxSprite(healthBarBG.x + 4, healthBarBG.y + 4).makeGraphic(Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), FlxColor.WHITE);
		healthBar.scrollFactor.set();
        healthBar.color = characterToModify.healthBarColor;
		add(healthBar);

        healthIcon = new HealthIcon(healthBar.x, healthBar.y - 75).loadIcon(characterToModify.healthIcon);
        add(healthIcon);

        // Put UI elements onto the HUD camera
        for(item in [UI_box, UI_animBox, healthBarBG, healthBar, healthIcon])
            item.cameras = [camHUD];

        refreshAvailableAnims();
    }

    function refreshAvailableAnims() {
        availableAnims = [];
        var numbers = "0123456789";
        if (characterToModify.frames != null) {
            for(e in characterToModify.frames.frames) {
                var animName = e.name;
                while(numbers.contains(animName.substr(-1)))
                    animName = animName.substr(0, animName.length - 1);
                
                if (!availableAnims.contains(animName))
                    availableAnims.push(animName);
            }
        }
    }

    function trackCharacter() {
        var midpoint = characterToModify.getGraphicMidpoint().add(characterToModify.positionOffset.x, characterToModify.positionOffset.y);
        camFollow.setPosition(midpoint.x, midpoint.y);
    }

    function initTab(tab:String, label:String) {
        switch(tab) {
            case "General":
                var group:FlxUI = new FlxUI(null, UI_box);
                group.name = label;

                var characterList:Array<String> = [];

                // Modded
                for(item in CoolUtil.readDirectoryFoldersOnly("data/characters", Paths.currentMod))
                    characterList.push(item);

                // Base Game
                for(item in CoolUtil.readDirectoryFoldersOnly("data/characters", Paths.fallbackMod))
                    characterList.push(item);
                
                var healthIconInput = new FlxUIInputText(10, 65, 75, characterToModify.healthIcon, 8); 
                var characterDropDown = new FlxUIDropDownMenu(10, 25, FlxUIDropDownMenu.makeStrIdLabelArray(characterList, true), function(character:String) {
                    var characterIndex:Int = Std.parseInt(character);
                    curCharacter = characterList[characterIndex];
                    characterToModify.loadCharacter(curCharacter);
                    characterToModify.isPlayer = characterToModify.isTruePlayer;
                    characterToModify.loadCharacter(curCharacter);

                    var pos = characterToModify.isPlayer ? stage.characterPositions["bf"] : stage.characterPositions["dad"];
                    characterToModify.setPosition(pos.x, pos.y);
                    trackCharacter();

                    healthIconInput.text = characterToModify.healthIcon;
                    healthIcon.loadIcon(characterToModify.healthIcon);
                    healthBar.color = characterToModify.healthBarColor;

                    animationDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(characterToModify.animation.getNameList(), true));
                    characterToModify.playAnim(characterToModify.animation.getNameList()[0], true);

                    refreshAvailableAnims();
                });
                characterDropDown.selectedLabel = curCharacter;

                // Psych's way of doing this is so fucking stupid lmao
                // https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/editors/CharacterEditorState.hx#L759
                healthIconInput.callback = function(text:String, action:String) {
                    characterToModify.healthIcon = text;
                    healthIcon.loadIcon(characterToModify.healthIcon);
                };
                inputFields.push(healthIconInput);

                group.add(new FlxText(healthIconInput.x, healthIconInput.y - 15, "Health Bar Icon"));
                group.add(healthIconInput);

                group.add(new FlxText(characterDropDown.x, characterDropDown.y - 15, "Character to edit"));
                group.add(characterDropDown);

                UI_box.addGroup(group);

            case "Animation_box":
                var group:FlxUI = new FlxUI(null, UI_animBox);
                group.name = label;

                animationDropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(characterToModify.animation.getNameList(), true), function(animation:String) {
                    var anim:String = characterToModify.animation.getNameList()[Std.parseInt(animation)];
                    characterToModify.playAnim(anim, true);
                });
                animationDropDown.selectedLabel = characterToModify.animation.name;
                group.add(animationDropDown);

                var addButton = new FlxButton(animationDropDown.x + (animationDropDown.width + 10), animationDropDown.y, "Add", function() {
                    persistentUpdate = false;
                    persistentDraw = true;
                    openSubState(new funkin.substates.editors.character_editor.ConfirmAnimMenu(true));
                });
                group.add(addButton);

                var removeButton = new FlxButton(addButton.x + (addButton.width + 10), addButton.y, "Remove", function() {
                    persistentUpdate = false;
                    persistentDraw = true;
                    openSubState(new funkin.substates.editors.character_editor.ConfirmAnimMenu(false));
                });
                group.add(removeButton);

                UI_animBox.addGroup(group);
        }
    }

    override function update(elapsed:Float) {
        FlxG.mouse.visible = true;

        super.update(elapsed);

        if(isTyping()) return;

        if(controls.getP("BACK")) {
            FlxG.switchState(new funkin.states.menus.MainMenuState());
            // Make the mouse invisible when going back again
            FlxG.mouse.visible = false;
        }

        // Camera moving
        var camSpeed:Float = MathUtil.fpsAdjust(10);

        if(FlxG.keys.pressed.UP) camFollow.y -= camSpeed;
        if(FlxG.keys.pressed.DOWN) camFollow.y += camSpeed;
        if(FlxG.keys.pressed.LEFT) camFollow.x -= camSpeed;
        if(FlxG.keys.pressed.RIGHT) camFollow.x += camSpeed;

        // Quick animation switching
        if(FlxG.keys.justPressed.W) switchCharacterAnim(-1);
        if(FlxG.keys.justPressed.S) switchCharacterAnim(1);
    }

    function switchCharacterAnim(change:Int = 0) {
        var list:Array<String> = characterToModify.animation.getNameList();
        var index:Int = Std.int(FlxMath.wrap(list.indexOf(characterToModify.animation.name)+change, 0, list.length-1));
        characterToModify.playAnim(list[index], true);
        animationDropDown.selectedLabel = list[index];
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

    override function destroy() {
        current = null;
        super.destroy();
    }
}
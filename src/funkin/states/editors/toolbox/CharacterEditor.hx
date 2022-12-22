package funkin.states.editors.toolbox;

import flixel.addons.ui.FlxUIButton;
import funkin.ui.ColorPicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.system.FNFSprite;
import haxe.io.Path;
import flixel.math.FlxPoint;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.math.FlxMath;
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
    public var curCharacter:String = "dad";
    public var stage:Stage;

    public var availableAnims:Array<String> = [];

    public var character:Character;
    public var shadowCharacter:Character;

    // Camera
    public var camFollow:FlxObject;
    public var camHUD:FlxCamera;

    // UI
    public var UI_box:FlxUITabMenu;
    public var UI_animBox:FlxUITabMenu;
    public var UI_fileBox:FlxUITabMenu;

    public var inputFields:Array<FlxUIInputText> = [];

    public var healthBarBG:FlxSprite;
	public var healthBar:FlxSprite;

    public var healthIcon:HealthIcon;

    public var animationDropDown:FlxUIDropDownMenu;

    public var camGame:FlxCamera;
    public var cross:FNFSprite;

    public var referenceGroup:FlxTypedGroup<Character>;

    public function new(character:String = "dad") {
        super();
        curCharacter = character;
        current = this;
    }

    public var stageList:Array<String> = [];

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

        // Initialize stage list
        for(item in CoolUtil.readDirectory("data/stages", Paths.currentMod)) {
            var fixed:String = item.split("."+Path.extension(item))[0];
            if(!stageList.contains(fixed))
                stageList.push(fixed);
        }

        for(item in CoolUtil.readDirectory("data/stages", Paths.fallbackMod)) {
            var fixed:String = item.split("."+Path.extension(item))[0];
            if(!stageList.contains(fixed))
                stageList.push(fixed);
        }

        // Add the stage
        add(stage = new Stage().load("default"));

        // Add reference characters
        add(referenceGroup = new FlxTypedGroup<Character>());
        for(i in ["dad", "gf", "bf"]) {
            var pos = stage.characterPositions[i];
            var character = new Character(pos.x, pos.y).loadCharacter(i);
            character.isPlayer = character.playerOffsets;
            character.loadCharacter(i);
            character.debugMode = true;
            character.color = FlxColor.BLACK;
            character.alpha = 0.5;
            if(character.animation.curAnim != null)
                character.animation.curAnim.curFrame = character.animation.curAnim.frames.length;
            referenceGroup.add(character);
        }

        // Add the character
        character = new Character().loadCharacter(curCharacter);
        character.isPlayer = character.playerOffsets;
        character.loadCharacter(curCharacter);
        character.debugMode = true;

        var pos = character.isPlayer ? stage.characterPositions["bf"] : stage.characterPositions["dad"];
        character.setPosition(pos.x, pos.y);

        shadowCharacter = new Character(pos.x, pos.y).loadCharacter(curCharacter);
        shadowCharacter.isPlayer = shadowCharacter.playerOffsets;
        shadowCharacter.loadCharacter(curCharacter);
        shadowCharacter.debugMode = true;
        shadowCharacter.color = FlxColor.BLACK;
        shadowCharacter.alpha = 0.5;
        add(shadowCharacter);
        add(character);

        var list:Array<String> = character.animation.getNameList();
        character.playAnim(list[0], true);
        shadowCharacter.playAnim(list[0], true);

        add(cross = new FNFSprite().load("IMAGE", Paths.image("ui/cross")));
        positionCross();

        // Setup cameras
        add(camFollow = new FlxObject(0,0,1,1));
        trackCharacter();

        camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        var dummyHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        dummyHUD.bgColor = 0;
        dummyHUD.visible = false;
        FlxG.cameras.reset(dummyHUD);
        FlxG.cameras.add(camGame, true);
        
        camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        camHUD.bgColor = 0;
        FlxG.cameras.add(camHUD, false);

        camGame.follow(camFollow, LOCKON, 1);
        
        healthBarBG = new FlxSprite(30, FlxG.height * 0.9).loadGraphic(Assets.load(IMAGE, Paths.image('ui/healthBar')));
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxSprite(healthBarBG.x + 4, healthBarBG.y + 4).makeGraphic(Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), FlxColor.WHITE);
		healthBar.scrollFactor.set();
        healthBar.color = character.healthBarColor;
		add(healthBar);

        healthIcon = new HealthIcon(healthBar.x, healthBar.y - 75).loadIcon(character.healthIcon);
        add(healthIcon);

        // Setup UI
        var tabs = [
            {name: "Health Colors", label: "Health Colors"}, 
            {name: "General",       label: "General"},
            {name: "Animation",     label: "Animation"},
        ];
        UI_box = new FlxUITabMenu(null, tabs, true);

        var size = new Size(300, 240);
        UI_box.resize(size.width, size.height);
        UI_box.setPosition(FlxG.width - (size.width + 20), 20);
        UI_box.scrollFactor.set();
        add(UI_box);

        for(tab in tabs)
            initTab(tab.name, tab.label);

        UI_box.selected_tab = 1;

        var tabs = [
            {name: "Animations",    label: "Animations"}
        ];
        UI_animBox = new FlxUITabMenu(null, tabs, true);

        var size = new Size(485, 60);
        UI_animBox.resize(size.width, size.height);
        UI_animBox.setPosition(20, 20);
        UI_animBox.scrollFactor.set();
        add(UI_animBox);

        var tabs = [
            {name: "File",          label: "File"}
        ];
        UI_fileBox = new FlxUITabMenu(null, tabs, true);

        var size = new Size(103, 60);
        UI_fileBox.resize(size.width, size.height);
        UI_fileBox.setPosition(FlxG.width - (size.width + 20), FlxG.height - (size.height + 20));
        UI_fileBox.scrollFactor.set();
        add(UI_fileBox);

        initTab("Animation_box", "Animations");
        initTab("File_box", "File");

        // Put UI elements onto the HUD camera
        for(item in [UI_box, UI_animBox, UI_fileBox, healthBarBG, healthBar, healthIcon])
            item.cameras = [camHUD];

        refreshAvailableAnims();
    }

    function refreshAvailableAnims() {
        availableAnims = [];
        var numbers = "0123456789";
        if (character.frames != null) {
            for(e in character.frames.frames) {
                var animName = e.name;
                while(numbers.contains(animName.substr(-1)))
                    animName = animName.substr(0, animName.length - 1);
                
                if (!availableAnims.contains(animName))
                    availableAnims.push(animName);
            }
        }
    }

    function trackCharacter() {
        var midpoint = character.getGraphicMidpoint().add(character.positionOffset.x, character.positionOffset.y);
        camFollow.setPosition(midpoint.x, midpoint.y);
    }

    public var animOffsetXStepper:FlxUINumericStepper;
    public var animOffsetYStepper:FlxUINumericStepper;

    public var posOffsetXStepper:FlxUINumericStepper;
    public var posOffsetYStepper:FlxUINumericStepper;

    public var camOffsetXStepper:FlxUINumericStepper;
    public var camOffsetYStepper:FlxUINumericStepper;

    public var scaleStepper:FlxUINumericStepper;

    public var animFPSStepper:FlxUINumericStepper;
    public var indicesInput:FlxUIInputText;

    public var loopBox:FlxUICheckBox;
    public var colorPicker:ColorPicker;

    function initTab(tab:String, label:String) {
        #if !docs
        switch(tab) {
            case "General":
                var group:FlxUI = new FlxUI(null, UI_box);
                group.name = label;

                var characterList:Array<String> = [];

                // Modded
                for(item in CoolUtil.readDirectoryFoldersOnly("data/characters", Paths.currentMod)) {
                    if(!characterList.contains(item))
                        characterList.push(item);
                }

                // Base Game
                for(item in CoolUtil.readDirectoryFoldersOnly("data/characters", Paths.fallbackMod)) {
                    if(!characterList.contains(item))
                        characterList.push(item);
                }
                
                var healthIconInput = new FlxUIInputText(10, 25, 75, character.healthIcon, 8); 

                // Psych's way of doing this is so fucking stupid lmao
                // https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/editors/CharacterEditorState.hx#L759
                healthIconInput.callback = function(text:String, action:String) {
                    character.healthIcon = text;
                    healthIcon.loadIcon(character.healthIcon);
                };
                inputFields.push(healthIconInput);

                group.add(new FlxText(healthIconInput.x, healthIconInput.y - 15, "Health Bar Icon"));
                group.add(healthIconInput);

                var flipBox = new FlxUICheckBox(healthIconInput.x + (healthIconInput.width + 10), 10, null, null, "Flip Character", 80);
                @:privateAccess
                flipBox.checked = character.__baseFlipped;
                flipBox.callback = function() {
                    @:privateAccess {
                        character.__baseFlipped = !character.__baseFlipped;
                        character.flipX = !character.flipX;

                        shadowCharacter.__baseFlipped = !shadowCharacter.__baseFlipped;
                        shadowCharacter.flipX = !shadowCharacter.flipX;
                    }
                }
                group.add(flipBox);

                var playerBox = new FlxUICheckBox(flipBox.x + (flipBox.width + 10), 10, null, null, "Is Player");
                @:privateAccess
                playerBox.checked = character.isTruePlayer;
                playerBox.callback = function() {
                    character.isTruePlayer = !character.isTruePlayer;
                    character.playerOffsets = !character.playerOffsets;
                    character.isPlayer = !character.isPlayer;

                    if (character.isPlayer != character.playerOffsets) {
                        // Swap left and right animations
                        CoolUtil.switchAnimFrames(character.animation.getByName('singRIGHT'), character.animation.getByName('singLEFT'));
                        CoolUtil.switchAnimFrames(character.animation.getByName('singRIGHTmiss'), character.animation.getByName('singLEFTmiss'));
                        CoolUtil.switchAnimFrames(shadowCharacter.animation.getByName('singRIGHT'), shadowCharacter.animation.getByName('singLEFT'));
                        CoolUtil.switchAnimFrames(shadowCharacter.animation.getByName('singRIGHTmiss'), shadowCharacter.animation.getByName('singLEFTmiss'));

                        // Swap left and right animations
                        character.switchOffset('singLEFT', 'singRIGHT');
                        character.switchOffset('singLEFTmiss', 'singRIGHTmiss');
                        shadowCharacter.switchOffset('singLEFT', 'singRIGHT');
                        shadowCharacter.switchOffset('singLEFTmiss', 'singRIGHTmiss');
                    }

                    var pos = character.isPlayer ? stage.characterPositions["bf"] : stage.characterPositions["dad"];
                    character.setPosition(pos.x, pos.y);
                    positionCross();

                    trackCharacter();
                }
                group.add(playerBox);

                var antialiasingBox = new FlxUICheckBox(healthIconInput.x + (healthIconInput.width + 10), 25, null, null, "Antialiasing", 80);
                @:privateAccess
                antialiasingBox.checked = character.__antialiasing;
                antialiasingBox.callback = function() {
                    @:privateAccess
                    character.__antialiasing = !character.__antialiasing;
                    character.antialiasing = PlayerSettings.prefs.get("Antialiasing") ? !character.antialiasing : false;
                    shadowCharacter.antialiasing = character.antialiasing;

                    var offsets = character.offsets[character.animation.name];
                    character.rotOffset.set(offsets.x, offsets.y);
                }
                group.add(antialiasingBox);

                var offsets = character.positionOffset;
                posOffsetXStepper = new FlxUINumericStepper(10, 65, 5, offsets.x, -99999, 99999, 0);
                group.add(new FlxText(posOffsetXStepper.x, posOffsetXStepper.y - 15, "Position Offset"));
                group.add(posOffsetXStepper);

                posOffsetYStepper = new FlxUINumericStepper(posOffsetXStepper.x + (posOffsetXStepper.width + 10), 65, 5, offsets.y, -99999, 99999, 0);
                group.add(posOffsetYStepper);

                var offsets = character.cameraOffset;
                camOffsetXStepper = new FlxUINumericStepper(10, 105, 5, offsets.x, -99999, 99999, 0);
                group.add(new FlxText(camOffsetXStepper.x, camOffsetXStepper.y - 15, "Camera Offset"));
                group.add(camOffsetXStepper);

                camOffsetYStepper = new FlxUINumericStepper(camOffsetXStepper.x + (camOffsetXStepper.width + 10), 105, 5, offsets.y, -99999, 99999, 0);
                group.add(camOffsetYStepper);

                scaleStepper = new FlxUINumericStepper(posOffsetYStepper.x + (posOffsetYStepper.width + 10), 65, 0.05, (character.scale.x + character.scale.y) * 0.5, 0.05, 10, 2);
                group.add(new FlxText(scaleStepper.x, scaleStepper.y - 15, "Character Scale"));
                group.add(scaleStepper);

                var stringDanceSteps:String = "";
                for(i in 0...character.danceSteps.length) {
                    var step:String = character.danceSteps[i];
                    stringDanceSteps += step;
                    if(i < character.danceSteps.length - 1)
                        stringDanceSteps += ",";
                }

                var danceStepsInput = new FlxUIInputText(10, 140, Std.int(UI_box.width - 20), stringDanceSteps, 8);
                danceStepsInput.callback = function(text:String, action:String) {
                    character.danceSteps = CoolUtil.trimArray(text.split(","));
                };
                inputFields.push(danceStepsInput);
                group.add(new FlxText(danceStepsInput.x, danceStepsInput.y - 15, "Dance Steps (Seperated by \",\")"));
                group.add(danceStepsInput);
                
                var stageDropDown = new FlxUIDropDownMenu(10, 185, FlxUIDropDownMenu.makeStrIdLabelArray(stageList, true), function(id:String) {
                    stage.load(stageList[Std.parseInt(id)]);

                    var funny:Array<String> = ["dad", "gf", "bf"];
                    for(i in 0...referenceGroup.length) {
                        var character = referenceGroup.members[i];
                        var pos = stage.characterPositions[funny[i]];
                        character.setPosition(pos.x, pos.y);
                        trackCharacter();
                    }

                    var pos = character.isPlayer ? stage.characterPositions["bf"] : stage.characterPositions["dad"];
                    character.setPosition(pos.x, pos.y);
                    positionCross();
                });
                stageDropDown.selectedLabel = "default";
                group.add(new FlxText(stageDropDown.x, stageDropDown.y - 15, "Stage"));
                group.add(stageDropDown);

                UI_box.addGroup(group);

            case "Animation":
                var group:FlxUI = new FlxUI(null, UI_box);
                group.name = label;

                var offsets = character.offsets[character.animation.name];
                animOffsetXStepper = new FlxUINumericStepper(10, 25, 5, offsets.x, -99999, 99999, 0);
                group.add(new FlxText(animOffsetXStepper.x, animOffsetXStepper.y - 15, "Animation Offset"));
                group.add(animOffsetXStepper);

                animOffsetYStepper = new FlxUINumericStepper(animOffsetXStepper.x + (animOffsetXStepper.width + 10), 25, 5, offsets.y, -99999, 99999, 0);
                group.add(animOffsetYStepper);

                @:privateAccess {
                    inputFields.push(cast(animOffsetXStepper.text_field, FlxUIInputText));
                    inputFields.push(cast(animOffsetYStepper.text_field, FlxUIInputText));
                }

                var fps:Float = character.animation.curAnim != null ? character.animation.curAnim.frameRate : 24;
                animFPSStepper = new FlxUINumericStepper(10, 65, 1, fps, 0, 99999, 0);
                group.add(new FlxText(animFPSStepper.x, animFPSStepper.y - 15, "Animation Framerate"));
                group.add(animFPSStepper);

                loopBox = new FlxUICheckBox(10, 85, null, null, "Loop Animation");
                loopBox.checked = character.animation.curAnim != null ? character.animation.curAnim.looped : false;
                loopBox.callback = function() {
                    // goofy ahh code
                    @:privateAccess {
                        var reversed:Bool = character.animation.curAnim != null ? character.animation.curAnim.reversed : false;
                        var frame:Int = character.animation.curAnim != null ? character.animation.curAnim.curFrame : 0;
                        if(character.animation._animations[character.animation.name] != null)
                            character.animation._animations[character.animation.name].looped = loopBox.checked;
                        character.playAnim(character.animation.name, true, reversed, frame);
                    }
                }
                group.add(loopBox);

                indicesInput = new FlxUIInputText(10, 125, Std.int(UI_box.width - 20), "", 8);
                indicesInput.callback = function(text:String, action:String) {
                    // goofy ahh code
                    @:privateAccess {
                        var reversed:Bool = character.animation.curAnim != null ? character.animation.curAnim.reversed : false;
                        var frame:Int = character.animation.curAnim != null ? character.animation.curAnim.curFrame : 0;
                        var goofin = character.animation._animations[character.animation.name];
                        var animName:String = character.animation.name;
                        if(goofin != null) {
                            var indices:Array<Int> = CoolUtil.splitInt(text, ",");
                            if(indices != null && indices.length > 0) {
                                character.animation.addByIndices(animName, goofin.prefix, indices, "", Std.int(goofin.frameRate), goofin.looped);
                                shadowCharacter.animation.addByIndices(animName, goofin.prefix, indices, "", Std.int(goofin.frameRate), goofin.looped);
                            } else {
                                character.animation.addByPrefix(animName, goofin.prefix, Std.int(goofin.frameRate), goofin.looped);
                                shadowCharacter.animation.addByPrefix(animName, goofin.prefix, Std.int(goofin.frameRate), goofin.looped);
                            }
                        }
                        character.playAnim(animName, true, reversed, frame);
                    }
                };
                inputFields.push(indicesInput);
                group.add(new FlxText(indicesInput.x, indicesInput.y - 15, "Animation Indices (Seperate by \",\")"));
                group.add(indicesInput);

                UI_box.addGroup(group);

            case "Health Colors":
                var group:FlxUI = new FlxUI(null, UI_box);
                group.name = label;
                
                colorPicker = new ColorPicker(
                    10, 10, 
                    190, 100,
                    function() {
                        healthBar.color = character.healthBarColor;
                        colorPicker.setColor({
                            "r": healthBar.color.red,
                            "g": healthBar.color.green,
                            "b": healthBar.color.blue
                        }, false);
                    }
                );
                colorPicker.onChange = function(h:Float, s:Float, b:Float) {
                    healthBar.color = FlxColor.fromHSB(h, s, b);
                };
                colorPicker.setColor({
                    "r": healthBar.color.red,
                    "g": healthBar.color.green,
                    "b": healthBar.color.blue
                }, false);
                colorPicker.cameras = [camHUD];
                colorPicker.scrollFactor.set();
                group.add(colorPicker);

                var iconColorButton = new FlxUIButton(10, 140, "Get color from icon", function() {
                    healthBar.color = CoolUtil.dominantColor(healthIcon);
                    colorPicker.setColor({
                        "r": healthBar.color.red,
                        "g": healthBar.color.green,
                        "b": healthBar.color.blue
                    }, false);
                });
                iconColorButton.resize(UI_box.width - 20, iconColorButton.height);
                group.add(iconColorButton);

                UI_box.addGroup(group);

            // this is for the box with the dropdown + the add & remove buttons
            case "Animation_box":
                var group:FlxUI = new FlxUI(null, UI_animBox);
                group.name = label;

                animationDropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(character.animation.getNameList(), true), function(animation:String) {
                    var anim:String = character.animation.getNameList()[Std.parseInt(animation)];
                    character.playAnim(anim, true);
                    animOffsetXStepper.value = character.rotOffset.x;
                    animOffsetYStepper.value = character.rotOffset.y;
                    var fps:Float = character.animation.curAnim != null ? character.animation.curAnim.frameRate : 24;
                    animFPSStepper.value = fps;

                    @:privateAccess {
                        if(character.animation._animations[character.animation.name] != null)
                            loopBox.checked = character.animation._animations[character.animation.name].looped;
                        else
                            loopBox.checked = false;
                    }
                });
                animationDropDown.selectedLabel = character.animation.name;
                group.add(animationDropDown);

                var addButton = new FlxUIButton(animationDropDown.x + (animationDropDown.width + 10), animationDropDown.y, "Add", function() {
                    persistentUpdate = false;
                    persistentDraw = true;
                    openSubState(new funkin.substates.editors.character_editor.ConfirmAnimMenu(true));
                });
                group.add(addButton);

                var removeButton = new FlxUIButton(addButton.x + (addButton.width + 10), addButton.y, "Remove", function() {
                    persistentUpdate = false;
                    persistentDraw = true;
                    openSubState(new funkin.substates.editors.character_editor.ConfirmAnimMenu(false));
                });
                group.add(removeButton);

                var shadowButton = new FlxUIButton(removeButton.x + (removeButton.width + 10), removeButton.y, "Set as shadow reference", function() {
                    shadowCharacter.playAnim(character.animation.name, true);
                });
                shadowButton.resize(150, shadowButton.height);
                group.add(shadowButton);

                UI_animBox.addGroup(group);

            case "File_box":
                var group:FlxUI = new FlxUI(null, UI_fileBox);
                group.name = label;

                var templateScript:String = 'function create() {
\tcharacter.loadXML();
}';

                var saveButton = new FlxUIButton(10, 10, "Save", function() {
                    var data:String = CoolUtil.getXMLDataFromCharacter(character, healthBar.color);
                    File.saveContent(Paths.xml('data/characters/${character.curCharacter}/config'), data);
                    
                    var scriptPath:String = Paths.script('data/characters/${character.curCharacter}/script');
                    if(!FileSystem.exists(scriptPath)) {
                        var path:String = 'data/characters/${character.curCharacter}/config.hxs';
                        if(Paths.currentMod == Paths.fallbackMod)
                            path = '${Sys.getCwd()}'+(Main.developerMode ? '../../../../' : '')+'assets/$path';
                        else
                            path = '${Sys.getCwd()}'+(Main.developerMode ? '../../../../' : '')+'mods/${Paths.currentMod}/$path';

                        File.saveContent(path, templateScript);
                    } else {
                        FileSystem.rename(scriptPath, scriptPath.replace("/script", "/script_BACKUP"));
                        File.saveContent(scriptPath, templateScript);
                    }

                    FlxG.switchState(new funkin.states.menus.MainMenuState());
                });
                group.add(saveButton);

                UI_fileBox.addGroup(group);
        }
        #end
    }

    // someone please tell me a better way of doing this i beg of you
    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
        switch(Type.getClass(sender)) {
            case FlxUINumericStepper:
                switch(id) {
                    case FlxUINumericStepper.CHANGE_EVENT:
                        if(sender == posOffsetXStepper) {
                            character.positionOffset.x = sender.value;
                            character.offset.x = character.positionOffset.x * (character.isPlayer != character.playerOffsets ? 1 : -1);
                            positionCross();
                        } 
                        else if(sender == posOffsetYStepper) {
                            character.positionOffset.y = sender.value;
                            character.offset.y = -character.positionOffset.y;
                            positionCross();
                        }
                        else if(sender == animOffsetXStepper) {
                            character.offsets[character.animation.name].x = sender.value;
                            character.rotOffset.x = sender.value;
                        } 
                        else if(sender == animOffsetYStepper) {
                            character.offsets[character.animation.name].y = sender.value;
                            character.rotOffset.y = sender.value;
                        }
                        else if(sender == camOffsetXStepper) {
                            character.cameraOffset.x = sender.value;
                            positionCross();
                        } 
                        else if(sender == camOffsetYStepper) {
                            character.cameraOffset.y = sender.value;
                            positionCross();
                        }
                        else if(sender == scaleStepper) {
                            character.scale.set(scaleStepper.value, scaleStepper.value);
                        }
                        else if(sender == animFPSStepper) {
                            // goofy ahh code
                            @:privateAccess {
                                var reversed:Bool = character.animation.curAnim != null ? character.animation.curAnim.reversed : false;
                                var frame:Int = character.animation.curAnim != null ? character.animation.curAnim.curFrame : 0;
                                if(character.animation._animations[character.animation.name] != null)
                                    character.animation._animations[character.animation.name].frameRate = Std.int(sender.value);
                                character.playAnim(character.animation.name, true, reversed, frame);
                            }
                        }
                }
        }
    }

    function positionCross() {
        var pos = character.getCameraPosition();
        cross.setPosition(pos.x, pos.y);
    }

    var movingOffset:Bool = false;

    var movingOffsetDefaultPos:FlxPoint = null;
    var movingOffsetDefaultPosOffset:FlxPoint = null;

    override function update(elapsed:Float) {
        FlxG.mouse.visible = true;

        super.update(elapsed);

        shadowCharacter.offset.copyFrom(character.offset);
        if(shadowCharacter.animation.name == character.animation.name)
            shadowCharacter.rotOffset.copyFrom(character.rotOffset);
        shadowCharacter.setPosition(character.x, character.y);
        shadowCharacter.scale.copyFrom(character.scale);

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

        if(FlxG.keys.justPressed.SPACE) character.playAnim(character.animation.name, true);

        // Offset dragging
        if(FlxG.mouse.pressed) {
            if(!movingOffset && mouseOverlapsChar()) {
                movingOffset = true;
                movingOffsetDefaultPos = FlxG.mouse.getScreenPosition();
                movingOffsetDefaultPosOffset = FlxPoint.get(animOffsetXStepper.value, animOffsetXStepper.value);
            }
            else if(movingOffset) {
                var pos = FlxG.mouse.getScreenPosition();
                animOffsetXStepper.value = movingOffsetDefaultPosOffset.x + (((movingOffsetDefaultPos.x - pos.x) / camGame.zoom) / character.scale.x);
                animOffsetYStepper.value = movingOffsetDefaultPosOffset.y + (((movingOffsetDefaultPos.y - pos.y) / camGame.zoom) / character.scale.y);

                character.rotOffset.set(animOffsetXStepper.value, animOffsetYStepper.value);
                character.offsets[character.animation.name].copyFrom(character.rotOffset);
            }
        } else movingOffset = false;

        // Camera zooming
        if(FlxG.mouse.wheel != 0) {
            var newZoom = camGame.zoom;
            if (FlxG.mouse.wheel < 0) {
                for(i in 0...-(FlxG.mouse.wheel))
                    newZoom *= 0.75;
            } else {
                for(i in 0...FlxG.mouse.wheel)
                    newZoom *= 4 / 3;
            }
            camGame.zoom = FlxMath.bound(newZoom, 0.1, 10);
        }
    }

    function switchCharacterAnim(change:Int = 0) {
        var list:Array<String> = character.animation.getNameList();
        var index:Int = Std.int(FlxMath.wrap(list.indexOf(character.animation.name)+change, 0, list.length-1));
        character.playAnim(list[index], true);
        animationDropDown.selectedLabel = list[index];
        animOffsetXStepper.value = character.rotOffset.x;
        animOffsetYStepper.value = character.rotOffset.y;
        var fps:Float = character.animation.curAnim != null ? character.animation.curAnim.frameRate : 24;
        animFPSStepper.value = fps;

        @:privateAccess {
            if(character.animation._animations[character.animation.name] != null)
                loopBox.checked = character.animation._animations[character.animation.name].looped;
            else
                loopBox.checked = false;
        }
    }

    function mouseOverlapsChar() {
        var mousePos = FlxG.mouse.getWorldPosition(camGame);
        var bruj = new FlxPoint(character.offset.x * (character.isPlayer ? -1 : 1), -character.offset.y);
        return ((character.x + bruj.x) - (character.rotOffset.x) < mousePos.x
             && (character.x + bruj.x) - (character.rotOffset.x) + (character.frameWidth * character.scale.y) > mousePos.x
             && (character.y + bruj.y) - (character.rotOffset.y) < mousePos.y
             && (character.y + bruj.y) - (character.rotOffset.y) + (character.frameHeight * character.scale.y) > mousePos.y);
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
package funkin.menus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import funkin.game.Boyfriend;
import funkin.game.Character;
import funkin.game.FunkinState;
import funkin.game.GlobalVariables;
import funkin.game.Stage;
import funkin.shaders.ColorSwap;
import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import funkin.systems.UIControls;
import lime.system.Clipboard;

using StringTools;

/**
    A editor for making characters because marcy kept crying to me about it
**/
class CharacterEditor extends FunkinState
{
    public static var instance:CharacterEditor;
    
    public var curCharacter:String = "bf";

    public var camHUD:FlxCamera;
    
    public var stage:Stage;

    public var dadReference:Character;
    public var gfReference:Character;
    public var bfReference:Character;

    public static var character:Character;

    public var animationUIBase:FlxUI = new FlxUI();
    public var animationDropdown:FlxUIDropDownMenuCustom;
    public var addAnimBTN:FlxButton;
    public var removeAnimBTN:FlxButton;

    #if MODS_ALLOWED
    var characterList:Array<String> = FunkinAssets.getText(Paths.txt("data/characterList"), softmod.SoftMod.modsList[GlobalVariables.selectedMod], true).split("\n");
    #else
    var characterList:Array<String> = FunkinAssets.getText(Paths.txt("data/characterList")).split("\n");
    #end

    override public function create()
    {
        super.create();

        instance = this;

        persistentUpdate = false;
        persistentDraw = true;
        
        stage = new Stage("stage");
        add(stage);

        var dumb:ColorSwap = new ColorSwap();
        dumb.set_brightness(-100);

        dadReference = new Character(100, 100, "dad");
        dadReference.debugMode = true;
        dadReference.shader = dumb.shader;
        dadReference.alpha = 0.5;
        add(dadReference);

        gfReference = new Character(400, 100, "gf");
        gfReference.debugMode = true;
        gfReference.shader = dumb.shader;
        gfReference.alpha = 0.5;
        add(gfReference);

        bfReference = new Boyfriend(770, 100, "bf");
        bfReference.debugMode = true;
        bfReference.shader = dumb.shader;
        bfReference.alpha = 0.5;
        bfReference.flipX = !bfReference.flipX;
        add(bfReference);

        character = new Character(stage.dadPosition.x, stage.dadPosition.y, curCharacter);
        add(character);

        FlxG.cameras.reset();

		camHUD = new FlxCamera();
		camHUD.bgColor = 0x0;

		FlxG.cameras.add(camHUD, false);

        animationUIBase.cameras = [camHUD];
        create_UI();

        //animationDropdown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(getAnimationArray(), true));
    }

    public static function getAnimationArray()
    {
        var array:Array<String> = [];
        for(key in character.animOffsets.keys())
            array.push(key);
        return array;
    }

    function create_UI()
    {
        // prepare
        var uiBox = new FlxUITabMenu(null, [], false);

        uiBox.resize(330, 50);
        uiBox.x = (FlxG.width - uiBox.width) - 10;
        uiBox.y = 10;
        uiBox.scrollFactor.set();
        uiBox.cameras = [camHUD];
        
        animationUIBase.add(uiBox);

        // add the objects
        animationDropdown = new FlxUIDropDownMenuCustom(15, 15, FlxUIDropDownMenuCustom.makeStrIdLabelArray(getAnimationArray(), true), function(id:String) {
            var animToLoad:String = getAnimationArray()[Std.parseInt(id)];
            character.playAnim(animToLoad, true);
        });
        uiBox.add(animationDropdown);

        var animBTNX = 15 + (animationDropdown.width + 10);
        var animBTNY = 15;
        addAnimBTN = new FlxButton(animBTNX, animBTNY, "Add", function() {
            openSubState(new AddAnimSubState());
        });
        uiBox.add(addAnimBTN);

        removeAnimBTN = new FlxButton(animBTNX + (addAnimBTN.width + 10), animBTNY, "Remove", function() {
            character.removeAnim(animationDropdown.selectedLabel);
            character.playAnim(character.animList[0], true);
        });
        uiBox.add(removeAnimBTN);
        
        // add the base
        add(animationUIBase);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(UIControls.justPressed("BACK"))
            switchState(new MainMenu());

        if (FlxG.mouse.wheel != 0) {
            var newZoom = FlxG.camera.zoom;
            if (FlxG.mouse.wheel < 0) {
                for(i in 0...-(FlxG.mouse.wheel)) {
                    newZoom *= 0.75;
                }
            } else {
                for(i in 0...FlxG.mouse.wheel) {
                    newZoom *= 4 / 3;
                }
            }
            FlxG.camera.zoom = FlxMath.bound(newZoom, 0.1, 10);
        }
    }
}

class AddAnimSubState extends FlxSubState
{
    var animNameInput:FlxUIInputText;
    var animPrefixInput:FlxUIInputText;

    var button:FlxButton;

    var oldZoom = FlxG.camera.zoom;
    
    override public function create()
    {
        super.create();
        
        FlxG.camera.zoom = 1;

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        bg.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
        add(bg);

        var uiBox = new FlxUITabMenu(null, [], false);
        uiBox.resize(430, 300);
        uiBox.screenCenter();
        uiBox.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
        add(uiBox);

        var yourMomShitted:FlxText = new FlxText(0, uiBox.y + 30, 0, "Add Anim", 32);
        yourMomShitted.screenCenter(X);
        yourMomShitted.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
        add(yourMomShitted);

        // anim nanme

        var death:FlxText = new FlxText(0, yourMomShitted.y + 60, 0, "Animation Name (singLEFT, singUP, etc)", 12);
        death.screenCenter(X);
        death.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
        add(death);

        animNameInput = new FlxUIInputText(0, death.y + 20, Std.int(uiBox.width - 30));
        animNameInput.screenCenter(X);
        animNameInput.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
        add(animNameInput);

        // anim preidjoxpk;l/,ds

        var death:FlxText = new FlxText(0, animNameInput.y + 50, 0, "Animation Prefix (bf left, bf down, etc)", 12);
        death.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
        death.screenCenter(X);
        add(death);

        animPrefixInput = new FlxUIInputText(0, death.y + 20, Std.int(uiBox.width - 30));
        animPrefixInput.screenCenter(X);
        animPrefixInput.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
        add(animPrefixInput);

        button = new FlxButton(0, animPrefixInput.y + 60, "Add Anim", function() {
            CharacterEditor.character.addAnimByPrefix(animNameInput.text, animPrefixInput.text, 24, false);
            CharacterEditor.character.playAnim(animNameInput.text, true);
            
            CharacterEditor.instance.animationDropdown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(CharacterEditor.getAnimationArray()));
            close();
        });
        button.screenCenter(X);
        button.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
        add(button);
    }

	function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().endsWith('v')) //probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length-1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		var inputTexts:Array<FlxUIInputText> = [animNameInput, animPrefixInput];
		for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null) { //Copy paste
					inputTexts[i].text = ClipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
				}
				if(FlxG.keys.justPressed.ENTER) {
					inputTexts[i].hasFocus = false;
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
        
        if(UIControls.justPressed("BACK"))
            close();
    }

    override public function close()
    {
        FlxG.camera.zoom = oldZoom;
        super.close();
    }
}
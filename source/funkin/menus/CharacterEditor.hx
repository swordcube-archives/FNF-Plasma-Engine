package funkin.menus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.math.FlxMath;
import funkin.game.Boyfriend;
import funkin.game.Character;
import funkin.game.FunkinState;
import funkin.game.GlobalVariables;
import funkin.game.Stage;
import funkin.shaders.ColorSwap;
import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import funkin.systems.UIControls;

/**
    A editor for making characters because marcy kept crying to me about it
**/
class CharacterEditor extends FunkinState
{
    var curCharacter:String = "bf";

    var camHUD:FlxCamera;
    
    var stage:Stage;

    var dadReference:Character;
    var gfReference:Character;
    var bfReference:Character;

    var character:Character;

    var animationUIBase:FlxUI = new FlxUI();
    var animationDropdown:FlxUIDropDownMenuCustom;

    #if MODS_ALLOWED
    var characterList:Array<String> = FunkinAssets.getText(Paths.txt("data/characterList"), softmod.SoftMod.modsList[GlobalVariables.selectedMod], true).split("\n");
    #else
    var characterList:Array<String> = FunkinAssets.getText(Paths.txt("data/characterList"));
    #end

    override public function create()
    {
        super.create();
        
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
    }

    function create_UI()
    {
        var uiBox = new FlxUITabMenu(null, [], false);

        uiBox.resize(300, 50);
        uiBox.x = (FlxG.width - uiBox.width) - 10;
        uiBox.y = 10;
        uiBox.scrollFactor.set();
        uiBox.cameras = [camHUD];
        
        animationUIBase.add(uiBox);

        animationDropdown = new FlxUIDropDownMenuCustom(15, 15, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characterList, true), function(id:String) {
            var charToLoad:String = characterList[Std.parseInt(id)];
            trace(charToLoad);
        });

        uiBox.add(animationDropdown);
        
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
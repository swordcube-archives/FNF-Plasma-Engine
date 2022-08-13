package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import gameplay.Boyfriend;
import gameplay.Character;
import gameplay.Stage;
import haxe.macro.ComplexTypeTools;
import shaders.ColorShader;
import systems.MusicBeat;

enum CharacterSpot {
    DAD;
    GF;
    BF;
}

class CharacterEditor extends MusicBeatState {
    var camHUD:FlxCamera;
    var stage:Stage;

    var characterSpot:CharacterSpot = DAD;

    public static var curCharacter:String = "dad";

    var coolCharacter:Character;

    var dumbassesColorShader:ColorShader = new ColorShader(255, 255, 255);
    var dumbassGroup:FlxTypedSpriteGroup<Character>;

    var uiGroup:FlxGroup;

    override function create()
    {
        super.create();

        setupCameras();

        stage = new Stage();
        add(stage);

        dumbassesColorShader.setColors(0, 0, 0);

        dumbassGroup = new FlxTypedSpriteGroup<Character>();
        dumbassGroup.shader = dumbassesColorShader;
        dumbassGroup.alpha = 0.45;
        add(dumbassGroup);

        var character:Character = new Character(stage.dadPosition.x, stage.dadPosition.y, "dad");
        character.debugMode = true;
        dumbassGroup.add(character);

        var character:Character = new Character(stage.gfPosition.x, stage.gfPosition.y, "gf");
        character.debugMode = true;
        dumbassGroup.add(character);

        var character:Boyfriend = new Boyfriend(stage.bfPosition.x, stage.bfPosition.y, "bf");
        character.flipX = !character.flipX;
        character.debugMode = true;
        dumbassGroup.add(character);

        coolCharacter = new Character(0, 0, curCharacter);
        coolCharacter.debugMode = true;
        repositionCharacter();
        add(coolCharacter);

        uiGroup = new FlxGroup();
        uiGroup.cameras = [camHUD];
        add(uiGroup);
    }

    function setupCameras()
    {
		FlxG.cameras.reset();
		camHUD = new FlxCamera();
		camHUD.bgColor = 0x0;

		FlxG.cameras.add(camHUD, false);
    }

    function repositionCharacter()
    {
        var x:Float = switch(characterSpot) {
            case DAD:
                stage.dadPosition.x;
            case GF:
                stage.gfPosition.x;
            default:
                stage.bfPosition.x;
        }
        var y:Float = switch(characterSpot) {
            case DAD:
                stage.dadPosition.y;
            case GF:
                stage.gfPosition.y;
            default:
                stage.bfPosition.y;
        }

        coolCharacter.goToPosition(x, y);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.mouse.wheel != 0) {
            var newZoom = FlxG.camera.zoom;
            if (FlxG.mouse.wheel < 0) {
                for(i in 0...-(FlxG.mouse.wheel)) {
                    newZoom *= 0.75;
                }
            } else {
                for(i in 0...FlxG.mouse.wheel) {
                    newZoom *= 1.3;
                }
            }
            FlxG.camera.zoom = FlxMath.bound(newZoom, 0.1, 10);
        }
    }

    public function mouseOverlapsChar() {
        var mousePos = FlxG.mouse.getWorldPosition(FlxG.camera);
        return (coolCharacter.x - (coolCharacter.offset.x) < mousePos.x
             && coolCharacter.x - (coolCharacter.offset.x) + (coolCharacter.frameWidth * coolCharacter.scale.y) > mousePos.x
             && coolCharacter.y - (coolCharacter.offset.y) < mousePos.y
             && coolCharacter.y - (coolCharacter.offset.y) + (coolCharacter.frameHeight * coolCharacter.scale.y) > mousePos.y);
    }
}
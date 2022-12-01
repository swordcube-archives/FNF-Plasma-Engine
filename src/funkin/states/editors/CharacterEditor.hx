package funkin.states.editors;

import flixel.FlxObject;
import funkin.game.Character;
import funkin.game.Stage;

class CharacterEditor extends Editor {
    var curCharacter:String = "bf";
    var stage:Stage;

    var characterToModify:Character;

    var camFollow:FlxObject;

    public function new(character:String = "bf") {
        super();
        curCharacter = character;
    }

    override function create() {
        super.create();

        add(stage = new Stage().load("default"));

        var pos = stage.characterPositions["bf"];
        add(characterToModify = new Character(pos.x, pos.y).loadCharacter(curCharacter));

        camFollow = new FlxObject(0,0,1,1);
        var midpoint = characterToModify.getGraphicMidpoint().add(characterToModify.positionOffset.x, characterToModify.positionOffset.y);
        camFollow.setPosition(midpoint.x, midpoint.y);
        add(camFollow);

        FlxG.camera.follow(camFollow, LOCKON, 0.8);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var camSpeed:Float = elapsed * 60 * 10;

        if(FlxG.keys.pressed.UP) camFollow.y -= camSpeed;
        if(FlxG.keys.pressed.DOWN) camFollow.y += camSpeed;
        if(FlxG.keys.pressed.LEFT) camFollow.x -= camSpeed;
        if(FlxG.keys.pressed.RIGHT) camFollow.x += camSpeed;
    }
}
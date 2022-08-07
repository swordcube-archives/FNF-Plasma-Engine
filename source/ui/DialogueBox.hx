package ui;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import haxe.Json;
import hscript.HScript;
import states.PlayState;
import systems.FNFSprite;

typedef DialogueJSON = {
    var dialogue:Array<DialoguePage>;
};

typedef DialoguePage = {
    var char:String;
    var emotion:String;
    var text:String;
    var speed:Float;
};

// To use dialogue make a script.hxs in your song's folder
// And do this:
/**
    function create() {
        DialogueBox.dialogue = DialogueManager.loadFromJSON('dialogue');
        
        var dialogue:DialogueBox = new DialogueBox(someSkin);
        PlayState.add(dialogue);
    }
**/
// Dialogue loads from songs folder btw, ex: "assets/yourPack/songs/yourSong/dialogue.json"
// Then you win

class DialogueBox extends FlxGroup
{
    public static var dialogue:Array<DialoguePage> = [];

    public var bg:FlxSprite;

    public var box:DialogueBoxSprite;

    public function new(skin:String)
    {
        super();

        PlayState.current.inCutscene = true;

        box = new DialogueBoxSprite(70, 370, skin);
        add(box);
    }
}

class DialogueBoxSprite extends FNFSprite
{
    public var script:HScript;
    public var skin:String = "default";

    public function new(x:Float, y:Float, ?skin:String = "default")
    {
        super(x, y);

        this.skin = skin;
        
		scrollFactor.set();

        script = new HScript('boxes/${skin}');
        script.setVariable("sprite", this);
        
        script.start(false);
        script.callFunction("create", [skin]);
        script.callFunction("createPost", [skin]);
    }
}

class DialogueManager
{
    /**
        Returns an array of `DialoguePage` from a json at path of
        "assets/somePack/songs/someSong/`jsonName`.json".

        @param jsonName           The name of the thing
    **/
    public static function loadFromJSON(jsonName:String):Array<DialoguePage>
    {
        var json:DialogueJSON = Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json('songs/${PlayState.SONG.song}/$jsonName')));
        var result:Array<DialoguePage> = json != null ? json.dialogue : [];

        return result;
    }
}
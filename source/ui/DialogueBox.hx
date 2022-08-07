package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
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
// function create() {
//     DialogueBox.dialogue = DialogueManager.loadFromJSON('dialogue');
    
//     var dialogue:DialogueBox = new DialogueBox(someSkin);
//     PlayState.add(dialogue);
// }
// Dialogue loads from songs folder btw, ex: "assets/yourPack/songs/yourSong/dialogue.json"
// Then you win

class DialogueBox extends FlxGroup
{
    public static var dialogue:Array<DialoguePage> = [];

    public var tempDialogue:Array<DialoguePage> = [];

    public var bg:FlxSprite;

    public var box:DialogueBoxSprite;

    public var skipped:Bool = false;

    public function new(?skin:String = "default")
    {
        super();

        tempDialogue = dialogue.copy();

        PlayState.current.inCutscene = true;

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        bg.cameras = [PlayState.current.camOther];
        bg.alpha = 0;
        add(bg);

        box = new DialogueBoxSprite(70, 370, skin);
        box.cameras = [PlayState.current.camOther];
        box.visible = false;
        add(box);

        FlxTween.tween(bg, { alpha: 0.3 }, 0.5, { ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
            box.playAnim("normalOpen");
            box.visible = true;
        }});
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.SHIFT && !skipped)
            skipDialogue();
        else if(FlxG.keys.justPressed.ANY && !skipped)
            nextPage();
    }

    function nextPage()
    {
        if(tempDialogue.length > 0)
        {
            tempDialogue.shift();
        }
        else
        {
            skipDialogue();
        }
    }

    function skipDialogue()
    {
        skipped = true;
            
        FlxTween.tween(bg, { alpha: 0 }, 0.5, { ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
            box.playAnim("normalOpen");
            box.animation.curAnim.curFrame = box.animation.curAnim.frames.length-1;
            box.animation.curAnim.reverse();
            box.visible = true;
        }});
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

        script = new HScript('boxes/$skin');
        script.setVariable("sprite", this);
        script.setVariable("playBoxAnim", this.playBoxAnim);
        
        script.start(false);
        script.callFunction("create", [skin]);
        script.callFunction("createPost", [skin]);
    }

    public function playBoxAnim(anim:String, isLoud:Bool, isMiddle:Bool, force:Bool = false)
    {
        var state:String = isLoud ? "loud " : "normal ";
        var middleShit:String = isMiddle ? "middle " : "";
        
        switch(anim.toLowerCase())
        {
            case "open":
                playAnim(state + middleShit + " open");
            case "idle":
                playAnim(state + middleShit + " idle");
        }
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
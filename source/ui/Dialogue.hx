package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;
import hscript.HScript;
import openfl.media.Sound;
import states.PlayState;

typedef DialogueJSON = {
    var info:DialogueInfo;
    var lines:Array<DialogueLine>;
};

typedef DialogueInfo = {
    var music:String;
    var musicVolume:Float;
    var proceedSound:String;
};

typedef DialogueLine = {
    var char:String;
    var emotion:String;
    var text:String;
    var box:String;
    var font:String;
    var speed:Float;
    var ?background:String;
    var ?voiceTrack:String;
};

// To use dialogue make a script.hxs in your song's folder
// And do this:
// function create() {
//     DialogueBox.dialogue = DialogueManager.loadFromJSON('dialogue');
//
//     var dialogue:DialogueBox = new DialogueBox(someSkin);
//     PlayState.add(dialogue);
// }
// Dialogue loads from songs folder btw, ex: "assets/yourPack/songs/yourSong/dialogue.json"
// Then you win

class Dialogue extends FlxGroup
{
    var json:DialogueJSON;

    var curLine:DialogueLine;
    var curLineIndex:Int;

    var box:FlxSprite;
    var portrait:FlxSprite;
    var text:FlxTypeText;
    
    var boxScript:HScript;
    var portraitScript:HScript;
    var textScript:HScript;

    public function new(jsonName:String)
    {
        super();
        json = Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json('songs/${PlayState.SONG.song}/$jsonName')));
        //loadPortrait(json.lines[0].char, json.lines[0].emotion);
        loadBox(json.lines[0].box);
    }

    function loadBox(script) {
        box = new FlxSprite();
        boxScript = new HScript('dialog/boxes/$script');
        boxScript.setVariable("box", box);
        boxScript.setVariable("portrait", portrait);        
        boxScript.start();
        add(box);
    }
    function loadPortrait(script, emotion) {
        portrait = new FlxSprite();
        portraitScript = new HScript('dialog/portraits/$script');
        portraitScript.setVariable("portrait", portrait);
        portraitScript.callFunction(emotion);
        add(portrait);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        //boxScript.update(elapsed);
        //portraitScript.update(elapsed);
        //textScript.update(elapsed);
    }
}
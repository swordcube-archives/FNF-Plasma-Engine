package funkin.states;

import scripting.HScriptModule;
import scripting.Script;
import scripting.ScriptModule;
import openfl.media.Sound;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import base.Conductor;

class TitleScreen extends FunkinState {
    public var defaultBehavior:Bool = true;
	var script:ScriptModule;

    var logo:Sprite;
    var gf:Sprite;
    var pressEnter:Sprite;
    var ngSpr:Sprite;

    var danced:Bool = true;

    var startedIntro:Bool = false;
    var skippedIntro:Bool = false;
    var accepted:Bool = false;

    var curWacky:Array<String> = [];
    var textGroup:FlxTypedGroup<Alphabet>;

    var confirmMenu:Sound = Assets.load(SOUND, Paths.sound("menus/confirmMenu"));

    function getIntroTextShit():Array<Array<String>> {
		var fullText:String = Assets.load(TEXT, Paths.txt('data/introText'));
		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];
		for(i in firstArray) swagGoodArray.push(i.split('--'));
		return swagGoodArray;
	}

    override function create() {
        super.create();

        DiscordRPC.changePresence(
            "In the Title Screen",
            null
        );

        script = Script.create(Paths.script("data/states/TitleScreen"));
		if(Std.isOfType(script, HScriptModule)) cast(script, HScriptModule).setScriptObject(this);
		script.start(true, []);

		if(!defaultBehavior) return;
        Conductor.changeBPM(102);
        curWacky = FlxG.random.getObject(getIntroTextShit());

        logo = new Sprite(-150, -100).load(SPARROW, Paths.image("menus/title/logo"));
        logo.addAnim("idle", "logo bumpin");
        logo.playAnim("idle");
        logo.alpha = 0.001;
        add(logo);

        gf = new Sprite(FlxG.width * 0.4, FlxG.height * 0.07).load(SPARROW, Paths.image("menus/title/gf"));
        gf.addAnimByIndices("danceL", "GF dancing", [for(i in 0...14) i]);
        gf.addAnimByIndices("danceR", "GF dancing", [for(i in 14...29) i]);
        gf.playAnim("danceL");
        gf.alpha = 0.001;
        add(gf);

        pressEnter = new Sprite(100, FlxG.height * 0.8).load(SPARROW, Paths.image("menus/title/titleEnter"));
        pressEnter.addAnim("idle", "idle loop", 24, true);
        pressEnter.addAnim("confirm", "confirm loop", 24, true);
        pressEnter.playAnim("idle");
        pressEnter.alpha = 0.001;
        add(pressEnter);

        ngSpr = new Sprite(0, FlxG.height * 0.52).load(IMAGE, Paths.image('menus/title/newgrounds'));
        ngSpr.alpha = 0.001;
		ngSpr.scale.set(0.8, 0.8);
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		add(ngSpr);

        textGroup = new FlxTypedGroup<Alphabet>();
        add(textGroup);

        new FlxTimer().start(1, function(t:FlxTimer) {
            startedIntro = true;
            if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
                FlxG.sound.playMusic(Assets.load(SOUND, Paths.music("menus/titleScreen")));
        });
    }

    function createTextLines(textArray:Array<String>) {
        if(!defaultBehavior) return;
		for (item in textArray) addTextLine(item);
	}

    function addTextLine(text:String) {
        if(!defaultBehavior) return;
		var text:Alphabet = new Alphabet(0, 0, Bold, text);
		text.screenCenter(X);
		text.y += (textGroup.length * 60) + 200;
		textGroup.add(text);
	}

    function deleteTextLines() {
        if(!defaultBehavior) return;
		while (textGroup.members.length > 0) {
            textGroup.remove(textGroup.members[0], true);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        script.call("onUpdate", [elapsed]);
		script.call("update", [elapsed]);

        if(!defaultBehavior) return;
        if(FlxG.sound.music != null)
            Conductor.position = FlxG.sound.music.time;

        if(Controls.getP("accept") && startedIntro) {
            if(!skippedIntro)
                skipIntro();
            else if(!accepted) {
                accepted = true;
                pressEnter.playAnim("confirm");
                FlxG.sound.play(confirmMenu);
                FlxG.camera.flash(FlxColor.WHITE, 1);
                new FlxTimer().start(2, function(tmr:FlxTimer) {
                    Main.switchState(new MainMenu());
                });
            }
        }
    }

    override function beatHit(curBeat:Int) {
        super.beatHit(curBeat);

        danced = !danced;
        logo.playAnim("idle", true);
        gf.playAnim("dance"+(danced ? "L" : "R"));

        if(!skippedIntro) {
            switch(curBeat) {
                case 1:
                    createTextLines(['swordcube', 'Leather128', 'Raf', 'Stilic']);
                case 3:
                    addTextLine('present');
                case 4:
                    deleteTextLines();
                case 5:
                    createTextLines(['In association', 'with']);
                case 7:
                    addTextLine('Newgrounds');
                    ngSpr.alpha = 1;
                case 8:
                    deleteTextLines();
                    ngSpr.alpha = 0.001;
                case 9:
                    createTextLines([curWacky[0]]);
                case 11:
                    addTextLine(curWacky[1]);
                case 12:
                    deleteTextLines();
                case 13:
                    addTextLine('Friday');
                case 14:
                    addTextLine('Night');
                case 15:
                    addTextLine('Funkin');
                default:
                    if(curBeat >= 16)
                        skipIntro();
            }
        }
    }

    function skipIntro() {
        FlxG.camera.flash(FlxColor.WHITE, 4);
        skippedIntro = true;

        remove(ngSpr, true);
        ngSpr.destroy();

        deleteTextLines();

        logo.alpha = 1;
        gf.alpha = 1;
        pressEnter.alpha = 1;
    }
}
package funkin.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.game.FunkinSprite;
import funkin.game.FunkinState;
import funkin.game.PlayState;
import funkin.game.Song.SongLoader;
import funkin.systems.Conductor;
import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import funkin.systems.UIControls;
import funkin.ui.Alphabet;

class TitleState extends FunkinState
{
    var freakyMenu:Dynamic;
    
	var alphabet:Alphabet;
	var credGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = ["???", "???"];

	public static var startedIntro:Bool = false;

	public static var alreadySkipped:Bool = false;

    var logo:FunkinSprite = new FunkinSprite(-15, -5);
    var gf:FunkinSprite = new FunkinSprite(FlxG.width * 0.4, FlxG.height * 0.07);
    var titleEnter:FunkinSprite = new FunkinSprite(100, FlxG.height * 0.8);

	var danceLeft:Bool = false;

	override public function create()
	{
		super.create();

		persistentUpdate = true;
		persistentDraw = true;

		freakyMenu = FunkinAssets.getSound(Paths.music('freakyMenu'));

		Conductor.changeBPM(102);
		Conductor.position = 0.0;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// ng logo
		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(FunkinAssets.getImage(Paths.image('title/newgrounds')));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = Preferences.antiAliasing;

		logo.frames = FunkinAssets.getSparrow("title/funkinLogo");
		logo.addAnimByPrefix("bump", "logo bumpin", 24, false);
		logo.playAnim("bump");
        logo.visible = false;
		add(logo);

		gf.frames = FunkinAssets.getSparrow("title/gfDance");
		gf.addAnimByIndices("danceLeft", "GF Boppin", Utilities.generateArray(0, 15), 24, false);
		gf.addAnimByIndices("danceRight", "GF Boppin", Utilities.generateArray(16, 29), 24, false);
		gf.playAnim("danceLeft");
        gf.visible = false;
		add(gf);

		titleEnter.frames = FunkinAssets.getSparrow("title/pressEnter");
		titleEnter.addAnimByPrefix("idle", "Press Enter to Begin", 24, true);
		titleEnter.addAnimByPrefix("press", "ENTER PRESSED", 24, true);
		titleEnter.playAnim("idle");
        titleEnter.visible = false;
		add(titleEnter);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
			if (alreadySkipped)
				skipIntro();
		});
	}

	function startIntro()
	{
		if (!startedIntro)
		{
			FlxG.sound.playMusic(freakyMenu);
			FlxG.sound.music.fadeIn(4, 0, 0.7);

			startedIntro = true;
			add(credGroup);
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = FunkinAssets.getText(Paths.txt('data/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('~~'));
		}

		return swagGoodArray;
	}

	var confirmed:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (UIControls.justPressed("ACCEPT"))
		{
			if (!skippedIntro)
				skipIntro();
			else
			{
				if (!confirmed)
				{
					confirmed = true;

					titleEnter.animation.play('press');
					FlxG.sound.play(FunkinAssets.getSound(Paths.sound('menus/confirmMenu')));
					FlxG.camera.flash(FlxColor.WHITE, 2);

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						switchState(new MainMenu());
					});
				}
			}
		}

		if (startedIntro || skippedIntro)
		{
			if (FlxG.sound.music != null && FlxG.sound.music.playing)
				Conductor.position = FlxG.sound.music.time;
			else
				Conductor.position += FlxG.elapsed * 1000;
		}
	}

	override public function beatHit()
	{
		super.beatHit();

		danceLeft = !danceLeft;
		if (danceLeft)
			gf.playAnim("danceLeft", true);
		else
			gf.playAnim("danceRight", true);

		logo.playAnim("bump", true);

		if (!skippedIntro)
		{
			switch(Conductor.currentBeat)
			{
				case 1:
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
				case 3:
					addMoreText('present');
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(['In association', 'with']);
				case 7:
					addMoreText('newgrounds');
					ngSpr.visible = true;
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				case 9:
					createCoolText([curWacky[0]]);
				case 11:
					addMoreText(curWacky[1]);
				case 12:
					deleteCoolText();
				case 13:
					addMoreText('Friday');
				case 14:
					addMoreText('Night');
				case 15:
					addMoreText('Funkin');
				case 16:
					skipIntro();
			}
		}
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			addMoreText(textArray[i]);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text.toUpperCase(), true, false);
		coolText.screenCenter(X);
		coolText.y += (credGroup.length * 60) + 200;
		credGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (credGroup.members.length > 0)
		{
			credGroup.remove(credGroup.members[0], true);
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			alreadySkipped = true;

			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;

			gf.visible = true;
			logo.visible = true;
			titleEnter.visible = true;
		}
	}
}

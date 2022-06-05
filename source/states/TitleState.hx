package states;

import base.Conductor;
import base.Controls;
import base.MusicBeat.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.ds.StringMap;
import ui.Alphabet;

class TitleState extends MusicBeatState
{
	var freakyMenu:Dynamic;
	var alphabet:Alphabet;
	var credGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = ["???", "???"];

	public static var startedIntro:Bool = false;

	public static var alreadySkipped:Bool = false;

	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	
	override public function create()
	{
		super.create();

        persistentUpdate = true;
        persistentDraw = true;

		freakyMenu = GenesisAssets.getAsset('freakyMenu', MUSIC);

		Conductor.changeBPM(102);
		Conductor.songPosition = 0;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// ng logo
		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(GenesisAssets.getAsset('title/newgrounds', IMAGE));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = Init.getOption('anti-aliasing');

		// load gf
		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = GenesisAssets.getAsset('title/gfTitle', SPARROW);
		gfDance.animation.addByPrefix('danceLeft', 'danceLeft', 24, false);
		gfDance.animation.addByPrefix('danceRight', 'danceRight', 24, false);
		gfDance.antialiasing = Init.getOption('anti-aliasing');
		gfDance.visible = false;
		add(gfDance);

		logo = new FlxSprite(-150, -100);
		logo.frames = GenesisAssets.getAsset('title/fnfLogo', SPARROW);
		logo.antialiasing = Init.getOption('anti-aliasing');
		logo.animation.addByPrefix('bump', 'bump', 24, false);
		logo.animation.play('bump');
		logo.updateHitbox();
		logo.visible = false;
		add(logo);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = GenesisAssets.getAsset('title/titleEnter', SPARROW);
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = Init.getOption('anti-aliasing');
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.visible = false;
		add(titleText);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
			if(alreadySkipped)
				skipIntro();
		});
	}

	function startIntro()
	{
		if(!startedIntro)
		{
			FlxG.sound.playMusic(freakyMenu);
			FlxG.sound.music.fadeIn(4, 0, 0.7);

			startedIntro = true;
			add(credGroup);
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = GenesisAssets.getAsset('data/introText.txt', TEXT);

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var confirmed:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(Controls.isPressed("ACCEPT", JUST_PRESSED))
		{
			if(!skippedIntro)
				skipIntro();
			else
			{
				if(!confirmed)
				{
					confirmed = true;
					
					titleText.animation.play('press');
					FlxG.sound.play(GenesisAssets.getAsset('menus/confirmMenu', SOUND));
					FlxG.camera.flash(FlxColor.WHITE, 2);

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						States.switchState(this, new MainMenu());
					});
				}
			}
		}

		if(startedIntro || skippedIntro)
		{
			if(FlxG.sound.music != null && FlxG.sound.music.playing)
				Conductor.songPosition = FlxG.sound.music.time;
			else
				Conductor.songPosition += FlxG.elapsed * 1000;
		}
	}

	override public function beatHit()
	{
		super.beatHit();

		danceLeft = !danceLeft;
		if(danceLeft)
			gfDance.animation.play("danceLeft", true);
		else
			gfDance.animation.play("danceRight", true);

		logo.animation.play("bump", true);
		
		if(!skippedIntro)
		{
			switch(curBeat)
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

			gfDance.visible = true;
			logo.visible = true;
			titleText.visible = true;
		}
	}
}

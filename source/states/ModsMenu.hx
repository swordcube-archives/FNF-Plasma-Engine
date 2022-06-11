package states;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
#if MODS_ALLOWED
import base.Controls;
import base.MusicBeat.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef ModInfoJSON =
{
	var name:String;
	var description:String;
	var enabledByDefault:Bool;
	var color:String;
};

class ModsMenu extends MusicBeatState
{
	var menuBG:FlxSprite;

	var scrollMenu:Dynamic;
	var cancelMenu:Dynamic;

	var grpMods:FlxTypedGroup<ModSelection>;

	static var curSelected:Int = 0;

	override public function create()
	{
		super.create();

		if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			FlxG.sound.playMusic(GenesisAssets.getAsset('freakyMenu', MUSIC));

		scrollMenu = GenesisAssets.getAsset('menus/scrollMenu', SOUND);
		cancelMenu = GenesisAssets.getAsset('menus/cancelMenu', SOUND);

		menuBG = new FlxSprite().loadGraphic(GenesisAssets.getAsset('menuBGDesat', IMAGE));
		add(menuBG);

		grpMods = new FlxTypedGroup<ModSelection>();
		add(grpMods);

		var i:Int = 0;
		var modsDirectory = FileSystem.readDirectory('${GenesisAssets.cwd}mods');
		for (file in modsDirectory)
		{
			if (!file.contains("."))
			{
				if (FileSystem.exists('${GenesisAssets.cwd}mods/$file/modInfo.json'))
				{
					var mod:ModSelection = new ModSelection(0, 20 + (i * 150), file);
					mod.targetY = i;
					mod.screenCenter(X);
					grpMods.add(mod);
					i++;
				}
			}
		}

		changeSelection();
	}

	var physicsUpdateTimer:Float = 0;

	function physicsUpdate()
	{
		menuBG.color = FlxColor.interpolate(menuBG.color, FlxColor.fromString(grpMods.members[curSelected].json.color), 0.045);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		physicsUpdateTimer += elapsed;
		if (physicsUpdateTimer > 1 / 60)
		{
			physicsUpdate();
			physicsUpdateTimer = 0;
		}

		if (Controls.isPressed("BACK", JUST_PRESSED))
		{
			FlxG.sound.play(cancelMenu);
			States.switchState(this, new MainMenu());
		}

		if (Controls.isPressed("UI_UP", JUST_PRESSED))
			changeSelection(-1);

		if (Controls.isPressed("UI_DOWN", JUST_PRESSED))
			changeSelection(1);

		if (Controls.isPressed("ACCEPT", JUST_PRESSED))
		{
			var enabled = GenesisAssets.getModActive(grpMods.members[curSelected].mod);
			GenesisAssets.setModActive(grpMods.members[curSelected].mod, !enabled);
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = grpMods.members.length - 1;
		if (curSelected > grpMods.members.length - 1)
			curSelected = 0;

		var i:Int = 0;
		grpMods.forEachAlive(function(m:ModSelection)
		{
			if (curSelected == i)
				m.alpha = 1;
			else
				m.alpha = 0.6;
			m.targetY = i - curSelected;
			i++;
		});

		FlxG.sound.play(scrollMenu);
	}
}

class ModSelection extends FlxSpriteGroup
{
	public var mod:String;

	public var bg:FlxSprite;
	public var icon:FlxSprite;

	public var targetY:Int = 0;

	public var json:ModInfoJSON;

	public var toggledBG:FlxSprite;
	public var toggledText:FlxText;

	public function new(x:Float, y:Float, ?mod:String = "")
	{
		super(x, y);

		this.mod = mod;

		json = Json.parse(File.getContent('${GenesisAssets.cwd}mods/$mod/modInfo.json'));

		var width:Float = FlxG.width / 1.1;
		var height:Float = 300;

		bg = new FlxSprite().makeGraphic(Std.int(width), Std.int(height), FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawRoundRect(bg, 0, 0, Std.int(width), Std.int(height), 15, 15, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

		var iconIMG:Dynamic;

		if (GenesisAssets.exists('modIcon.png', MOD_ICON, mod))
		{
			trace('modIcon.png exists for $mod!');
			iconIMG = GenesisAssets.getAsset('modIcon.png', MOD_ICON, mod);
		}
		else
		{
			trace('mod_icon.png doesn\'t exist for $mod.');
			iconIMG = GenesisAssets.getAsset('ui/modsMenu/modIcon', IMAGE);
		}

		var icon = new FlxSprite().loadGraphic(iconIMG);
		icon.setGraphicSize(150, 150);
		icon.updateHitbox();
		add(icon);

		icon.setPosition(bg.x + 20, bg.y + 20);

		var modName:FlxText = new FlxText(icon.x + (icon.width + 20), 20, 0, json.name, 48);
		modName.setFormat(GenesisAssets.getAsset('vcr.ttf', FONT), 48, FlxColor.WHITE, LEFT);
		add(modName);

		var modDesc:FlxText = new FlxText(modName.x, 70, bg.width - (icon.width + 20), json.description, 24);
		modDesc.setFormat(GenesisAssets.getAsset('vcr.ttf', FONT), 24, FlxColor.WHITE, LEFT);
		add(modDesc);

		// TOGGLED INDICATOR

		var width:Float = 150;
		var height:Float = 50;

		toggledBG = new FlxSprite().makeGraphic(Std.int(width), Std.int(height), FlxColor.WHITE);
		toggledBG.color = FlxColor.RED;
		toggledBG.setPosition(bg.x + (bg.width - (width + 20)), 0 + (bg.height - (height)));
		add(toggledBG);

		toggledText = new FlxText(toggledBG.x, toggledBG.y, width, '[ OFF ]', 28);
		toggledText.setFormat(GenesisAssets.getAsset('vcr.ttf', FONT), 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		toggledText.borderSize = 2;
		add(toggledText);

		refreshToggled();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		y = FlxMath.lerp(y, 50 + (targetY * 350), elapsed * 9.4);

		refreshToggled();
	}

	function refreshToggled()
	{
		toggledBG.color = GenesisAssets.getModActive(mod) ? FlxColor.fromString("#46c780") : FlxColor.fromString("#c74646");
		toggledText.text = GenesisAssets.getModActive(mod) ? "[ ON ]" : "[ OFF ]";
		toggledText.setPosition(toggledBG.x, toggledBG.y + (toggledText.height / 4));
	}
}
#end

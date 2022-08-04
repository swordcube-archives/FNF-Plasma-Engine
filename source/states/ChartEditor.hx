package states;

import cpp.Int16;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.util.FlxAxes;
import gameplay.Note;
import gameplay.Song;
import openfl.media.Sound;
import sys.FileSystem;
import systems.MusicBeat;
import systems.UIControls;

class ChartEditor extends MusicBeatState
{
    public static var current:ChartEditor;
    public static var stateClass:Class<FlxState> = states.PlayState;

    public var grids:Array<CharterGrid> = [];

    public var SONG:Song;

    public var curSection:Int = 0;
    public var hasVocals:Bool = true;

    public var vocals:FlxSound = new FlxSound();

    public var loadedSong:Map<String, Sound> = [];

    function leaveMenu()
    {
        FlxG.sound.music.stop();
        vocals.stop();
        
        Main.switchState(Type.createInstance(stateClass, []));
    }

    override function create()
    {
        current = this;
        super.create();

        if(PlayState.SONG != null)
            SONG = PlayState.SONG;
        else
            SONG = SongLoader.getJSON("tutorial", "hard");

        grids = [
            new CharterGrid(-1),
            new CharterGrid(0),
            new CharterGrid(1),
        ];

        loadedSong.set("inst", FNFAssets.returnAsset(SOUND, AssetPaths.songInst(SONG.song)));
		hasVocals = FileSystem.exists(AssetPaths.songVoices(SONG.song));
		if(hasVocals)
		{
            loadedSong.set("voices", FNFAssets.returnAsset(SOUND, AssetPaths.songVoices(SONG.song)));
            vocals.loadEmbedded(loadedSong.get("voices"), false);
        }

        var bg:FlxSprite = new FlxSprite().loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image("menuBGDesat")));
        bg.scrollFactor.set();
        bg.alpha = 0.2;
        add(bg);

        grids[1].screenCenter();
        add(grids[1]);

        grids[0].setPosition(grids[1].grid.x, grids[1].grid.y - grids[1].grid.height);
        grids[0].grid.alpha = 0.6;
        add(grids[0]);

        grids[2].setPosition(grids[1].grid.x, grids[1].grid.y + grids[1].grid.height);
        grids[2].grid.alpha = 0.6;
        add(grids[2]);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(UIControls.justPressed("BACK"))
            leaveMenu();
    }
}

class CharterGrid extends FlxGroup
{
    var sectionOffset:Int = 0;

    public var grid:FlxSprite;
    var gridSize:Int = 40;

    public var notes:FlxTypedSpriteGroup<Note>;

    public function new(sectionOffset:Int = 0, gridSize:Int = 40)
    {
        super();
        this.gridSize = gridSize;
        this.sectionOffset = sectionOffset;

        var funnySection:Int = Std.int(FlxMath.bound(ChartEditor.current.curSection + sectionOffset, 0, ChartEditor.current.SONG.notes.length-1));
        
        grid = FlxGridOverlay.create(gridSize, gridSize, gridSize * (ChartEditor.current.SONG.keyCount * 2), gridSize * ChartEditor.current.SONG.notes[funnySection].lengthInSteps);
        add(grid);

        notes = new FlxTypedSpriteGroup<Note>();
        add(notes);
    }

    public function refreshGrid()
    {
        var funnySection:Int = Std.int(FlxMath.bound(ChartEditor.current.curSection + sectionOffset, 0, ChartEditor.current.SONG.notes.length-1));

        remove(grid, true);
        grid.kill();
        grid.destroy();
        
        grid = FlxGridOverlay.create(gridSize, gridSize, gridSize * (ChartEditor.current.SONG.keyCount * 2), gridSize * ChartEditor.current.SONG.notes[funnySection].lengthInSteps);
        add(grid);
    }

    public function setPosition(X:Float, Y:Float)
    {
        grid.setPosition(X, Y);
        notes.setPosition(X, Y);
    }

    public function screenCenter(axes:FlxAxes = XY)
    {
        grid.screenCenter(axes);
        notes.setPosition(grid.x, grid.y);
    }
}
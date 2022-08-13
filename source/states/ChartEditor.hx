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
import systems.Conductor;
import systems.MusicBeat;
import systems.UIControls;

class ChartEditor extends MusicBeatState {
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

    public function sectionStartTime(?curSection:Int):Float
    {
        if(curSection == null)
            curSection = this.curSection;

        var daBPM:Float = SONG.bpm;
        var daPos:Float = 0;

        for (i in 0...curSection)
        {
            if (SONG.notes[i].changeBPM && SONG.notes[i].bpm != daBPM)
                daBPM = SONG.notes[i].bpm;

            daPos += (16 / Conductor.timeScale[1]) * (1000 * (60 / daBPM));
        }

        return daPos;
    }

    override function create()
    {
        current = this;
        super.create();

        if(PlayState.SONG != null)
            SONG = PlayState.SONG;
        else
            SONG = SongLoader.getJSON("tutorial", "hard");

		Conductor.changeBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);

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

        grids[0].updateNotes();
        grids[1].updateNotes();
        grids[2].updateNotes();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(UIControls.justPressed("BACK"))
            leaveMenu();
    }
}

class CharterGrid extends FlxGroup {
    public function getYfromStrum(strumTime:Float, ?baseGrid:FlxSprite):Float
    {
        if(baseGrid == null)
            baseGrid = ChartEditor.current.grids[1].grid;

        return FlxMath.remapToRange(strumTime, 0, ((16 / Conductor.timeScale[1]) * Conductor.timeScale[0]) * Conductor.stepCrochet, baseGrid.y, baseGrid.y + baseGrid.height);
    }

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

    public function updateNotes()
    {
        var s:Int = ChartEditor.current.curSection + sectionOffset;
        
        if(ChartEditor.current.SONG.notes[s] != null)
        {
            for (i in ChartEditor.current.SONG.notes[s].sectionNotes)
            {
                var daNoteInfo = i[1];
                var daStrumTime = i[0];
                var daSus = i[2];

                var note:Note = new Note(daStrumTime, daNoteInfo % ChartEditor.current.SONG.keyCount);

                note.setGraphicSize(gridSize, gridSize);
                note.updateHitbox();

                note.x = grid.x + Math.floor(daNoteInfo * gridSize);
                note.y = Math.floor(getYfromStrum((daStrumTime - ChartEditor.current.sectionStartTime(s)) % (Conductor.stepCrochet * ChartEditor.current.SONG.notes[s].lengthInSteps), grid));

                note.rawNoteData = daNoteInfo;

                notes.add(note);
            }
        }
    }

    public function setPosition(X:Float, Y:Float)
    {
        grid.setPosition(X, Y);
    }

    public function screenCenter(axes:FlxAxes = XY)
    {
        grid.screenCenter(axes);
    }
}
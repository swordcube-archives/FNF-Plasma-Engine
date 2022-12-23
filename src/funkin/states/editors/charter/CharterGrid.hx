package funkin.states.editors.charter;

import flixel.math.FlxPoint;
import funkin.system.PlayerControls;
import funkin.system.PlayerPrefs;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.math.FlxMath;
import flixel.math.FlxMath.remapToRange as remap;
import funkin.game.Note;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class CharterGrid extends FlxTypedGroup<Dynamic> {
    public var charter:ChartingState = cast FlxG.state;

    public var onChangeSection:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

    // Shortcuts to variables from the charter.
    var SONG(get, set):Song;
    function get_SONG() {
        return charter.SONG;
    }
    function set_SONG(value:Song) {
        return charter.SONG = value;
    }

    var curSection(get, set):Int;
    function get_curSection() {
        return charter.curSelectedSection;
    }
    function set_curSection(value:Int) {
        return charter.curSelectedSection = value;
    }

    // Shortcuts to player settings shit
    var prefs(get, null):PlayerPrefs;
    function get_prefs() {
        return PlayerSettings.prefs;
    }

    var controls(get, null):PlayerControls;
    function get_controls() {
        return PlayerSettings.controls;
    }

    // Size of the grid squares
    public final gridSize:Int = 40;
    public var noteSnap:Int = 16;

    public var stepLength:Int = 16;

    // Grid variables
    public var grid:FlxSprite;
    public var strumLine:FlxSprite;

    public var selectedSquare:FlxSprite;

    public var notes:FlxTypedGroup<Note>;
    public var sustains:FlxTypedGroup<FlxSprite>;

    public var currentNote:SectionNote;

    public var selectedPos:FlxPoint = new FlxPoint();

    public function new(keyAmount:Int, stepLength:Int) {
        super();
        this.stepLength = stepLength;

        // Create the grid
        grid = FlxGridOverlay.create(gridSize, gridSize, gridSize * (keyAmount * 2) + gridSize, gridSize * stepLength);
		grid.screenCenter();
		add(grid);

        selectedSquare = new FlxSprite().makeGraphic(gridSize, gridSize);
        add(selectedSquare);

        // Create the group of notes
        add(notes = new FlxTypedGroup<Note>());
        add(sustains = new FlxTypedGroup<FlxSprite>());

        // Create the strum line
        strumLine = new FlxSprite(grid.x, grid.y).makeGraphic(1, 4);
		strumLine.scale.x = grid.width;
		strumLine.updateHitbox();
		add(strumLine);

        // Allow the section to reload when changed
        onChangeSection.add(function(section:Int) {
            reloadSection();
        });

        // Load the current section
        reloadSection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // Position the white square that indicates what grid space
        // we are hovering over to the mouse
        var mousePos:FlxPoint = FlxG.mouse.getPosition();
        mousePos.subtract(grid.x, grid.y);

        selectedPos.set(Math.floor(mousePos.x / gridSize), Math.floor(mousePos.y / gridSize));
        var coolSnap:Int = Math.floor(gridSize / (noteSnap / 16.0));

        if(FlxG.keys.pressed.SHIFT)
            selectedSquare.setPosition(selectedPos.x * gridSize, mousePos.y);
        else
            selectedSquare.setPosition(selectedPos.x * gridSize, Math.floor(mousePos.y / coolSnap) * coolSnap);

        selectedSquare.x += grid.x;
        selectedSquare.y += grid.y;

        // Adding/removing notes
        if(FlxG.mouse.justPressed) {
            if(selectedPos.x >= 0 && selectedPos.x <= (SONG.keyAmount * 2)) {
                if(selectedPos.y >= 0 && selectedPos.y <= stepLength) {
                    var note:SectionNote = addNote(selectedPos.x, selectedPos.y);
                    if(note != null) currentNote = note;
                }
            }
        }
    }

    public function updateGrid(keyAmount:Int, stepLength:Int) {
        this.stepLength = stepLength;

        // Remove previously displayed grid
        grid.kill();
        grid.destroy();
        remove(grid, true);

        // Create new grid
        grid = FlxGridOverlay.create(gridSize, gridSize, gridSize * (keyAmount * 2) + gridSize, gridSize * stepLength);
		grid.screenCenter();
		add(grid);

        // Update the strumline
        strumLine.x = grid.x;
        strumLine.scale.x = grid.width;
		strumLine.updateHitbox();

        // Reload the section
        reloadSection();
    }

    public function reloadSection() {
        // Remove previously displayed notes
        for(note in notes.members) {
            note.kill();
            note.destroy();
        }
        notes.clear();

        for(note in sustains.members) {
            note.kill();
            note.destroy();
        }
        notes.clear();

        // Make sure we don't end up in a null section
        if(curSection > SONG.sections.length - 1) {
            while(curSection > SONG.sections.length - 1) {
                var previousSection:Section = CoolUtil.last(SONG.sections);
                SONG.sections.push({
                    notes: [],
                    playerSection: previousSection != null ? previousSection.playerSection : false,
                    lengthInSteps: previousSection != null ? previousSection.lengthInSteps : 16,
                    changeBPM: previousSection != null ? previousSection.changeBPM : false,
                    bpm: previousSection != null ? previousSection.bpm : 0,
                    altAnim: previousSection != null ? previousSection.altAnim : false,
                });
            }
        }

        // Spawn the notes
        for(note in SONG.sections[curSection].notes)
            spawnNote(note.direction + 1, timeToY(note.strumTime - sectionStartTime()), note.sustainLength, note.type);
    }

    function spawnNote(x:Float, y:Null<Float>, sustainLength:Float, type:String) {
        if(y == null) y = selectedSquare.y;
        else y += grid.y;

        var mousePos:FlxPoint = FlxG.mouse.getPosition();
        mousePos.subtract(grid.x, grid.y);

        var newNote:Note = new Note(0, SONG.keyAmount, Std.int(x - 1) % SONG.keyAmount, null, false, type);
        newNote.setPosition(x * gridSize, y);
        newNote.x += grid.x;
        newNote.setGraphicSize(gridSize);
        newNote.noteScale = newNote.scale.x;
        newNote.playCorrectAnim();

        if(sustainLength > 0) {
            var sustain:FlxSprite = new FlxSprite(newNote.x + (gridSize / 2), newNote.y).makeGraphic(8, 1);
            sustain.scale.y = Math.floor(remap(sustainLength, 0, Conductor.stepCrochet * 16, 0, stepLength * gridSize)) / newNote.scale.y;
            sustain.updateHitbox();
            sustain.x -= sustain.width / 2;
            sustains.add(sustain);
            newNote.charterParentSustain = sustain;
        }
        
        notes.add(newNote);
        return newNote;
    }

    function addNote(x:Float, y:Float):Null<SectionNote> {
        var mousePos:FlxPoint = FlxG.mouse.getPosition();
        mousePos.subtract(grid.x, grid.y);

        for(note in notes.members) {
            if(selectedPos.x * gridSize == (note.x - grid.x)) {
                if(mousePos.y >= (note.y - grid.y) && mousePos.y <= (note.y - grid.y) + gridSize) {
                    for(noteObj in SONG.sections[curSection].notes) {
                        if(noteObj.direction == Std.int(x - 1)) {
                            if(Std.int(noteObj.strumTime) == Std.int(yToTime(note.y - grid.y) + sectionStartTime()))
                                SONG.sections[curSection].notes.remove(noteObj);
                        }
                    }

                    note.kill();
                    note.destroy();
                    notes.remove(note, true);
                    if(note.charterParentSustain != null) {
                        note.charterParentSustain.kill();
                        note.charterParentSustain.destroy();
                        sustains.remove(note, true);
                    }
                    return null;
                }
            }
        }

        var note:Note = spawnNote(x, null, 0, charter.currentNoteType);
        note.alpha = 0.5;

        var strumTime:Float = yToTime(selectedSquare.y - grid.y) + sectionStartTime();
        var direction:Int = Std.int(x - 1);

        SONG.sections[curSection].notes.push({
            strumTime: strumTime,
            direction: direction,
            sustainLength: 0.0,
            type: charter.currentNoteType,
            altAnim: false
        });

        return SONG.sections[curSection].notes.last();
    }

    function yToTime(y:Float) {
		return remap(y + gridSize, grid.y, grid.y + (16 * gridSize), 0, 16 * Conductor.stepCrochet);
    }
	function timeToY(time:Float) {
		return remap(time - Conductor.stepCrochet, 0, 16 * Conductor.stepCrochet, grid.y, grid.y + (16 * gridSize));
    }
    function sectionStartTime(?section:Null<Int>) {
        if(section == null) section = curSection;
        var coolPos:Float = 0.0;
        var goodBPM = Conductor.bpm;
        
        for(i in 0...section) {
            if(SONG.sections[i] != null) {
                if(SONG.sections[i].changeBPM)
                    goodBPM = SONG.sections[i].bpm;
            }
            coolPos += 4 * (1000 * (60 / goodBPM));
        }
        
        return coolPos;
    }
}
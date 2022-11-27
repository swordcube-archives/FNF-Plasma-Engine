package funkin.states;

import funkin.scripting.events.SimpleNoteEvent;
import flixel.util.FlxStringUtil;
import haxe.io.Path;
import funkin.ui.HealthIcon;
import funkin.game.Note;
import funkin.system.ChartParser;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using StringTools;

class ChartingState extends FNFState {
	var _file:FileReference;

	var UI_box:FlxUITabMenu;
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
    var strumLineCam:FlxSprite;

	var curSong:String = 'Test';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	var SONG:Song;

	var typingShit:FlxInputText;
	var curSelectedNote:SectionNote;

	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var currentNoteType:String = "Default";

	override function create() {
		super.create();

		if (PlayState.SONG != null)
			SONG = PlayState.SONG;
		else {
			SONG = {
				name: 'Test',
				sections: [],
				bpm: 150,
				bf: 'bf',
				dad: 'dad',
                gf: 'gf',
                stage: 'default',
                keyAmount: 4,
				scrollSpeed: 1,
                events: [],
				needsVoices: true
			};
		}

		if(SONG.stage == null) SONG.stage = "default";

        var bg:FlxSprite = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image("menuBGNeo")));
        bg.alpha = 0.2;
        bg.scrollFactor.set();
        add(bg);

        FlxG.camera.followLerp = 1;
        
		curSection = lastSection;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, (GRID_SIZE * (SONG.keyAmount * 2)) + GRID_SIZE, GRID_SIZE * 16);
		add(gridBG);

        var gridBG2 = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, (GRID_SIZE * (SONG.keyAmount * 2)) + GRID_SIZE, GRID_SIZE * 16);
        gridBG2.y = gridBG.y + gridBG.height;
        gridBG2.alpha = 0.3;
		add(gridBG2);

        var gridBG3 = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, (GRID_SIZE * (SONG.keyAmount * 2)) + GRID_SIZE, GRID_SIZE * 16);
        gridBG3.y = gridBG.y - gridBG.height;
        gridBG3.alpha = 0.3;
		add(gridBG3);

		for(grid in [gridBG, gridBG2, gridBG3]) grid.x -= GRID_SIZE;

		leftIcon = new HealthIcon().loadIcon(SONG.dad);
		rightIcon = new HealthIcon().loadIcon(SONG.bf);
		leftIcon.scrollFactor.set(1, 0);
		rightIcon.scrollFactor.set(1, 0);

		leftIcon.setGraphicSize(0, 65);
		rightIcon.setGraphicSize(0, 65);

		leftIcon.setPosition(0, 30);
		rightIcon.setPosition((gridBG.width / 2) - (GRID_SIZE / 2), 30);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + (GRID_SIZE * SONG.keyAmount) + GRID_SIZE).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		FlxG.mouse.visible = true;

		tempBpm = SONG.bpm;

		addSection();

		loadSong(SONG.name);
		Conductor.bpm = SONG.bpm;
		Conductor.mapBPMChanges(SONG);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(gridBG.width), 4);
		add(strumLine);

        strumLineCam = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width/2), 4);
        strumLineCam.alpha = 0.001;
        add(strumLineCam);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Charting", label: 'Charting'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addChartingUI();
        updateGrid();

		check_playerSection.checked = SONG.sections[0].playerSection;
        updateHeads();

		add(curRenderedNotes);
		add(curRenderedSustains);
        add(leftIcon);
		add(rightIcon);

        Conductor.position = 0;
        FlxG.sound.music.time = 0;
	}

	var hitsoundsOpponent:FlxUICheckBox;
	var hitsoundsPlayer:FlxUICheckBox;

	function addChartingUI() {
		hitsoundsOpponent = new FlxUICheckBox(10, 10, null, null, "Enable Hitsounds (Opponent)", 100);
		hitsoundsOpponent.checked = false;

		hitsoundsPlayer = new FlxUICheckBox(10, 40, null, null, "Enable Hitsounds (Player)", 100);
		hitsoundsPlayer.checked = false;

		var tab_groupCharting = new FlxUI(null, UI_box);
		tab_groupCharting.name = "Charting";

		tab_groupCharting.add(hitsoundsOpponent);
		tab_groupCharting.add(hitsoundsPlayer);
		
		UI_box.addGroup(tab_groupCharting);
	}

	function addSongUI():Void {
		var UISONGTitle = new FlxUIInputText(10, 10, 70, SONG.name, 8);
		typingShit = UISONGTitle;

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function() {
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function() {
			saveLevel();
		});
		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function() {
			loadSong(SONG.name);
		});
		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function() {
			loadJson(SONG.name.toLowerCase());
		});
		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = SONG.scrollSpeed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 9999, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var characters:Array<String> = [];
		for(item in CoolUtil.readDirectoryFoldersOnly("data/characters")) {
			characters.push(item);
		}

		var stages:Array<String> = [];
        for(item in CoolUtil.readDirectory("data/stages")) {
			if(Paths.scriptExtensions.contains("."+Path.extension(item)))
				stages.push(item.split("."+Path.extension(item))[0]);
		}

		var dadDropDown = new FlxUIDropDownMenu(10, 125, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String) {
			SONG.dad = characters[Std.parseInt(character)];
            updateHeads();
		});
		dadDropDown.selectedLabel = SONG.dad;

		var opponentText:FlxText = new FlxText(dadDropDown.x, dadDropDown.y - 15, 0, "Opponent");

		var bfDropDown = new FlxUIDropDownMenu(140, 125, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String) {
			SONG.bf = characters[Std.parseInt(character)];
            updateHeads();
		});
		bfDropDown.selectedLabel = SONG.bf;

		var playerText:FlxText = new FlxText(bfDropDown.x, bfDropDown.y - 15, 0, "Player");

		var gfDropDown = new FlxUIDropDownMenu(10, 165, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String) {
			SONG.gf = characters[Std.parseInt(character)];
		});
		gfDropDown.selectedLabel = SONG.gf;

		var gfText:FlxText = new FlxText(gfDropDown.x, gfDropDown.y - 15, 0, "Girlfriend");
		
		var stageDropDown = new FlxUIDropDownMenu(140, 165, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String) {
			SONG.stage = stages[Std.parseInt(stage)];
		});
		stageDropDown.selectedLabel = SONG.stage;

		var stageText:FlxText = new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, "Stage");

		var tab_groupSONG = new FlxUI(null, UI_box);
		tab_groupSONG.name = "Song";
		tab_groupSONG.add(UISONGTitle);

		tab_groupSONG.add(check_mute_inst);
		tab_groupSONG.add(saveButton);
		tab_groupSONG.add(reloadSong);
		tab_groupSONG.add(reloadSongJson);
		tab_groupSONG.add(loadAutosaveBtn);
		tab_groupSONG.add(stepperBPM);
		tab_groupSONG.add(stepperSpeed);
		tab_groupSONG.add(opponentText);
		tab_groupSONG.add(playerText);
		tab_groupSONG.add(gfText);
		tab_groupSONG.add(stageText);
		tab_groupSONG.add(gfDropDown);
		tab_groupSONG.add(stageDropDown);
		tab_groupSONG.add(dadDropDown);
		tab_groupSONG.add(bfDropDown);

		UI_box.addGroup(tab_groupSONG);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLineCam);
	}

	var stepperLength:FlxUINumericStepper;
	var check_playerSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void {
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = SONG.sections[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function() {
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function() {
			for (i in 0...SONG.sections[curSection].notes.length) {
				var note = SONG.sections[curSection].notes[i];
				note.direction = (note.direction + SONG.keyAmount) % (SONG.keyAmount*2);
				SONG.sections[curSection].notes[i] = note;
				updateGrid();
			}
		});

		check_playerSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_playerSection.name = 'check_mustHit';
		check_playerSection.checked = true;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_playerSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	function addNoteUI():Void {
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 1024);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);

		var noteTypeText:FlxText = new FlxText(stepperSusLength.x, stepperSusLength.y + 15, 0, "Note Type");
		var noteTypes:Array<String> = [];
		for(item in CoolUtil.readDirectory("data/scripts/note_types")) {
			if(Paths.scriptExtensions.contains("."+Path.extension(item)))
				noteTypes.push(item.split("."+Path.extension(item))[0]);
		}

		var noteTypeDropDown = new FlxUIDropDownMenu(noteTypeText.x, noteTypeText.y + 15, FlxUIDropDownMenu.makeStrIdLabelArray(noteTypes, true), function(type:String) {
			currentNoteType = noteTypes[Std.parseInt(type)];
			if(curSelectedNote != null) curSelectedNote.type = currentNoteType;
			updateGrid();
		});
		noteTypeDropDown.selectedLabel = currentNoteType;

		tab_group_note.add(noteTypeText);
		tab_group_note.add(noteTypeDropDown);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.playMusic(Assets.load(SOUND, Paths.inst(daSong)));
		FlxG.sound.music.pitch = 1;

		vocals = new FlxSound().loadEmbedded(Assets.load(SOUND, Paths.voices(daSong)));
		FlxG.sound.list.add(vocals);
        vocals.play();

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function() {
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void {
		while (bullshitUI.members.length > 0) {
            bullshitUI.members[0].destroy();
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if (id == FlxUICheckBox.CLICK_EVENT) {
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label) {
				case 'Must hit section':
					SONG.sections[curSection].playerSection = check.checked;

					updateHeads();

				case 'Change BPM':
					SONG.sections[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					SONG.sections[curSection].altAnim = check.checked;
			}
		} else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length') {
				SONG.sections[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			} else if (wname == 'song_speed')
				SONG.scrollSpeed = nums.value;
			else if (wname == 'song_bpm') {
				tempBpm = nums.value;
				Conductor.mapBPMChanges(SONG);
				Conductor.bpm = nums.value;
			} else if (wname == 'note_susLength') {
				curSelectedNote.sustainLength = nums.value;
				updateGrid();
			} else if (wname == 'section_bpm') {
				SONG.sections[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
		}
	}

	var updatedSection:Bool = false;

	function sectionStartTime():Float {
		var daBPM:Float = SONG.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection) {
			if (SONG.sections[i].changeBPM)
				daBPM = SONG.sections[i].bpm;
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

    var lastConductorPos:Float = 0;
	override function update(elapsed:Float) {
		super.update(elapsed);

        FlxG.camera.followLerp = 1;
		Conductor.position = FlxG.sound.music.time;
		SONG.name = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.position - sectionStartTime()) % (Conductor.stepCrochet * SONG.sections[curSection].lengthInSteps));
        strumLineCam.y = strumLine.y + 200;
        @:privateAccess
        FlxG.camera.scroll.y = FlxG.camera._scrollTarget.y;

		if (Conductor.curBeat % 4 == 0 && Conductor.curStep >= 16 * (curSection + 1)) {
			if (SONG.sections[curSection + 1] == null)
				addSection();

			changeSection(curSection + 1, false);
            if(FlxG.sound.music.playing) {
                FlxG.sound.music.pause();
                vocals.pause();
                FlxG.sound.music.time = Conductor.position;
                vocals.time = Conductor.position;
                vocals.play();
                FlxG.sound.music.play();
            }
        }

        if(Conductor.position < sectionStartTime()) {
            changeSection(curSection - 1, false);
            if(FlxG.sound.music.playing) {
                FlxG.sound.music.pause();
                vocals.pause();
                FlxG.sound.music.time = Conductor.position;
                vocals.time = Conductor.position;
                vocals.play();
                FlxG.sound.music.play();
            }
        }

		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.overlaps(curRenderedNotes)) {
				curRenderedNotes.forEach(function(note:Note) {
					if (FlxG.mouse.overlaps(note)) {
						if (FlxG.keys.pressed.CONTROL)
							selectNote(note);
						else
							deleteNote(note);
					}
				});
			} else {
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * SONG.sections[curSection].lengthInSteps))
					addNote();
			}
		}
		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * SONG.sections[curSection].lengthInSteps)) {
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}
		if (FlxG.keys.justPressed.ENTER) {
			lastSection = curSection;
			PlayState.SONG = SONG;
			FlxG.sound.music.stop();
			vocals.stop();
            FlxG.mouse.visible = false;
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
			changeNoteSustain(Conductor.stepCrochet);
		if (FlxG.keys.justPressed.Q)
			changeNoteSustain(-Conductor.stepCrochet);

		if (FlxG.keys.justPressed.TAB) {
			if (FlxG.keys.pressed.SHIFT) {
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			} else {
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}
		if (!typingShit.hasFocus) {
			if (FlxG.keys.justPressed.SPACE) {
				if (FlxG.sound.music.playing) {
					FlxG.sound.music.pause();
					vocals.pause();
				} else {
                    FlxG.sound.music.time = Conductor.position;
                    vocals.time = Conductor.position;
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R) {
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0) {
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;

                if(FlxG.sound.music.time < 0)
                    FlxG.sound.music.time = 0;

                if(Conductor.position < 0)
                    Conductor.position = 0;
			}

			if (!FlxG.keys.pressed.SHIFT) {
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) {
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
						FlxG.sound.music.time -= daTime;
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			} else {
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S) {
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
						FlxG.sound.music.time -= daTime;
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		SONG.bpm = tempBpm;

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = FlxStringUtil.formatTime(Conductor.position / 1000)
			+ " / "
			+ FlxStringUtil.formatTime(FlxG.sound.music.length / 1000)
			+ "\nSection: "
			+ curSection
			+ "\nBeat: "
			+ Conductor.curBeat
			+ "\nStep: "
			+ Conductor.curStep;

        var playedSound:Array<Bool> = [for(i in 0...SONG.keyAmount) false]; // hit sound bull shit
        for(note in curRenderedNotes.members) {
            note.alpha = 1;
			if(note.strumTime <= Conductor.position) {
				note.alpha = 0.4;
                if(note.strumTime > lastConductorPos && FlxG.sound.music.playing && note.direction > -1) {
					if(!playedSound[note.direction % SONG.keyAmount]) {
						if((hitsoundsOpponent.checked && !note.mustPress) || (hitsoundsPlayer.checked && note.mustPress))
                        	FlxG.sound.play(Assets.load(SOUND, Paths.sound("hitsound")), 0.65);
                        playedSound[note.direction % SONG.keyAmount] = true;
					}
                }
            }
        }

        lastConductorPos = Conductor.position;
	}

	function changeNoteSustain(value:Float):Void {
		if (curSelectedNote != null) {
			curSelectedNote.sustainLength += value;
			curSelectedNote.sustainLength = Math.max(curSelectedNote.sustainLength, 0);
		}

		updateNoteUI();
		updateGrid();
	}

	function resetSection(songBeginning:Bool = false):Void {
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning) {
			FlxG.sound.music.time = 0;
			curSection = 0;
		}
		vocals.time = FlxG.sound.music.time;

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void {
		if (SONG.sections[sec] != null) {
			curSection = sec;

			if (updateMusic) {
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
			}

			updateGrid();
			updateSectionUI();
            strumLine.y = getYfromStrum((Conductor.position - sectionStartTime()) % (Conductor.stepCrochet * SONG.sections[sec].lengthInSteps));
            strumLineCam.y = strumLine.y + 200;
            @:privateAccess
            FlxG.camera.scroll.y = FlxG.camera._scrollTarget.y;
		}
	}

	function copySection(?sectionNum:Int = 1) {
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in SONG.sections[daSec - sectionNum].notes) {
			var strum = note.strumTime + Conductor.stepCrochet * (SONG.sections[daSec].lengthInSteps * sectionNum);
			SONG.sections[daSec].notes.push({
				strumTime: strum,
				direction: note.direction,
				sustainLength: note.sustainLength,
				type: note.type,
				altAnim: note.altAnim
			});
		}

		updateGrid();
	}

	function updateSectionUI():Void {
		var sec = SONG.sections[curSection];
		stepperLength.value = sec.lengthInSteps;
		check_playerSection.checked = sec.playerSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void {
		if (check_playerSection.checked) {
			leftIcon.loadIcon(SONG.bf);
            rightIcon.loadIcon(SONG.dad);
		} else {
			leftIcon.loadIcon(SONG.dad);
            rightIcon.loadIcon(SONG.bf);
		}
        leftIcon.offset.set();
        rightIcon.offset.set();
	}

	function updateNoteUI():Void {
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote.sustainLength;
	}

	function updateGrid():Void {
		while (curRenderedNotes.members.length > 0) {
            curRenderedNotes.members[0].destroy();
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}
		while (curRenderedSustains.members.length > 0) {
            curRenderedSustains.members[0].destroy();
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		if (SONG.sections[curSection].changeBPM && SONG.sections[curSection].bpm > 0)
			Conductor.bpm = SONG.sections[curSection].bpm;
		else {
			// get last bpm
			var daBPM:Float = SONG.bpm;
			for (i in 0...curSection)
				if (SONG.sections[i].changeBPM)
					daBPM = SONG.sections[i].bpm;
			Conductor.bpm = daBPM;
		}

        var sectionsToFuck:Array<Int> = [
            curSection-1,
            curSection,
            curSection+1
        ];

        var gridHeights:Array<Float> = [
            -gridBG.height,
            0,
            gridBG.height
        ];

        for(sex in sectionsToFuck) {
            if(SONG.sections[sex] == null) continue;
            var sectionInfo:Array<SectionNote> = SONG.sections[sex].notes;

            for (i in sectionInfo) {
                var daNoteInfo = i.direction;
                var daStrumTime = i.strumTime;
                var daSus = i.sustainLength;

                var note:Note = new Note(daStrumTime, SONG.keyAmount, daNoteInfo % SONG.keyAmount, null, false, i.type);
				var gottaHitNote:Bool = SONG.sections[sex].playerSection;
				if (daNoteInfo > (SONG.keyAmount - 1))
					gottaHitNote = !SONG.sections[sex].playerSection;
				note.mustPress = gottaHitNote;
                note.rawStrumTime = daStrumTime;
                note.rawDirection = daNoteInfo;
                note.strumTime = daStrumTime;
                note.sustainLength = daSus;
                note.x = Math.floor(daNoteInfo * GRID_SIZE);
                note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * SONG.sections[sex].lengthInSteps)));
                var guh = gridHeights[sectionsToFuck.indexOf(sex)];
                note.y += guh;
                if(guh != 0)
                    note.alpha = 0.3;

				note.script.event("onNoteCreation", new SimpleNoteEvent(note));
				note.setGraphicSize(GRID_SIZE);
                note.updateHitbox();
				note.noteScale = note.scale.x;
				note.playAnim("normal");
                curRenderedNotes.add(note);

                if (daSus > 0) {
                    var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
                        note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
                    sustainVis.x -= sustainVis.width/2;
                    curRenderedSustains.add(sustainVis);
                }
            }
        }
	}

	function addSection(lengthInSteps:Int = 16):Void {
		var sec:Section = {
			lengthInSteps: lengthInSteps,
			bpm: SONG.bpm,
			changeBPM: false,
			playerSection: true,
			notes: [],
			altAnim: false
		};

		SONG.sections.push(sec);
	}

	function selectNote(note:Note):Void {
		var swagNum:Int = 0;

		for (i in SONG.sections[curSection].notes) {
			if (i.strumTime == note.strumTime && i.direction % 4 == note.direction)
				curSelectedNote = SONG.sections[curSection].notes[swagNum];

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void {
		for (i in SONG.sections[curSection].notes) {
			if (i.strumTime == note.rawStrumTime && i.direction == note.rawDirection)
				SONG.sections[curSection].notes.remove(i);
		}

		updateGrid();
	}

	function clearSection():Void {
		SONG.sections[curSection].notes = [];
		updateGrid();
	}

	function clearSong():Void {
		for (daSection in 0...SONG.sections.length)
			SONG.sections[daSection].notes = [];

		updateGrid();
	}

	function addNote():Void {
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;

		SONG.sections[curSection].notes.push({
			strumTime: noteStrum,
			direction: noteData,
			sustainLength: noteSus,
			type: currentNoteType,
			altAnim: false
		});

		curSelectedNote = SONG.sections[curSection].notes[SONG.sections[curSection].notes.length - 1];

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float {
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	var daSpacing:Float = 0.3;

	function getNotes():Array<Dynamic> {
		var noteData:Array<Dynamic> = [];

		for (i in SONG.sections)
			noteData.push(i.notes);

		return noteData;
	}

	function loadJson(song:String):Void {
		PlayState.SONG = ChartParser.loadSong(AUTO, song, PlayState.curDifficulty);
		FlxG.resetState();
	}

	function loadAutosave():Void {
		PlayState.SONG = ChartParser.loadFromText(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void {
		FlxG.save.data.autosave = Json.stringify({
			"song": SONG
		});
		FlxG.save.flush();
	}

	function saveLevel() {
		var json = {
			"song": SONG
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0)) {
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), SONG.name.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
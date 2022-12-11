package funkin.game;

import funkin.scripting.Script;
import flixel.text.FlxText;
import funkin.system.FNFSprite;
import flixel.tweens.FlxTween;
import funkin.game.Ranking.Judgement;
import funkin.states.PlayState;
import funkin.scripting.events.NoteHitEvent;
import flixel.util.FlxSort;
import openfl.events.KeyboardEvent;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * A class for handling note input.
 */
@:dox(hide)
class NoteInput implements IFlxDestroyable {
	var closestNotes:Array<Note> = [];
	var parent:StrumLine;

	public var pressed:Array<Bool> = [];

	public function new(parent:StrumLine) {
		this.parent = parent;
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onJustPressed);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onJustReleased);
	}

    function noteSorting(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function onJustPressed(evt:KeyboardEvent) {
        if(parent.isOpponent || PlayerSettings.prefs.get("Botplay") || PlayState.paused) return;

		@:privateAccess
		var key:Int = evt.keyCode;
		var binds = PlayerSettings.controls.list['GAME_${parent.keyAmount}'];

		var data:Int = -1;
		switch (evt.keyCode) {
			case 37: data = 0;
			case 40: data = 1;
			case 38: data = 2;
			case 39: data = 3;
		}

		for (i in 0...binds.length) {
			if (binds[i] == key) {
				data = i;
				break;
			}
		}

		var dontHit:Array<Bool> = [for(i in 0...parent.keyAmount) false];
		if (data == -1 || pressed[data]) return;
		pressed[data] = true;
		var receptor = parent.receptors.members[data];
		var rgb = PlayerSettings.prefs.get('NOTE_COLORS_${parent.keyAmount}')[data];
		receptor.colorShader.setColors(rgb[0], rgb[1], rgb[2]);
		receptor.playAnim("press");

		closestNotes = [];

		parent.notes.forEachAlive(function(daNote:Note) {
			if (!dontHit[daNote.direction] && !daNote.tooLate && daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit) {
				dontHit[daNote.direction] = true;
				closestNotes.push(daNote);
			}
		});

		closestNotes.sort(noteSorting);

		var dataNotes = [];
		for (i in closestNotes)
			if (i.direction == data && !i.isSustainNote)
				dataNotes.push(i);

		if (dataNotes.length > 0) {
			var coolNote = null;
			for (i in dataNotes) {
				coolNote = i;
				break;
			}
			if (dataNotes.length > 1) {
				for (i in 0...dataNotes.length) {
					if (i == 0) continue;
					var note = dataNotes[i];
                    // stacked notes
					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 5) && note.direction % parent.keyAmount == data) {
						note.kill();
						parent.notes.remove(note, true);
						note.destroy();
					}
				}
			}
			goodNoteHit(coolNote);
		}
	}

	public function goodNoteHit(note:Note) {
		note.wasGoodHit = true;
		var receptor = parent.receptors.members[note.direction];
		var rgb = PlayerSettings.prefs.get('NOTE_COLORS_${parent.keyAmount}')[note.direction];
		receptor.colorShader.setColors(rgb[0], rgb[1], rgb[2]);
		if(PlayerSettings.prefs.get("Botplay")) {
			receptor.animation.finishCallback = function(name:String) {
				if(name == "confirm") {
					receptor.colorShader.setColors(255, 0, 0);
					receptor.playAnim("static");
				}
			}
		}
        receptor.playAnim("confirm");
		PlayState.current.vocals.volume = 1;
		if(note.doSingAnim) {
			var chars:Array<Character> = (PlayerSettings.prefs.get("Play As Opponent") && !PlayState.isStoryMode) ? PlayState.current.dads : PlayState.current.bfs;
			for(c in chars) {
				if(c != null && !c.specialAnim) {
					c.holdTimer = 0;
					var suffix:String = note.altAnim ? "-alt" : "";
					var anim:String = c.getSingAnim(parent.keyAmount, note.direction)+suffix;
					if(!c.animation.exists(anim)) anim = c.getSingAnim(parent.keyAmount, note.direction);
					c.playAnim(anim, true);
				}
			}
		}
		PlayState.current.combo++;
		popUpScore(note, PlayState.current.combo);

		var eventGlobal = PlayState.current.scripts.event("onPlayerHit", new NoteHitEvent(note, Ranking.judgeNote(note.strumTime)));
		var event = PlayState.current.noteScriptMap[note.type].event("onPlayerHit", new NoteHitEvent(note, Ranking.judgeNote(note.strumTime)));

		if(!event.cancelled && !eventGlobal.cancelled) {
			note.kill();
			parent.notes.remove(note, true);
			note.destroy();
		}
	}

	public function popUpScore(note:Note, combo:Int) {
		var prefs = PlayerSettings.prefs;

		var judgement:String = PlayerSettings.prefs.get("Botplay") ? Ranking.judgements[0].name : Ranking.judgeNote(note.strumTime);
		var judgeData:Judgement = Ranking.getInfo(judgement);
		var placement:String = Std.string(combo);

		var game = PlayState.current;
		game.score += Math.floor(judgeData.score * (Conductor.rate >= 1 ? 1 : Conductor.rate));
		game.totalNotes++;
		game.totalHit += judgeData.mod;
		game.health += game.healthGain + judgeData.health;
		if(game.health > game.maxHealth) game.health = game.maxHealth;
		game.UI.updateScoreText();

		switch(judgement) {
			case "sick": game.sicks++;
			case "good": game.goods++;
			case "bad":  game.bads++;
			case "shit": game.shits++;
		}
		game.UI.updateJudgementText();

		var coolText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

        var rating = new FNFSprite(0, 0);
        if(PlayState.current.showRating) {
            rating.loadGraphic(Assets.load(IMAGE, Paths.image('game/judgements/${game.ratingSkin}/$judgement')));
            rating.antialiasing = game.ratingAntialiasing;
            rating.screenCenter();
            rating.x = coolText.x - 40;
            rating.y -= 60;
            
            rating.scale.set(game.ratingScale, game.ratingScale);
            rating.updateHitbox();

            rating.acceleration.y = 550;
            rating.velocity.y -= FlxG.random.int(140, 175);
            rating.velocity.x -= FlxG.random.int(0, 10);
			switch(prefs.get("Judgement Camera")) {
				case "HUD":
					PlayState.current.UI.add(rating);
				default:
					PlayState.current.insert(PlayState.current.members.length-1, rating);
			}
        }

        if(PlayState.current.showCombo) {
            var seperatedScore:Array<String> = placement.split("");
            while(seperatedScore.length < 3) seperatedScore.insert(0, "0");
            var daLoop:Int = 0;
            for (i in seperatedScore) {
                var numScore = new FNFSprite();
                numScore.loadGraphic(Assets.load(IMAGE, Paths.image('game/combo/${game.comboSkin}/num$i')));
                numScore.screenCenter();
                numScore.x = coolText.x + (43 * daLoop) - 90;
                numScore.y += 80;
                numScore.antialiasing = game.comboAntialiasing;

                numScore.scale.set(game.comboScale, game.comboScale);
                numScore.updateHitbox();

                numScore.acceleration.y = FlxG.random.int(200, 300);
                numScore.velocity.y -= FlxG.random.int(140, 160);
                numScore.velocity.x = FlxG.random.float(-5, 5);
				switch(prefs.get("Judgement Camera")) {
					case "HUD":
						PlayState.current.UI.add(numScore);
					default:
						PlayState.current.insert(PlayState.current.members.length-1, numScore);
				}

                FlxTween.tween(numScore, {alpha: 0}, 0.2, {
                    onComplete: function(tween:FlxTween) {
                        numScore.destroy();
                    },
                    startDelay: Conductor.crochet * 0.002
                });
                daLoop++;
            }
        }
        
        if(PlayState.current.showRating) {
            FlxTween.tween(rating, {alpha: 0}, 0.2, {
                onComplete: function(twn:FlxTween) {
                    rating.destroy();
                },
                startDelay: Conductor.crochet * 0.001
            });
        }

		if(prefs.get("Enable Note Splashes") && note.canSplash && judgeData.noteSplash) {
			var receptor = parent.receptors.members[note.direction];
			var rgb:Array<Int> = [
				Std.int(note.colorShader.color.value[0]),
				Std.int(note.colorShader.color.value[1]),
				Std.int(note.colorShader.color.value[2]),
			];
			var splash = new NoteSplash(receptor.x, receptor.y, rgb, parent.keyAmount, note.directionName, note.splashSkin);
			splash.x -= parent.x;
			splash.y -= parent.y;
			parent.noteSplashes.add(splash);
		}
	}

	function onJustReleased(evt:KeyboardEvent) {
        if(parent.isOpponent || PlayerSettings.prefs.get("Botplay") || PlayState.paused) return;

		@:privateAccess
		var key:Int = evt.keyCode;
		var binds = PlayerSettings.controls.list['GAME_${parent.keyAmount}'];

		var data:Int = -1;
		switch (evt.keyCode) {
			case 37: data = 0;
			case 40: data = 1;
			case 38: data = 2;
			case 39: data = 3;
		}

		for (i in 0...binds.length) {
			if (binds[i] == key) {
				data = i;
				break;
			}
		}
		if (data == -1) return;
		pressed[data] = false;
		var receptor = parent.receptors.members[data];
		receptor.colorShader.setColors(255, 0, 0);
        receptor.playAnim("static");
    }

	public function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onJustPressed);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onJustReleased);
	}
}

package funkin.ui.playstate;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import funkin.game.FunkinSprite;
import funkin.game.PlayState;
import funkin.systems.Conductor;
import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import funkin.ui.playstate.StrumNote.ArrowSkin;
import haxe.Json;
import lime.math.Vector2;

/**
    A class for displaying shit like "SiCK!!" and your combo when hitting a note.
**/
class RatingDisplay extends FlxGroup
{
    var skin:String = "default";

    var combo:Int = 0;
    var rating:FunkinSprite = new FunkinSprite(0, 0);

    var comboNumbers:Array<FunkinSprite> = [
        new FunkinSprite(0, 0),
        new FunkinSprite(0, 0),
        new FunkinSprite(0, 0),
        new FunkinSprite(0, 0),
    ];

    var json:ArrowSkin;

    public function new(judgement:String = "marvelous", combo:Int = 0)
    {
        super();

        this.combo = combo;

        json = Json.parse(FunkinAssets.getText(Paths.json('images/ui/skins/$skin/config')));

        var center:Vector2 = new Vector2(FlxG.width * 0.55, FlxG.height/2);
        
        rating.loadGraphic(FunkinAssets.getImage(Paths.image('ui/skins/${PlayState.instance.uiSkin}/ratings/$judgement')));
        rating.scale.set(json.ratingScale, json.ratingScale);
        rating.updateHitbox();
        rating.screenCenter(Y);
        rating.antialiasing = json.skinType != "pixel";

        // Adjust the position a bit
		rating.x = center.x - 40;
		rating.y -= 60;

        // Make the rating have physics
		rating.acceleration.y = 550;
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.velocity.y -= FlxG.random.int(140, 175);

        // Add the rating
        add(rating);

        // Make the rating disappear eventually
		FlxTween.tween(rating, {alpha: 0}, 0.2, {
            onComplete: function(twn:FlxTween) {
                remove(rating, true);
                rating.kill();
                rating.destroy();
            },
			startDelay: Conductor.crochet * 0.001
		});

        // The combo but it's an array!!!!1
		var seperatedCombo:Array<Int> = [];

		seperatedCombo.push(Math.floor(combo / 100));
		seperatedCombo.push(Math.floor((combo - (seperatedCombo[0] * 100)) / 10));
		seperatedCombo.push(combo % 10);

        // Generate each number and add them
        var daLoop:Int = 0;
        for(i in seperatedCombo)
        {
			var numScore:FunkinSprite = new FunkinSprite();
            numScore.loadGraphic(FunkinAssets.getImage(Paths.image('ui/skins/${PlayState.instance.uiSkin}/combo/num$i')));
			numScore.screenCenter();
			numScore.x = center.x + (43 * daLoop) - 90;
			numScore.y += 80;

            numScore.antialiasing = json.skinType != "pixel";
			numScore.scale.set(json.comboScale, json.comboScale);
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
            numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.velocity.y -= FlxG.random.int(140, 160);

			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
                    remove(numScore, true);
                    numScore.kill();
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

            daLoop++;
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if(members.length <= 0)
        {
            kill();
            destroy();
        }
    }
}
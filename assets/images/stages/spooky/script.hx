var halloweenBG = null;
var thunder1 = null;
var thunder2 = null;

var lightningStrikeBeat = 0;
var lightningOffset = 8;

function create()
{
    Stage.removeDefaultStage();
    PlayState.defaultCamZoom = 1.05;

    thunder1 = FunkinAssets.getSound(Paths.sound('thunder_1'));
    thunder2 = FunkinAssets.getSound(Paths.sound('thunder_2'));

    halloweenBG = new FunkinSprite(-200, -100);
    halloweenBG.frames = FunkinAssets.getSparrow('stages/spooky/halloween_bg');
    halloweenBG.addAnimByPrefix('static', 'halloweem bg0', 24, true);
    halloweenBG.addAnimByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
    halloweenBG.playAnim('static');
    Stage.addSprite(halloweenBG, 'BACK');
}

function beatHit(curBeat)
{
    if(FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
        lightningStrikeShit(curBeat);
}

function lightningStrikeShit(curBeat)
{
    if(FlxG.random.int(1, 2) == 2)
        FlxG.sound.play(thunder2);
    else
        FlxG.sound.play(thunder1);

    halloweenBG.playAnim('lightning');

    lightningStrikeBeat = curBeat;
    lightningOffset = FlxG.random.int(8, 24);

    gf.playAnim('scared', true);
    bf.playAnim('scared', true);
}
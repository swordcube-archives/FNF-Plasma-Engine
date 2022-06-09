var halloweenBG = null;
var thunder1 = null;
var thunder2 = null;

var lightningStrikeBeat = 0;
var lightningOffset = 8;

function create()
{
    Stage.removeDefaultStage();
    PlayState.instance.defaultCamZoom = 1.05;

    thunder1 = GenesisAssets.getSound('thunder_1');
    thunder2 = GenesisAssets.getSound('thunder_2');

    halloweenBG = new FNFSprite(-200, -100);
    halloweenBG.frames = GenesisAssets.getSparrow('stages/spooky/halloween_bg');
    halloweenBG.animation.addByPrefix('static', 'halloweem bg0', 24, true);
    halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
    halloweenBG.animation.play('static');
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

    halloweenBG.animation.play('lightning');

    lightningStrikeBeat = curBeat;
    lightningOffset = FlxG.random.int(8, 24);

    gf.playAnim('scared', true);
    bf.playAnim('scared', true);
}
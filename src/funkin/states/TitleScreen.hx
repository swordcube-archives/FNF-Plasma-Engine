package funkin.states;

import base.Conductor;

class TitleScreen extends FunkinState {
    var logo:Sprite;
    var gf:Sprite;

    var danced:Bool = true;

    override function create() {
        super.create();

        logo = new Sprite(-150, -100).load(SPARROW, Paths.image("menus/title/logo"));
        logo.addAnim("idle", "logo bumpin");
        logo.playAnim("idle");
        add(logo);

        gf = new Sprite(FlxG.width * 0.4, FlxG.height * 0.07).load(SPARROW, Paths.image("menus/title/gf"));
        gf.addAnimByIndices("danceL", "GF dancing", [for(i in 0...14) i]);
        gf.addAnimByIndices("danceR", "GF dancing", [for(i in 14...29) i]);
        gf.playAnim("danceL");
        add(gf);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        Conductor.position += elapsed * 1000;
    }

    override function beatHit(curBeat:Int) {
        super.beatHit(curBeat);

        danced = !danced;
        logo.playAnim("idle", true);
        gf.playAnim("dance"+(danced ? "L" : "R"));
    }
}
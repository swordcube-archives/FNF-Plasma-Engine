package funkin.gameplay;

import shaders.ColorShader;
import funkin.events.NoteHitEvent;
import scripting.HScriptModule;
import scripting.Script;
import scripting.ScriptModule;

class NoteSplash extends Sprite {
    var skin:String = "Default";
    var script:ScriptModule;
    public var useRGBShader:Bool = false;
    public var colorShader:ColorShader = new ColorShader(255, 0, 0);

    public function new(x:Float, y:Float, skin:String = "Default", event:NoteHitEvent) {
        super(x, y);
        this.skin = skin;
        script = Script.create(Paths.script('data/scripts/note_splashes/$skin'));
        script.set("skin", skin);
        if(Std.isOfType(script, HScriptModule)) cast(script, HScriptModule).setScriptObject(this);
        script.start(true, [event, Note.keyInfo[event.note.parent.keyCount].directions[event.note.direction]]);
        if(useRGBShader) {
            var rgb = event.note.colorShader.color.value;
            colorShader.setColors(Std.int(rgb[0]), Std.int(rgb[1]), Std.int(rgb[2]));
            shader = colorShader;
        }
    }

    override public function destroy() {
        script.destroy();
        super.destroy();
    }
}
package funkin.gameplay;

import funkin.gameplay.Note.NoteSkin;
import misc.RGBFormat;
import shaders.ColorShader;

class StrumNote extends Sprite {
    public var noteData:Int = 0;
    public var json:NoteSkin = null;

    public var parent:StrumLine;
    public var colorShader:ColorShader = new ColorShader(255, 0, 0);

    public function new(x:Float, y:Float, noteData:Int) {
        super(x, y);
        this.noteData = noteData;
        shader = colorShader;
        colorShader.enabled.value = [false];
    }

    public function loadSkin(skin:String) {
        json = Note.noteSkins[skin];
        var direction:String = Note.noteDirections[parent.keyAmount-1][noteData];
        
        frames = Assets.get(SPARROW, Paths.image(json.image_location));
        animation.addByPrefix("static", direction+" static0", json.framerate, false);
        animation.addByPrefix("press", direction+" press0", json.framerate, false);
        animation.addByPrefix("confirm", direction+" confirm0", json.framerate, false);

        scale.set(json.strum_scale * Note.noteScales[parent.keyAmount-1], json.strum_scale * Note.noteScales[parent.keyAmount-1]);
        updateHitbox();

        playAnim("static");

        if(!json.use_color_shader)
            shader = null;
        else
            shader = colorShader;

        antialiasing = json.skin_type != "pixel" ? Settings.get("Antialiasing") : false;

        setColors();
    }

    public function setColors() {
        var color:RGBFormat = {
            r: Settings.noteColors[parent.keyAmount-1][noteData][0],
            g: Settings.noteColors[parent.keyAmount-1][noteData][1],
            b: Settings.noteColors[parent.keyAmount-1][noteData][2]
        };
        colorShader.setColors(color.r, color.g, color.b);
    }

    override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
    {
        super.playAnim(name, force, reversed, frame);

		centerOrigin();

		if (json.skin_type != "pixel")
		{
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;

			var scale = json.strum_scale * Note.noteScales[parent.keyAmount-1];

			offset.x -= 156 * (scale / 2);
			offset.y -= 156 * (scale / 2);
		}
		else
			centerOffsets();
    }
}
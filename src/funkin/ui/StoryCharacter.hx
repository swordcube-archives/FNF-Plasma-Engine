package funkin.ui;

import haxe.xml.Access;
import flixel.math.FlxPoint;
import funkin.system.FNFSprite;

using StringTools;

class StoryCharacter extends FNFSprite {
	public var character:String;

	/**
		The X and Y offset of this character's position.
	**/
	public var positionOffset:FlxPoint = new FlxPoint(0, 0);

	/**
	 * Allows you to have multiple animations when the character dances.
	 */
	public var danceSteps:Array<String> = ["idle"];
	public var curDanceStep:Int = 0;

	public var canDance:Bool = true;

	public function new(x:Float, y:Float, character:String = 'bf') {
		super(x, y);
		loadCharacter(character);
	}

	public function loadCharacter(character:String) {
		if(this.character == character) return this;
		this.character = character;

		if(character == "") {
			visible = false;
			return this;
		}
		visible = true;

		while(true) {
			var xml:Xml = Xml.parse(Assets.load(TEXT, Paths.xml('data/story_characters/$character/config'))).firstElement();
			if(xml == null) {
				Console.error('Occured on story character: $character | Either the XML doesn\'t exist or the "character" node is missing!');
				break;
			}
			var data:Access = new Access(xml);

			var atlasType:String = "SPARROW";
			if(data.has.atlasType) atlasType = data.att.atlasType;
			var spritesheetName:String = data.has.spritesheet ? data.att.spritesheet : "spritesheet";
			switch(atlasType.toLowerCase()) {
				case "packer":
					frames = Assets.load(PACKER, Paths.image('data/story_characters/$character/$spritesheetName', false));
				default:
					frames = Assets.load(SPARROW, Paths.image('data/story_characters/$character/$spritesheetName', false));
			}
			antialiasing = data.has.antialiasing ? (data.att.antialiasing == 'true' ? PlayerSettings.prefs.get("Antialiasing") : false) : PlayerSettings.prefs.get("Antialiasing");
			flipX = data.att.flip_x == "true";

			// Load animations
			var animations_node:Access = data.node.animations; // <- This is done to make the code look cleaner (aka instead of data.node.animations.nodes.animation)

			for (anim in animations_node.nodes.animation) {
				// Add the animation
				if (anim.has.indices && anim.att.indices.split(",").length > 1)
					animation.addByIndices(anim.att.name, anim.att.anim, CoolUtil.splitInt(anim.att.indices, ","), "", Std.parseInt(anim.att.fps),
						anim.att.looped == "true");
				else
					animation.addByPrefix(anim.att.name, anim.att.anim, Std.parseInt(anim.att.fps), anim.att.looped == "true");

				setOffset(anim.att.name, -Std.parseFloat(anim.att.offsetX), -Std.parseFloat(anim.att.offsetY));
			}

			// Load miscellaneous attributes

			// Create variables for cleaner code first
			var global_pos:Access = data.node.global_pos;
			var scale:Access = data.node.scale;

			// Set the actual properties
			positionOffset.set(Std.parseFloat(global_pos.att.offsetX), Std.parseFloat(global_pos.att.offsetY));

			this.scale.set(Std.parseFloat(scale.att.x), Std.parseFloat(scale.att.y));
			updateHitbox();

			// Dance Steps moment
			danceSteps = data.has.dance_steps ? data.att.dance_steps.split(",") : ["idle"];
			for (i in 0...danceSteps.length) danceSteps[i] = danceSteps[i].trim();

			break;
		}
		dance();

		return this;
	}

	override function playAnim(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		super.playAnim(anim, force, reversed, frame);

		if(animation.exists(anim) && offsets.exists(anim)) {
			var daOffset = offsets.get(anim);
			rotOffset.set(daOffset.x, daOffset.y);
		}

		offset.set(-positionOffset.x, -positionOffset.y);
	}

	var danced:Bool = false;

	public function dance() {
		if(!canDance) return;
		danced = !danced;

		if (danceSteps.length > 1) {
			if (curDanceStep > danceSteps.length - 1) curDanceStep = 0;
			playAnim(danceSteps[curDanceStep]);
			curDanceStep++;
		} else {
			if(danceSteps.length > 0)
				playAnim(danceSteps[0]);
		}
	}
}

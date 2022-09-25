# Information about this folder
Put .hx, .hxs, .hsc, or .hscript files to make a `ScriptedSprite`.

A `ScriptedSprite` is an `FlxSprite` that runs a script when loaded.

You can animate the sprites, tween them, anything really. This is so you don't have to do it in a weird way in a script.
You just make a walking animation or something then use the sprite when needed.

How to create a new `ScriptedSprite`:
```haxe
// "ScriptedSpriteName" is the name of the .hxs file.
// [arg1, arg2, arg3] is the arguments your sprite can use.
// 100, 500 are the X and Y positions of your sprite.
var mySprite = new ScriptedSprite("ScriptedSpriteName", [arg1, arg2, arg3], 100, 500);
mySprite.cameras = [PlayState.camHUD];
PlayState.add(mySprite);
```
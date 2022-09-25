# Information about this folder.
Put folders into this folder named something like `my-super-cool-character`.

Then in that new folder, add the following files:
`script.hxs`
`spritesheet.png`
`spritesheet.xml`

Then put this example script into `script.hxs`:
```haxe
function create() {
    frames = FNFAssets.getStoryCharacterSparrow("my-super-cool-character");
    scale.set(0.85, 0.85);
    updateHitbox();
    animation.addByPrefix("idle", "idle name", 24, false);
    animation.addByPrefix("confirm", "confirm name", 24, false);

    setOffset("idle");
    setOffset("confirm");

    dance();
}
```
And modify it to your liking!
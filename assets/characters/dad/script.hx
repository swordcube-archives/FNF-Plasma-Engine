function create()
{
    character.frames = FunkinAssets.getCharacterSparrow(character.curCharacter);
    character.singDuration = 6.1;
    character.dancesLeftAndRight = false;
    character.isPlayer = false;

    character.addAnimByPrefix('idle', 'Dad idle dance0', 24, false, [0, 0]);

    character.addAnimByPrefix('singLEFT', 'Dad Sing Note LEFT0', 24, false, [-10, 10]);
    character.addAnimByPrefix('singDOWN', 'Dad Sing Note DOWN0', 24, false, [0, -30]);
    character.addAnimByPrefix('singUP', 'Dad Sing Note UP0', 24, false, [-6, 50]);
    character.addAnimByPrefix('singRIGHT', 'Dad Sing Note RIGHT0', 24, false, [0, 27]);

    character.dance();
}
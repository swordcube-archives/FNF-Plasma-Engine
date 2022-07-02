function create()
{
    character.frames = FunkinAssets.getCharacterSparrow(character.curCharacter);
    character.dancesLeftAndRight = false;
    character.isPlayer = true;

    character.addAnimByPrefix('hey', 'BF HEY!!0', 24, false, [7, 4]);
    character.addAnimByPrefix('idle', 'BF idle dance0', 24, false, [-5, 0]);
    character.addAnimByPrefix('scared', 'BF idle shaking0', 24, false, [-4, 0]);

    character.addAnimByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false, [12, -6]);
    character.addAnimByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false, [-10, -50]);
    character.addAnimByPrefix('singUP', 'BF NOTE UP0', 24, false, [-29, 27]);
    character.addAnimByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false, [-38, -7]);

    character.addAnimByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS0', 24, false, [12, 24]);
    character.addAnimByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS0', 24, false, [-11, -19]);
    character.addAnimByPrefix('singUPmiss', 'BF NOTE UP MISS0', 24, false, [-29, 27]);
    character.addAnimByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS0', 24, false, [-30, 21]);

    character.positionOffset = [0, 350];

    character.dance();
}
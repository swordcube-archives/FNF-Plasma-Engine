function create()
{
    character.frames = FunkinAssets.getCharacterSparrow(character.curCharacter);
    character.dancesLeftAndRight = true;
    character.isPlayer = false;

    character.addAnimByIndices('danceLeft', 'GF Dancing Beat0', Utilities.generateArray(0, 15), 24, false, [0, -9]);
    character.addAnimByIndices('danceRight', 'GF Dancing Beat0', Utilities.generateArray(16, 29), 24, false, [0, -9]);

    character.addAnimByPrefix('singLEFT', 'GF left note0', 24, false, [0, -19]);
    character.addAnimByPrefix('singDOWN', 'GF Down Note0', 24, false, [0, -20]);
    character.addAnimByPrefix('singUP', 'GF Up Note0', 24, false, [0, 4]);
    character.addAnimByPrefix('singRIGHT', 'GF Right Note0', 24, false, [0, -20]);

    character.addAnimByPrefix('scared', 'GF FEAR0', 24, false, [-2, -17]);

    character.dance();
    
}

function updatePost(elapsed)
{
    switch(character.curCharacter)
    {
        case 'gf':
            if (character.animation.curAnim.name == 'hairFall' && character.animation.curAnim.finished)
                character.playAnim('danceRight');
    }
}
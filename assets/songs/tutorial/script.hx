function beatHit(curBeat)
{
    if (curBeat % 16 == 15 && PlayState.instance.dad.curCharacter == "gf" && curBeat > 16 && curBeat < 48)
    {
        PlayState.instance.bf.playAnim('hey', true);
        PlayState.instance.dad.playAnim('cheer', true);
    }

    if (curBeat % 16 == 15 && PlayState.instance.dad.curCharacter != "gf" && curBeat > 16 && curBeat < 48)
    {
        PlayState.instance.bf.playAnim('hey', true);
        PlayState.instance.gf.playAnim('cheer', true);
    }
}
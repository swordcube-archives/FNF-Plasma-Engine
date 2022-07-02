function beatHit(curBeat)
{
    if (curBeat % 8 == 7)
    {
        PlayState.instance.bf.playAnim('hey', true);
        PlayState.instance.bf.specialAnim = true;
    }
}
-- this character is in lua
-- because fuck you that's why
function create()
    loadSparrow('characters/'..curCharacter..'/spritesheet', nil, false)
    setProperty('isPlayer', true)
    setProperty('healthIcon', 'template')

    addAnim('PREFIX', 'idle', 'BF idle dance', 24, false)
    addAnim('PREFIX', 'singUP', 'BF NOTE UP0', 24, false)
    addAnim('PREFIX', 'singLEFT', 'BF NOTE LEFT0', 24, false)
    addAnim('PREFIX', 'singRIGHT', 'BF NOTE RIGHT0', 24, false)
    addAnim('PREFIX', 'singDOWN', 'BF NOTE DOWN0', 24, false)
    addAnim('PREFIX', 'singUPmiss', 'BF NOTE UP MISS', 24, false)
    addAnim('PREFIX', 'singLEFTmiss', 'BF NOTE LEFT MISS', 24, false)
    addAnim('PREFIX', 'singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false)
    addAnim('PREFIX', 'singDOWNmiss', 'BF NOTE DOWN MISS', 24, false)
    addAnim('PREFIX', 'hey', 'BF HEY!!', 24, false)

    setOffset('idle', -5)
    setOffset("singUP", -29, 27)
    setOffset("singRIGHT", -38, -7)
    setOffset("singLEFT", 12, -6)
    setOffset("singDOWN", -10, -50)
    setOffset("singUPmiss", -29, 27)
    setOffset("singRIGHTmiss", -30, 21)
    setOffset("singLEFTmiss", 12, 24)
    setOffset("singDOWNmiss", -11, -19)
    setOffset("hey", 7, 4)

    setProperty('positionOffset.x', 0)
    setProperty('positionOffset.y', 350)
    setProperty('flipX', true)
end
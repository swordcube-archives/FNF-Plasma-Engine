package;

/**
    A class containing utilties used in the game.

    Feel free to take any of these utils and use them yourself!
**/
class Utilities
{
    /**
        A function that auto-generates an array from `startingNumber` to `endingNumber`.
            
        @param startingNumber       The number to start with.
        @param endingNumber         The number to end with.
    **/
    public static function generateArray(startingNumber:Int = 0, endingNumber:Int = 1):Array<Int>
    {
		var a:Array<Int> = [];
		for (i in startingNumber...endingNumber)
			a.push(i);
		return a;
    }
}
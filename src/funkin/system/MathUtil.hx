package funkin.system;

class MathUtil {
	/**
	 * Round a decimal number to have reduced precision (less decimal numbers).
	 *
	 * ```haxe
	 * roundDecimal(1.2485, 2) = 1.25
	 * ```
	 *
	 * @param	Value		Any number.
	 * @param	Precision	Number of decimals the result should have.
	 * @return	The rounded value of that number.
	 */
	public static function roundDecimal(Value:Float, Precision:Int):Float {
		return Math.round(Value * Math.pow(10, Precision)) / Math.pow(10, Precision);
	}
}

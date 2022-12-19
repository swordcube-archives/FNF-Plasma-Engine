package base;

/**
 * A simple class that stores a `width` and `height`.
 */
abstract Size(Array<Float>) to Array<Float> from Array<Float> {
    public var width(get, set):Float;
    
    function get_width():Float {
        return this[0];
    }
    function set_width(v:Float):Float {
        return this[0] = v;
    }

    public var height(get, set):Float;
    
    function get_height():Float {
        return this[1];
    }
    function set_height(v:Float):Float {
        return this[1] = v;
    }

    public function new(width:Float, height:Float) {
        this = [width, height];
    }
}
package funkin.scripting.events;

import funkin.game.NoteInput;
import funkin.game.StrumLine;

class InputSystemEvent extends CancellableEvent {
    /**
     * The strum line used for input.
     */
    public var strumLine:StrumLine;

    /**
     * Some data used for input, Such as pressed, which contains a list of receptors that are being held down.
     * 
     * ```hx
     * pressed[0]
     * ```
     * 
     * For example, Would grab if the first receptor is being held down.
     */
    public var input:NoteInput;

    public function new(strumLine:StrumLine) {
        super();
        this.strumLine = strumLine;
        this.input = strumLine.input;
    }
}
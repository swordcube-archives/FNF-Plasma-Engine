package funkin.scripting.events;

class CancellableEvent {
    @:dox(hide) public var cancelled:Bool = false;
    
    /**
     * Prevents this event from running.
     */
    public function cancel() {
        cancelled = true;
    }

    /**
     * Returns a string representation of the event, in this format:
     * `[CancellableEvent]`
     * `[CancellableEvent (Cancelled)]`
     * @return String
     */
     public function toString():String {
        var claName = Type.getClassName(Type.getClass(this)).split(".");
        var rep = '[${claName[claName.length-1]}${cancelled ? " (Cancelled)" : ""}]';
        return rep;
    }
}
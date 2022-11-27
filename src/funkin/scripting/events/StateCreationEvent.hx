package funkin.scripting.events;

import flixel.FlxState;

class StateCreationEvent extends CancellableEvent {
    /**
     * The state being created.
     */
    public var state:FlxState;

    public function new(state:FlxState) {
        this.state = state;
    }

    public function removeDefault() {
        cancel();
    }
}
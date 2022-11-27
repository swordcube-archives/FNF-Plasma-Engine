package funkin.scripting.events;

import flixel.FlxSubState;

class SubStateCreationEvent extends CancellableEvent {
    /**
     * The state being created.
     */
    public var substate:FlxSubState;

    public function new(substate:FlxSubState) {
        this.substate = substate;
    }

    public function removeDefault() {
        cancel();
    }
}
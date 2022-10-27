package funkin.events;

import funkin.gameplay.Note;
import base.CancellableEvent;

class NoteCreationEvent extends CancellableEvent {
    /**
     * The note that triggered the event.
     * You can change properties about this event's note by changing this variable.
     */
    public var note:Note;
}
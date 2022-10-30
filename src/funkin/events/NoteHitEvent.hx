package funkin.events;

import funkin.gameplay.Note;
import base.CancellableEvent;

/**
 * An event that runs whenever a note is hit.
 */
class NoteHitEvent extends CancellableEvent {
    /**
     * The rating you got from hitting this note.
     */
    public var rating:String = "sick";

    /**
     * The note that triggered the event.
     * You can change properties about this event's note by changing this variable.
     */
    public var note:Note;
}
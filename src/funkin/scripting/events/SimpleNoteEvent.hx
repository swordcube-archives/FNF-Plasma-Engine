package funkin.scripting.events;

import funkin.game.Note;

class SimpleNoteEvent extends CancellableEvent {
    /**
     * The note being created.
     */
    public var note:Note;

    public function new(note:Note) {
        super();
        this.note = note;
    }
}
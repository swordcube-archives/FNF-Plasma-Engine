package funkin.scripting.events;

import funkin.game.Note;

class NoteHitEvent extends CancellableEvent {
    /**
     * The note being created.
     */
    public var note:Note;

    /**
     * The rating that shows up when hitting a note.
     */
    public var rating:String = "sick";

    public function new(note:Note, rating:String) {
        this.note = note;
        this.rating = rating;
    }
}
package base;

class CancellableEvent {
    public var cancelled:Bool = false;
    public function new() {}
    public function cancel() {
        cancelled = true;
    }
}
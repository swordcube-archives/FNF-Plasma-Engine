package funkin.states;

class PlayState extends FunkinState {
    public static var current:PlayState;

    public function new() {
        super();
        current = this;
    }

    override function create() {
        super.create();
        current = this;

        var guh:HealthIcon = new HealthIcon(0, 0, "dad");
        guh.iconHealth = 20;
        add(guh);

        var guh:HealthIcon = new HealthIcon(0, 100, "dad");
        guh.iconHealth = 50;
        add(guh);

        var guh:HealthIcon = new HealthIcon(0, 200, "dad");
        guh.iconHealth = 100;
        add(guh);
    }

    override function destroy() {
        current = null;
        super.destroy();
    }
}
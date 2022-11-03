package funkin.states.options.pages;

class AppearanceMenu extends OptionsPage {
    override function create() {
        super.create();

        for(setting in Settings.settings["Appearance"]) {
            var option = new Option(
                setting.type,
                setting.name,
                setting.desc,
                setting.values,
                setting.limits,
                setting.decimals,
                setting.increment
            );
            option.locked = setting.locked;
            addOption(option);
        }

        changeSelection();
    }
}
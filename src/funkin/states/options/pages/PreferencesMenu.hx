package funkin.states.options.pages;

class PreferencesMenu extends OptionsPage {
    override function create() {
        super.create();

        for(setting in Settings.settings["Preferences"]) {
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
import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "config/Appearance.qml"
    }
    ConfigCategory {
        name: i18n("Provider modules")
        icon: "network-connect"
        source: "config/Modules.qml"
    }
    ConfigCategory {
        name: i18n("Advanced settings")
        icon: "settings-configure"
        source: "config/AdvancedSettings.qml"
    }
}

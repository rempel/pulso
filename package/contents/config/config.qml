// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Sensors")
        icon: "view-list-icons"
        source: "configMetrics.qml"
    }
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "configAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Desktop")
        icon: "preferences-desktop"
        source: "configDesktop.qml"
    }
    ConfigCategory {
        name: i18n("Alerts & popup")
        icon: "preferences-desktop-notification"
        source: "configAlerts.qml"
    }
    ConfigCategory {
        name: i18n("Presets")
        icon: "bookmarks"
        source: "configPresets.qml"
    }
}

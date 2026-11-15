// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.ksysguard.faces as Faces

KCM.SimpleKCM {
    id: page

    property var cfg_sensors: []
    property alias cfg_showIcons: showIcons.checked
    property alias cfg_colorize: colorize.checked
    property alias cfg_hideUnavailable: hideUnavailable.checked
    property alias cfg_updateInterval: updateInterval.value
    property alias cfg_percentWarn: percentWarn.value
    property alias cfg_percentCrit: percentCrit.value
    property alias cfg_tempWarn: tempWarn.value
    property alias cfg_tempCrit: tempCrit.value

    // Plasma also hands every page the default values; declare them to keep the log clean
    property var cfg_sensorsDefault
    property bool cfg_showIconsDefault
    property bool cfg_colorizeDefault
    property bool cfg_hideUnavailableDefault
    property int cfg_updateIntervalDefault
    property int cfg_percentWarnDefault
    property int cfg_percentCritDefault
    property int cfg_tempWarnDefault
    property int cfg_tempCritDefault

    Kirigami.FormLayout {
        // KDE's own sensor picker: search, pick any sensor, drag to reorder
        Faces.Choices {
            id: choices
            Kirigami.FormData.label: i18n("Sensors in the panel:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 18
            supportsColors: false
            labelsEditable: false
            Component.onCompleted: selected = Array.from(page.cfg_sensors)
            onSelectedChanged: {
                // Only write back real changes, so opening the dialog doesn't mark it as modified
                const next = Array.from(selected || []);
                if (JSON.stringify(next) !== JSON.stringify(Array.from(page.cfg_sensors))) {
                    page.cfg_sensors = next;
                }
            }
        }
        QQC2.Label {
            text: i18n("Click to add, drag to reorder.")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox { id: showIcons; Kirigami.FormData.label: i18n("Appearance:"); text: i18n("Show icons") }
        QQC2.CheckBox { id: colorize; text: i18n("Change color above the limits") }
        QQC2.CheckBox { id: hideUnavailable; text: i18n("Hide sensors that are unavailable on this computer") }
        RowLayout {
            Kirigami.FormData.label: i18n("Update every:")
            QQC2.SpinBox { id: updateInterval; from: 500; to: 10000; stepSize: 500 }
            QQC2.Label { text: i18nc("milliseconds", "ms") }
        }

        Item { Kirigami.FormData.isSection: true }

        RowLayout {
            Kirigami.FormData.label: i18n("Percentages (warning / critical):")
            QQC2.SpinBox { id: percentWarn; from: 1; to: 100 }
            QQC2.SpinBox { id: percentCrit; from: 1; to: 100 }
            QQC2.Label { text: "%" }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Temperatures (warning / critical):")
            QQC2.SpinBox { id: tempWarn; from: 30; to: 120 }
            QQC2.SpinBox { id: tempCrit; from: 30; to: 120 }
            QQC2.Label { text: "°C" }
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
// Settings › Alerts & popup: critical-level notifications and the process list.
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_alertsEnabled: alertsEnabled.checked
    property alias cfg_alertSeconds: alertSeconds.value
    property alias cfg_alertCooldown: alertCooldown.value
    property alias cfg_showProcesses: showProcesses.checked
    property alias cfg_processCount: processCount.value

    property bool cfg_alertsEnabledDefault
    property int cfg_alertSecondsDefault
    property int cfg_alertCooldownDefault
    property bool cfg_showProcessesDefault
    property int cfg_processCountDefault

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: alertsEnabled
            Kirigami.FormData.label: i18n("Alerts:")
            text: i18n("Notify me when a sensor stays at the critical level")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("For at least:")
            enabled: alertsEnabled.checked
            QQC2.SpinBox { id: alertSeconds; from: 5; to: 3600; stepSize: 5 }
            QQC2.Label { text: i18n("seconds") }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Then wait:")
            enabled: alertsEnabled.checked
            QQC2.SpinBox { id: alertCooldown; from: 1; to: 240 }
            QQC2.Label { text: i18n("minutes before warning again") }
        }
        QQC2.Label {
            text: i18n("Uses the critical limits from “General”, for percentages and temperatures.")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
            wrapMode: Text.Wrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox {
            id: showProcesses
            Kirigami.FormData.label: i18n("Popup:")
            text: i18n("Show the processes using the most CPU")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("How many:")
            enabled: showProcesses.checked
            QQC2.SpinBox { id: processCount; from: 1; to: 15 }
        }
    }
}

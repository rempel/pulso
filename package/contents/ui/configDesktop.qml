// SPDX-License-Identifier: GPL-3.0-or-later
// Settings › Desktop: how the cards look when the widget sits on the desktop.
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property string cfg_desktopStyle
    property alias cfg_desktopColumns: columns.value
    property alias cfg_desktopHistory: history.value
    property alias cfg_desktopCardBackground: cardBackground.checked

    property string cfg_desktopStyleDefault
    property int cfg_desktopColumnsDefault
    property int cfg_desktopHistoryDefault
    property bool cfg_desktopCardBackgroundDefault

    readonly property var styles: [
        { value: "gauge", text: i18n("Gauge") },
        { value: "graph", text: i18n("History graph") },
        { value: "text",  text: i18n("Big number") }
    ]

    Kirigami.FormLayout {
        Kirigami.InlineMessage {
            Kirigami.FormData.isSection: true
            Layout.fillWidth: true
            visible: true
            text: i18n("These settings apply when Pulso is placed on the desktop. Right-click the desktop → Add Widgets… → Pulso.")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Card style:")
            model: page.styles
            textRole: "text"
            valueRole: "value"
            currentIndex: Math.max(0, page.styles.findIndex(s => s.value === page.cfg_desktopStyle))
            onActivated: page.cfg_desktopStyle = currentValue
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Columns:")
            QQC2.SpinBox { id: columns; from: 0; to: 8 }
            QQC2.Label { text: columns.value === 0 ? i18n("(automatic)") : ""; opacity: 0.7 }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Graph history:")
            QQC2.SpinBox { id: history; from: 10; to: 600; stepSize: 10 }
            QQC2.Label { text: i18n("samples"); opacity: 0.7 }
        }
        QQC2.CheckBox {
            id: cardBackground
            Kirigami.FormData.label: i18n("Cards:")
            text: i18n("Draw a background behind each card")
        }
        QQC2.Label {
            text: i18n("The widget background (standard, translucent or none) is set from the desktop edit mode.")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
            wrapMode: Text.Wrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }
    }
}

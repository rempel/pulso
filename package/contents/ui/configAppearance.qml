// SPDX-License-Identifier: GPL-3.0-or-later
// Settings › Appearance: icons, font, spacing and the history line in the panel.
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_showIcons: showIcons.checked
    property alias cfg_iconSize: iconSize.value
    property string cfg_fontFamily
    property alias cfg_fontSize: fontSize.value
    property alias cfg_fontBold: fontBold.checked
    property alias cfg_itemSpacing: itemSpacing.value
    property alias cfg_panelGraph: panelGraph.checked
    property alias cfg_panelGraphWidth: panelGraphWidth.value

    property bool cfg_showIconsDefault
    property int cfg_iconSizeDefault
    property string cfg_fontFamilyDefault
    property int cfg_fontSizeDefault
    property bool cfg_fontBoldDefault
    property int cfg_itemSpacingDefault
    property bool cfg_panelGraphDefault
    property int cfg_panelGraphWidthDefault

    readonly property var families: [i18n("Theme default")].concat(Qt.fontFamilies())

    Kirigami.FormLayout {
        QQC2.CheckBox { id: showIcons; Kirigami.FormData.label: i18n("Icons:"); text: i18n("Show icons") }
        RowLayout {
            Kirigami.FormData.label: i18n("Icon size:")
            QQC2.SpinBox { id: iconSize; from: 0; to: 64; enabled: showIcons.checked }
            QQC2.Label { text: iconSize.value === 0 ? i18n("(theme default)") : i18nc("pixels", "px"); opacity: 0.7 }
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Font:")
            model: page.families
            currentIndex: page.cfg_fontFamily === "" ? 0 : Math.max(0, page.families.indexOf(page.cfg_fontFamily))
            onActivated: index => page.cfg_fontFamily = index === 0 ? "" : page.families[index]
            Layout.maximumWidth: Kirigami.Units.gridUnit * 16
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Font size:")
            QQC2.SpinBox { id: fontSize; from: 0; to: 48 }
            QQC2.Label { text: fontSize.value === 0 ? i18n("(theme default)") : i18nc("points", "pt"); opacity: 0.7 }
        }
        QQC2.CheckBox { id: fontBold; text: i18n("Bold") }
        RowLayout {
            Kirigami.FormData.label: i18n("Space between items:")
            QQC2.SpinBox { id: itemSpacing; from: -1; to: 48 }
            QQC2.Label { text: itemSpacing.value < 0 ? i18n("(theme default)") : i18nc("pixels", "px"); opacity: 0.7 }
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox {
            id: panelGraph
            Kirigami.FormData.label: i18n("History:")
            text: i18n("Show a small graph next to each value in the panel")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Graph width:")
            enabled: panelGraph.checked
            QQC2.SpinBox { id: panelGraphWidth; from: 16; to: 200 }
            QQC2.Label { text: i18nc("pixels", "px"); opacity: 0.7 }
        }
    }
}

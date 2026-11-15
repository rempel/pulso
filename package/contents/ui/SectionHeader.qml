// SPDX-License-Identifier: GPL-3.0-or-later
// Título de cada seção do popup
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3

RowLayout {
    id: header

    property string icon
    property string title
    property string subtitle

    Layout.fillWidth: true
    Layout.topMargin: Kirigami.Units.largeSpacing
    spacing: Kirigami.Units.smallSpacing

    Kirigami.Icon {
        source: Qt.resolvedUrl("../icons/pulso-" + header.icon + ".svg")
        isMask: true
        color: Kirigami.Theme.highlightColor
        Layout.preferredWidth: Kirigami.Units.iconSizes.small
        Layout.preferredHeight: Kirigami.Units.iconSizes.small
    }

    Kirigami.Heading {
        text: header.title
        level: 4
    }

    PC3.Label {
        text: header.subtitle
        visible: text.length > 0
        opacity: 0.6
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
        Layout.fillWidth: true
        font: Kirigami.Theme.smallFont
    }
}

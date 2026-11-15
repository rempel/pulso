// SPDX-License-Identifier: GPL-3.0-or-later
// Uma linha do popup: nome à esquerda, valor à direita e barra opcional
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3

ColumnLayout {
    id: row

    property string label
    property string value
    property real fraction: -1          // 0..1 mostra a barra; -1 esconde
    property color color: Kirigami.Theme.textColor

    Layout.fillWidth: true
    Layout.leftMargin: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing
    spacing: 2

    RowLayout {
        Layout.fillWidth: true
        PC3.Label {
            text: row.label
            opacity: 0.75
            Layout.fillWidth: true
        }
        PC3.Label {
            text: row.value
            color: row.color
            font.features: { "tnum": 1 }
        }
    }

    PC3.ProgressBar {
        visible: row.fraction >= 0
        from: 0
        to: 1
        value: Math.max(0, Math.min(1, row.fraction))
        Layout.fillWidth: true
    }
}

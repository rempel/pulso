// SPDX-License-Identifier: GPL-3.0-or-later
// Desktop layout: one card per sensor, in a grid that adapts to the widget size.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3

Item {
    id: view

    property var cfg
    property var styles
    signal activated(string action)

    // How many cards are shown (unavailable sensors are hidden)
    property int visibleCount: 0
    function recount() {
        let n = 0
        for (let i = 0; i < cards.count; ++i) {
            const c = cards.itemAt(i)
            if (c && c.visible) n++
        }
        visibleCount = n
    }
    readonly property int columns: cfg.desktopColumns > 0
        ? cfg.desktopColumns
        : Math.max(1, Math.min(visibleCount || 1, Math.floor(width / (Kirigami.Units.gridUnit * 7))))

    Layout.minimumWidth: Kirigami.Units.gridUnit * 7
    Layout.minimumHeight: Kirigami.Units.gridUnit * 7
    Layout.preferredWidth: Kirigami.Units.gridUnit * 8 * Math.min(3, Math.max(1, cfg.sensors.length))
    Layout.preferredHeight: Kirigami.Units.gridUnit * 8 * Math.ceil(Math.max(1, cfg.sensors.length) / 3)

    GridLayout {
        anchors.fill: parent
        columns: view.columns
        rowSpacing: Kirigami.Units.smallSpacing
        columnSpacing: Kirigami.Units.smallSpacing

        Repeater {
            id: cards
            model: view.cfg.sensors
            onItemAdded: view.recount()
            onItemRemoved: view.recount()
            delegate: Card {
                required property string modelData
                sensorId: modelData
                cfg: view.cfg
                styles: view.styles
                cardStyle: view.cfg.desktopStyle
                Layout.fillWidth: true
                Layout.fillHeight: true
                onActivated: action => view.activated(action)
                onVisibleChanged: view.recount()
            }
        }
    }

    PC3.Label {
        anchors.centerIn: parent
        visible: view.cfg.sensors.length === 0
        text: i18n("No sensors selected. Right-click → Configure.")
        opacity: 0.7
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
// Top processes by CPU usage, with a two-click "end process" button.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import org.kde.ksysguard.process as Process

ColumnLayout {
    id: list

    property bool active: false          // only poll while the popup is open
    property int count: 5
    property int interval: 2000
    // Per-process usage comes as % of one core; divide to match the total CPU %
    property int cores: 1
    property var rows: []

    spacing: 2

    Process.ProcessDataModel {
        id: procs
        enabled: list.active
        enabledAttributes: ["name", "pid", "usage", "vmPSS"]
    }

    // flatList may be missing on older libksysguard; a Binding only warns instead of failing
    Binding {
        target: procs
        property: "flatList"
        value: true
    }

    Process.ProcessController {
        id: controller
        window: list.Window.window
    }

    Timer {
        interval: list.interval
        running: list.active
        repeat: true
        triggeredOnStart: true
        onTriggered: list.refresh()
    }

    function cell(row, attribute, role) {
        const col = procs.enabledAttributes.indexOf(attribute)
        return col < 0 ? undefined : procs.data(procs.index(row, col), role)
    }

    function refresh() {
        const out = []
        const n = procs.rowCount()
        for (let r = 0; r < n; ++r) {
            const usage = Number(cell(r, "usage", Process.ProcessDataModel.Value)) / Math.max(1, cores)
            if (isNaN(usage)) continue
            out.push({
                name: String(cell(r, "name", Process.ProcessDataModel.Value) || "?"),
                pid: Number(cell(r, "pid", Process.ProcessDataModel.Value)),
                usage: usage,
                memory: String(cell(r, "vmPSS", Process.ProcessDataModel.FormattedValue) || "")
            })
        }
        out.sort((a, b) => b.usage - a.usage)
        rows = out.slice(0, count)
    }

    Repeater {
        model: list.rows

        delegate: RowLayout {
            id: row
            required property var modelData
            property bool armed: false

            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            PC3.Label {
                text: row.modelData.name
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            PC3.Label {
                text: row.modelData.usage.toFixed(1) + "%"
                font.features: { "tnum": 1 }
                horizontalAlignment: Text.AlignRight
                Layout.minimumWidth: Kirigami.Units.gridUnit * 3
            }
            PC3.Label {
                text: row.modelData.memory
                opacity: 0.7
                font.features: { "tnum": 1 }
                horizontalAlignment: Text.AlignRight
                Layout.minimumWidth: Kirigami.Units.gridUnit * 4
            }
            PC3.ToolButton {
                icon.name: "process-stop"
                text: row.armed ? i18n("End?") : ""
                display: row.armed ? PC3.AbstractButton.TextBesideIcon : PC3.AbstractButton.IconOnly
                PC3.ToolTip.text: i18n("End process (click twice)")
                PC3.ToolTip.visible: hovered && !row.armed
                PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
                onClicked: {
                    if (!row.armed) {
                        row.armed = true
                        disarm.restart()
                    } else {
                        row.armed = false
                        controller.sendSignal([row.modelData.pid], Process.Signal.TerminateSignal)
                        list.refresh()
                    }
                }
                Timer {
                    id: disarm
                    interval: 3000
                    onTriggered: row.armed = false
                }
            }
        }
    }

    PC3.Label {
        visible: list.rows.length === 0
        text: i18n("Loading…")
        opacity: 0.6
        Layout.leftMargin: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing
    }
}

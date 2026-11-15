// SPDX-License-Identifier: GPL-3.0-or-later
// Pulso — Vitals-style system monitor for the Plasma 6 panel and desktop.
// Everything is read through KDE's own sensor service (ksystemstats):
// no network access, and only fixed, built-in commands are ever launched.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors
import "logic.js" as Logic

PlasmoidItem {
    id: root

    readonly property var cfg: Plasmoid.configuration
    readonly property var styles: Logic.parseStyles(cfg.styles)
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool onDesktop: Plasmoid.location === PlasmaCore.Types.Desktop
                                   || Plasmoid.formFactor === PlasmaCore.Types.Planar

    // On the desktop the cards are the widget itself; in a panel they live in a popup
    preferredRepresentation: onDesktop ? fullRepresentation : compactRepresentation
    switchWidth: Kirigami.Units.gridUnit * 4
    switchHeight: Kirigami.Units.gridUnit * 4
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground

    toolTipMainText: "Pulso"
    toolTipSubText: i18n("CPU %1 · RAM %2 · %3", pct(tipCpu.value), pct(tipRam.value), temp(tipTemp.value))

    Sensors.Sensor { id: tipCpu;  sensorId: "cpu/all/usage";               updateRateLimit: root.cfg.updateInterval }
    Sensors.Sensor { id: tipRam;  sensorId: "memory/physical/usedPercent"; updateRateLimit: root.cfg.updateInterval }
    Sensors.Sensor { id: tipTemp; sensorId: "cpu/all/averageTemperature";  updateRateLimit: root.cfg.updateInterval }

    function pct(v)  { return Logic.valid(v) ? Math.round(v) + "%" : "–" }
    function temp(v) { return Logic.valid(v) && v > 0 ? Math.round(v) + "°C" : "–" }

    // ── Click actions (fixed commands only) ──────────────────
    P5Support.DataSource {
        id: launcher
        engine: "executable"
        onNewData: (source, data) => disconnectSource(source)
    }

    function runAction(action) {
        if (action === "none") return
        if (action === "popup" || action === "") {
            if (!onDesktop) root.expanded = !root.expanded
            return
        }
        const cmd = Logic.command(action)
        if (cmd !== "") {
            launcher.connectSource(cmd)
            root.expanded = false
        }
    }

    // ── Alerts: one watcher per configured sensor ────────────
    Instantiator {
        model: root.cfg.alertsEnabled ? root.cfg.sensors : []
        delegate: AlertWatcher {
            required property string modelData
            sensorId: modelData
            cfg: root.cfg
            styles: root.styles
        }
    }

    // ── In the panel ─────────────────────────────────────────
    compactRepresentation: MouseArea {
        id: compact

        // How many sensors are currently visible (hidden ones don't count)
        property int shownCount: 0
        function recount() {
            let n = 0
            for (let i = 0; i < metrics.count; ++i) {
                const item = metrics.itemAt(i)
                if (item && item.visible) n++
            }
            shownCount = n
        }

        readonly property real contentWidth: fallback.visible ? fallback.width : grid.implicitWidth
        readonly property real contentHeight: fallback.visible ? fallback.height : grid.implicitHeight

        Layout.minimumWidth: root.vertical ? -1 : contentWidth
        Layout.preferredWidth: root.vertical ? -1 : contentWidth
        Layout.minimumHeight: root.vertical ? contentHeight : -1
        Layout.preferredHeight: root.vertical ? contentHeight : -1

        hoverEnabled: true
        onClicked: root.runAction(root.cfg.clickAction)

        GridLayout {
            id: grid
            anchors.centerIn: parent
            flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
            rowSpacing: root.cfg.itemSpacing >= 0 ? root.cfg.itemSpacing : Kirigami.Units.smallSpacing
            columnSpacing: root.cfg.itemSpacing >= 0 ? root.cfg.itemSpacing : Kirigami.Units.largeSpacing

            Repeater {
                id: metrics
                model: root.cfg.sensors
                onItemAdded: compact.recount()
                onItemRemoved: compact.recount()
                delegate: Metric {
                    required property string modelData
                    sensorId: modelData
                    cfg: root.cfg
                    styles: root.styles
                    vertical: root.vertical
                    onVisibleChanged: compact.recount()
                    onActivated: action => root.runAction(action)
                }
            }
        }

        // Fallback while nothing is shown (no sensor configured, or all hidden),
        // so the widget never collapses to zero size and stays clickable.
        Kirigami.Icon {
            id: fallback
            anchors.centerIn: parent
            visible: compact.shownCount === 0
            source: Qt.resolvedUrl("../icons/pulso-pulse.svg")
            isMask: true
            color: Kirigami.Theme.textColor
            width: Kirigami.Units.iconSizes.small
            height: Kirigami.Units.iconSizes.small
        }
    }

    // ── Popup (panel) or cards (desktop) ─────────────────────
    fullRepresentation: Loader {
        Layout.minimumWidth: item ? item.Layout.minimumWidth : 0
        Layout.minimumHeight: item ? item.Layout.minimumHeight : 0
        Layout.preferredWidth: item ? item.Layout.preferredWidth : 0
        Layout.preferredHeight: item ? item.Layout.preferredHeight : 0

        sourceComponent: root.onDesktop ? desktopComponent : popupComponent
    }

    Component {
        id: popupComponent
        PopupView {
            cfg: root.cfg
            active: root.expanded
            onOpenMonitor: root.runAction("monitor")
        }
    }

    Component {
        id: desktopComponent
        DesktopView {
            cfg: root.cfg
            styles: root.styles
            onActivated: action => root.runAction(action)
        }
    }
}

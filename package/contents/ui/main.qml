// SPDX-License-Identifier: GPL-3.0-or-later
// Pulso — Vitals-style system monitor for the Plasma 6 panel.
// Everything is read through KDE's own sensor service (ksystemstats):
// no network access, no shell scripts.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors
import "logic.js" as Logic

PlasmoidItem {
    id: root

    readonly property var cfg: Plasmoid.configuration
    readonly property int rate: cfg.updateInterval
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    preferredRepresentation: compactRepresentation
    toolTipMainText: "Pulso"
    toolTipSubText: i18n("CPU %1 · RAM %2 · %3", pct(cpuUsage.value), pct(ramPct.value), temp(cpuTemp.value))

    // ── Sensors used by the popup ────────────────────────────
    Sensors.Sensor { id: cpuUsage;   sensorId: "cpu/all/usage";               updateRateLimit: root.rate }
    Sensors.Sensor { id: cpuFreq;    sensorId: "cpu/all/averageFrequency";    updateRateLimit: root.rate }
    Sensors.Sensor { id: cpuTemp;    sensorId: "cpu/all/averageTemperature";  updateRateLimit: root.rate }
    Sensors.Sensor { id: cpuTempMax; sensorId: "cpu/all/maximumTemperature";  updateRateLimit: root.rate }
    Sensors.Sensor { id: cpuName;    sensorId: "cpu/all/name" }
    Sensors.Sensor { id: coreCount;  sensorId: "cpu/all/coreCount" }
    Sensors.Sensor { id: gpuName;    sensorId: "gpu/gpu0/name" }
    Sensors.Sensor { id: gpuUsage;   sensorId: "gpu/gpu0/usage";              updateRateLimit: root.rate }
    Sensors.Sensor { id: gpuTemp;    sensorId: "gpu/gpu0/temperature";        updateRateLimit: root.rate }
    Sensors.Sensor { id: gpuVram;    sensorId: "gpu/gpu0/usedVram";           updateRateLimit: root.rate }
    Sensors.Sensor { id: gpuVramMax; sensorId: "gpu/gpu0/totalVram" }
    Sensors.Sensor { id: ramPct;     sensorId: "memory/physical/usedPercent"; updateRateLimit: root.rate }
    Sensors.Sensor { id: ramUsed;    sensorId: "memory/physical/used";        updateRateLimit: root.rate }
    Sensors.Sensor { id: ramTotal;   sensorId: "memory/physical/total" }
    Sensors.Sensor { id: swapPct;    sensorId: "memory/swap/usedPercent";     updateRateLimit: root.rate }
    Sensors.Sensor { id: swapTotal;  sensorId: "memory/swap/total" }
    Sensors.Sensor { id: netDown;    sensorId: "network/all/download";        updateRateLimit: root.rate }
    Sensors.Sensor { id: netUp;      sensorId: "network/all/upload";          updateRateLimit: root.rate }
    Sensors.Sensor { id: diskPct;    sensorId: "disk/all/usedPercent";        updateRateLimit: root.rate }
    Sensors.Sensor { id: diskFree;   sensorId: "disk/all/free";               updateRateLimit: root.rate }
    Sensors.Sensor { id: uptime;     sensorId: "os/system/uptime";            updateRateLimit: 60000 }

    // Opens KDE's System Monitor (fixed command, no user input)
    P5Support.DataSource {
        id: launcher
        engine: "executable"
        onNewData: (source, data) => disconnectSource(source)
    }

    function pct(v)  { return Logic.valid(v) ? Math.round(v) + "%" : "–" }
    function temp(v) { return Logic.valid(v) && v > 0 ? Math.round(v) + "°C" : "–" }
    function has(sensor) { return sensor.status === Sensors.Sensor.Ready }

    function tint(v, warn, crit) {
        if (!cfg.colorize) return Kirigami.Theme.textColor
        const lvl = Logic.level(v, warn, crit)
        return lvl === 2 ? Kirigami.Theme.negativeTextColor
             : lvl === 1 ? Kirigami.Theme.neutralTextColor
             : Kirigami.Theme.textColor
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
        onClicked: root.expanded = !root.expanded

        GridLayout {
            id: grid
            anchors.centerIn: parent
            flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.largeSpacing

            Repeater {
                id: metrics
                model: root.cfg.sensors
                onItemAdded: compact.recount()
                onItemRemoved: compact.recount()
                delegate: Metric {
                    required property string modelData
                    onVisibleChanged: compact.recount()
                    sensorId: modelData
                    updateInterval: root.rate
                    vertical: root.vertical
                    showIcon: root.cfg.showIcons
                    colorize: root.cfg.colorize
                    hideUnavailable: root.cfg.hideUnavailable
                    percentWarn: root.cfg.percentWarn
                    percentCrit: root.cfg.percentCrit
                    tempWarn: root.cfg.tempWarn
                    tempCrit: root.cfg.tempCrit
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

    // ── Popup ────────────────────────────────────────────────
    fullRepresentation: ColumnLayout {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: implicitHeight
        spacing: Kirigami.Units.smallSpacing

        SectionHeader { icon: "cpu"; title: i18n("Processor"); subtitle: cpuName.value || ""; Layout.topMargin: 0 }
        DetailRow {
            label: i18n("Usage")
            value: pct(cpuUsage.value)
            fraction: Logic.valid(cpuUsage.value) ? cpuUsage.value / 100 : 0
            color: tint(cpuUsage.value, cfg.percentWarn, cfg.percentCrit)
        }
        DetailRow { label: i18n("Average frequency"); value: cpuFreq.formattedValue; visible: has(cpuFreq) }
        DetailRow { label: i18n("Cores"); value: coreCount.formattedValue; visible: has(coreCount) }

        SectionHeader { icon: "temp"; title: i18n("Temperature"); visible: temp(cpuTemp.value) !== "–" }
        DetailRow {
            visible: temp(cpuTemp.value) !== "–"
            label: i18n("CPU (average)")
            value: temp(cpuTemp.value)
            color: tint(cpuTemp.value, cfg.tempWarn, cfg.tempCrit)
        }
        DetailRow {
            visible: temp(cpuTempMax.value) !== "–"
            label: i18n("CPU (hottest core)")
            value: temp(cpuTempMax.value)
            color: tint(cpuTempMax.value, cfg.tempWarn, cfg.tempCrit)
        }

        SectionHeader { icon: "gpu"; title: i18n("Graphics card"); subtitle: gpuName.value || ""; visible: has(gpuName) }
        DetailRow {
            visible: has(gpuUsage) && Logic.valid(gpuUsage.value)
            label: i18n("Usage")
            value: pct(gpuUsage.value)
            fraction: Logic.valid(gpuUsage.value) ? gpuUsage.value / 100 : 0
            color: tint(gpuUsage.value, cfg.percentWarn, cfg.percentCrit)
        }
        DetailRow {
            visible: temp(gpuTemp.value) !== "–"
            label: i18n("Temperature")
            value: temp(gpuTemp.value)
            color: tint(gpuTemp.value, cfg.tempWarn, cfg.tempCrit)
        }
        DetailRow {
            visible: has(gpuVram) && gpuVramMax.value > 0
            label: i18n("Video memory")
            value: gpuVram.formattedValue + " / " + gpuVramMax.formattedValue
            fraction: gpuVramMax.value > 0 ? gpuVram.value / gpuVramMax.value : 0
        }

        SectionHeader { icon: "ram"; title: i18n("Memory") }
        DetailRow {
            label: i18n("RAM")
            value: ramUsed.formattedValue + " / " + ramTotal.formattedValue
            fraction: Logic.valid(ramPct.value) ? ramPct.value / 100 : 0
            color: tint(ramPct.value, cfg.percentWarn, cfg.percentCrit)
        }
        DetailRow {
            visible: swapTotal.value > 0
            label: i18n("Swap")
            value: pct(swapPct.value)
            fraction: Logic.valid(swapPct.value) ? swapPct.value / 100 : 0
        }

        SectionHeader { icon: "net"; title: i18n("Network") }
        DetailRow { label: i18n("Download"); value: Logic.speed(netDown.value) }
        DetailRow { label: i18n("Upload"); value: Logic.speed(netUp.value) }

        SectionHeader { icon: "disk"; title: i18n("Disk"); visible: has(diskPct) }
        DetailRow {
            visible: has(diskPct)
            label: i18n("Used")
            value: i18n("%1 (%2 free)", pct(diskPct.value), diskFree.formattedValue)
            fraction: Logic.valid(diskPct.value) ? diskPct.value / 100 : 0
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
        }

        RowLayout {
            Layout.fillWidth: true
            PC3.Label {
                text: i18n("Up for %1", Logic.duration(uptime.value))
                opacity: 0.6
                Layout.fillWidth: true
            }
            PC3.ToolButton {
                text: i18n("System Monitor")
                icon.name: "utilities-system-monitor"
                onClicked: {
                    launcher.connectSource("plasma-systemmonitor")
                    root.expanded = false
                }
            }
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
// Non-visual model of one sensor: value, formatting, alert level, icon and colors.
// Shared by the panel item (Metric.qml), the desktop card (Card.qml) and alerts.
import QtQuick
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import "logic.js" as Logic

QtObject {
    id: m

    property string sensorId
    property var cfg                         // Plasmoid.configuration
    property var styles: ({})                // parsed "styles" JSON

    // Colors come from the visual owner (Kirigami.Theme isn't available on a QtObject)
    property color normalColor: "white"
    property color warningColor: "orange"
    property color criticalColor: "red"

    readonly property var style: Logic.styleFor(styles, sensorId)

    readonly property Sensors.Sensor sensor: Sensors.Sensor {
        sensorId: m.sensorId
        updateRateLimit: m.cfg ? m.cfg.updateInterval : 2000
    }

    readonly property bool isPercent: sensor.unit === Formatter.Units.UnitPercent
    readonly property bool isTemp: sensor.unit === Formatter.Units.UnitCelsius
    readonly property bool isRate: sensor.unit === Formatter.Units.UnitByteRate
    readonly property bool ready: sensor.status === Sensors.Sensor.Ready && Logic.valid(sensor.value)
    readonly property real value: ready ? sensor.value : 0

    // Unknown/missing sensor (never becomes ready), or a temperature stuck at 0
    // (e.g. a GPU on the nouveau driver)
    readonly property bool unavailable: !ready || (isTemp && sensor.value <= 0)
    readonly property bool hidden: (cfg ? cfg.hideUnavailable : true) && unavailable

    readonly property int decimals: style.decimals >= 0 ? style.decimals : 0

    readonly property string valueText: {
        if (!ready) return "–";
        if (isPercent) return Logic.fixed(value, decimals) + "%";
        if (isTemp) return Logic.fixed(value, decimals) + "°C";
        if (isRate) return Logic.speed(value);
        if (style.decimals >= 0 && typeof sensor.value === "number" && sensor.formattedValue.indexOf(" ") < 0)
            return Logic.fixed(value, decimals);
        return sensor.formattedValue;
    }

    // Widest text this sensor can show, so the panel doesn't jump around
    readonly property string widest: {
        const frac = decimals > 0 ? "." + "0".repeat(decimals) : "";
        if (isPercent) return "100" + frac + "%";
        if (isTemp) return "100" + frac + "°C";
        if (isRate) return "999 K/s";
        return "";
    }

    // Friendly default name by sensor type; the user's label always wins
    readonly property string title: {
        if (style.label !== "") return style.label;
        const id = sensorId;
        switch (Logic.iconFor(id)) {
        case "cpu": return id === "cpu/all/usage" ? i18n("CPU") : (sensor.name || id);
        case "ram":
            if (id.indexOf("memory/swap/") === 0) return i18n("Swap");
            if (id === "memory/physical/usedPercent" || id === "memory/physical/used") return i18n("Memory");
            return sensor.name || id;
        case "temp":
            if (id.indexOf("cpu/") === 0) return i18n("CPU temperature");
            if (id.indexOf("gpu/") === 0) return i18n("GPU temperature");
            return sensor.name || id;
        case "gpu": return i18n("GPU");
        case "down": return i18n("Download");
        case "up": return i18n("Upload");
        case "disk": return i18n("Disk");
        default: return sensor.shortName || sensor.name || id;
        }
    }

    // Range used by gauges and graphs (0 = automatic)
    readonly property real rangeMax: {
        if (isPercent) return 100;
        if (isTemp) return Math.max((cfg ? cfg.tempCrit : 85) + 15, 100);
        return sensor.maximum > 0 ? sensor.maximum : 0;
    }

    readonly property int level: {
        if (!cfg || !cfg.colorize || !ready) return 0;
        if (isPercent) return Logic.level(value, cfg.percentWarn, cfg.percentCrit);
        if (isTemp) return Logic.level(value, cfg.tempWarn, cfg.tempCrit);
        return 0;
    }

    readonly property color baseColor: style.color !== "" ? style.color : normalColor
    readonly property color tint: level === 2 ? criticalColor : level === 1 ? warningColor : baseColor

    readonly property string iconSource: Logic.iconSource(style, sensorId, Qt.resolvedUrl("../icons/"))
    readonly property bool iconMask: style.iconMask

    readonly property string action: style.action !== "" ? style.action : (cfg ? cfg.clickAction : "popup")
}

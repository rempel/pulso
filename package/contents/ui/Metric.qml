// SPDX-License-Identifier: GPL-3.0-or-later
// One sensor in the panel: icon + value. Works for any ksystemstats sensor.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import "logic.js" as Logic

GridLayout {
    id: metric

    property string sensorId
    property int updateInterval: 2000
    property bool showIcon: true
    property bool vertical: false
    property bool colorize: true
    property bool hideUnavailable: true
    property int percentWarn: 75
    property int percentCrit: 90
    property int tempWarn: 70
    property int tempCrit: 85

    readonly property bool isPercent: sensor.unit === Formatter.Units.UnitPercent
    readonly property bool isTemp: sensor.unit === Formatter.Units.UnitCelsius
    readonly property bool isRate: sensor.unit === Formatter.Units.UnitByteRate
    readonly property bool ready: sensor.status === Sensors.Sensor.Ready && Logic.valid(sensor.value)

    // Unknown/missing sensor (never becomes ready), or a temperature stuck at 0
    // (e.g. a GPU on the nouveau driver)
    readonly property bool unavailable: !ready || (isTemp && sensor.value <= 0)

    readonly property string valueText: {
        if (!ready) return "–";
        const v = sensor.value;
        if (isPercent) return Math.round(v) + "%";
        if (isTemp) return Math.round(v) + "°C";
        if (isRate) return Logic.speed(v);
        return sensor.formattedValue;
    }

    // Reserve the widest possible text so the panel doesn't jump around
    readonly property string widest: isPercent ? "100%" : isTemp ? "100°C" : isRate ? "999 K/s" : ""

    readonly property color tint: {
        if (!colorize || !ready) return Kirigami.Theme.textColor;
        let lvl = 0;
        if (isPercent) lvl = Logic.level(sensor.value, percentWarn, percentCrit);
        else if (isTemp) lvl = Logic.level(sensor.value, tempWarn, tempCrit);
        return lvl === 2 ? Kirigami.Theme.negativeTextColor
             : lvl === 1 ? Kirigami.Theme.neutralTextColor
             : Kirigami.Theme.textColor;
    }

    visible: !(hideUnavailable && unavailable)
    columns: vertical ? 1 : 2
    rowSpacing: 0
    columnSpacing: Kirigami.Units.smallSpacing

    Sensors.Sensor {
        id: sensor
        sensorId: metric.sensorId
        updateRateLimit: metric.updateInterval
    }

    Kirigami.Icon {
        visible: metric.showIcon
        source: Qt.resolvedUrl("../icons/pulso-" + Logic.iconFor(metric.sensorId) + ".svg")
        isMask: true
        color: metric.tint
        Layout.preferredWidth: Kirigami.Units.iconSizes.small
        Layout.preferredHeight: Kirigami.Units.iconSizes.small
        Layout.alignment: Qt.AlignCenter
    }

    PC3.Label {
        id: label
        text: metric.valueText
        color: metric.tint
        font.pointSize: metric.vertical ? Kirigami.Theme.smallFont.pointSize : Kirigami.Theme.defaultFont.pointSize
        font.features: { "tnum": 1 }
        horizontalAlignment: metric.vertical ? Text.AlignHCenter : Text.AlignRight
        Layout.minimumWidth: metric.vertical ? 0 : widthProbe.advanceWidth
        Layout.alignment: Qt.AlignCenter

        TextMetrics {
            id: widthProbe
            font: label.font
            text: metric.widest
        }
    }
}

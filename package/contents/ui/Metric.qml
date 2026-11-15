// SPDX-License-Identifier: GPL-3.0-or-later
// One sensor in the panel: icon + optional label + value + optional history line.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import org.kde.quickcharts as Charts

Item {
    id: metric

    property alias sensorId: sm.sensorId
    property var cfg
    property var styles
    property bool vertical: false

    // Emitted on click with the action configured for this sensor
    signal activated(string action)

    readonly property alias model: sm
    readonly property bool showGraph: cfg.panelGraph && !vertical
        && (sm.isPercent || sm.isTemp || sm.isRate || sm.rangeMax > 0)

    readonly property string fontFamily: cfg.fontFamily !== "" ? cfg.fontFamily : Kirigami.Theme.defaultFont.family
    readonly property real fontPointSize: cfg.fontSize > 0 ? cfg.fontSize
        : (vertical ? Kirigami.Theme.smallFont.pointSize : Kirigami.Theme.defaultFont.pointSize)
    readonly property int iconPx: cfg.iconSize > 0 ? cfg.iconSize : Kirigami.Units.iconSizes.small

    visible: !sm.hidden
    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight
    Layout.alignment: Qt.AlignCenter

    MetricModel {
        id: sm
        cfg: metric.cfg
        styles: metric.styles
        normalColor: Kirigami.Theme.textColor
        warningColor: Kirigami.Theme.neutralTextColor
        criticalColor: Kirigami.Theme.negativeTextColor
    }

    GridLayout {
        id: grid
        anchors.centerIn: parent
        columns: metric.vertical ? 1 : 4
        rowSpacing: 0
        columnSpacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            visible: metric.cfg.showIcons
            source: sm.iconSource
            isMask: sm.iconMask
            color: sm.tint
            Layout.preferredWidth: metric.iconPx
            Layout.preferredHeight: metric.iconPx
            Layout.alignment: Qt.AlignCenter
        }

        PC3.Label {
            visible: sm.style.label !== ""
            text: sm.style.label
            color: sm.tint
            font.family: metric.fontFamily
            font.pointSize: metric.fontPointSize
            font.bold: metric.cfg.fontBold
            font.features: { "tnum": 1 }
            opacity: 0.8
            Layout.alignment: Qt.AlignCenter
        }

        PC3.Label {
            id: valueLabel
            text: sm.valueText
            color: sm.tint
            font.family: metric.fontFamily
            font.pointSize: metric.fontPointSize
            font.bold: metric.cfg.fontBold
            font.features: { "tnum": 1 }
            horizontalAlignment: metric.vertical ? Text.AlignHCenter : Text.AlignRight
            Layout.minimumWidth: metric.vertical ? 0 : widthProbe.advanceWidth
            Layout.alignment: Qt.AlignCenter

            TextMetrics {
                id: widthProbe
                font: valueLabel.font
                text: sm.widest
            }
        }

        Charts.LineChart {
            visible: metric.showGraph
            Layout.preferredWidth: metric.cfg.panelGraphWidth
            Layout.preferredHeight: metric.iconPx
            Layout.alignment: Qt.AlignCenter
            lineWidth: 1
            fillOpacity: 0.25
            yRange {
                from: 0
                to: sm.rangeMax > 0 ? sm.rangeMax : 100
                automatic: sm.rangeMax <= 0
            }
            colorSource: Charts.SingleValueSource { value: sm.tint }
            valueSources: Charts.HistoryProxySource {
                source: Charts.SingleValueSource { value: sm.value }
                maximumHistory: 30
                interval: metric.cfg.updateInterval
                fillMode: Charts.HistoryProxySource.FillFromEnd
            }
        }
    }

    // Per-sensor click action (the popup by default)
    MouseArea {
        anchors.fill: parent
        onClicked: metric.activated(sm.action)
    }
}

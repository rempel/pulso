// SPDX-License-Identifier: GPL-3.0-or-later
// One sensor on the desktop: a card with a gauge, a history graph or a big number.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3
import org.kde.quickcharts as Charts

Rectangle {
    id: card

    property alias sensorId: sm.sensorId
    property var cfg
    property var styles
    property string cardStyle: "gauge"     // gauge | graph | text

    // A gauge needs a known maximum; sensors without one (e.g. network speed) get the graph
    readonly property string effectiveStyle: cardStyle === "gauge" && sm.rangeMax <= 0 ? "graph" : cardStyle

    signal activated(string action)

    readonly property alias model: sm
    readonly property color textColor: Kirigami.Theme.textColor
    // Gauges and graphs: alert color, else the sensor's custom color, else the theme accent
    readonly property color accent: sm.level > 0 ? sm.tint
        : (sm.style.color !== "" ? sm.style.color : Kirigami.Theme.highlightColor)
    readonly property string fontFamily: cfg.fontFamily !== "" ? cfg.fontFamily : Kirigami.Theme.defaultFont.family

    visible: !sm.hidden
    radius: Kirigami.Units.largeSpacing
    color: cfg.desktopCardBackground ? Qt.rgba(textColor.r, textColor.g, textColor.b, 0.07) : "transparent"
    implicitWidth: Kirigami.Units.gridUnit * 8
    implicitHeight: Kirigami.Units.gridUnit * 8

    MetricModel {
        id: sm
        cfg: card.cfg
        styles: card.styles
        normalColor: Kirigami.Theme.textColor
        warningColor: Kirigami.Theme.neutralTextColor
        criticalColor: Kirigami.Theme.negativeTextColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        // Header: icon + name
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                visible: card.cfg.showIcons
                source: sm.iconSource
                isMask: sm.iconMask
                color: sm.tint
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
            }
            PC3.Label {
                text: sm.title
                elide: Text.ElideRight
                opacity: 0.8
                font.family: card.fontFamily
                font.bold: card.cfg.fontBold
                Layout.fillWidth: true
            }
        }

        // Body
        Item {
            id: body
            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property real side: Math.min(width, height)

            // Gauge (270° arc)
            Charts.PieChart {
                id: gauge
                visible: card.effectiveStyle === "gauge"
                anchors.centerIn: parent
                width: body.side * 0.9
                height: body.side * 0.9
                filled: false
                thickness: Math.max(4, body.side * 0.09)
                fromAngle: -135
                toAngle: 135
                smoothEnds: true
                // The chart ignores alpha, so mix an opaque track color like KDE's own faces do
                backgroundColor: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.15)
                range {
                    from: 0
                    to: sm.rangeMax > 0 ? sm.rangeMax : 100
                    automatic: sm.rangeMax <= 0
                }
                valueSources: Charts.SingleValueSource { value: sm.value }
                colorSource: Charts.SingleValueSource { value: card.accent }
            }

            // History graph
            Charts.LineChart {
                visible: card.effectiveStyle === "graph"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height * 0.6
                lineWidth: 2
                fillOpacity: 0.2
                yRange {
                    from: 0
                    to: sm.rangeMax > 0 ? sm.rangeMax : 100
                    automatic: sm.rangeMax <= 0
                }
                colorSource: Charts.SingleValueSource { value: card.accent }
                valueSources: Charts.HistoryProxySource {
                    source: Charts.SingleValueSource { value: sm.value }
                    maximumHistory: Math.max(10, card.cfg.desktopHistory)
                    interval: card.cfg.updateInterval
                    fillMode: Charts.HistoryProxySource.FillFromEnd
                }
            }

            // Value
            PC3.Label {
                text: sm.valueText
                color: sm.tint
                font.family: card.fontFamily
                font.bold: true
                font.features: { "tnum": 1 }
                font.pixelSize: card.effectiveStyle === "gauge" ? Math.max(10, body.side * 0.2)
                              : Math.max(12, Math.min(body.height * 0.35, body.width * 0.25))
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                // Top of the card above a graph, centered otherwise
                y: card.effectiveStyle === "graph" ? 0 : (parent.height - height) / 2
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: card.activated(sm.action)
    }
}

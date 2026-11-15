// SPDX-License-Identifier: GPL-3.0-or-later
// Settings › Presets: ready-made looks, plus export/import of the whole setup as JSON
// (to back it up or share it). Nothing is applied until you press Apply/OK.
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "logic.js" as Logic

KCM.SimpleKCM {
    id: page

    // Every setting, so a preset or an import can change any of them
    property var cfg_sensors: []
    property string cfg_styles
    property bool cfg_colorize
    property bool cfg_hideUnavailable
    property int cfg_updateInterval
    property string cfg_clickAction
    property int cfg_percentWarn
    property int cfg_percentCrit
    property int cfg_tempWarn
    property int cfg_tempCrit
    property bool cfg_showIcons
    property int cfg_iconSize
    property string cfg_fontFamily
    property int cfg_fontSize
    property bool cfg_fontBold
    property int cfg_itemSpacing
    property bool cfg_panelGraph
    property int cfg_panelGraphWidth
    property string cfg_desktopStyle
    property int cfg_desktopColumns
    property int cfg_desktopHistory
    property bool cfg_desktopCardBackground
    property bool cfg_alertsEnabled
    property int cfg_alertSeconds
    property int cfg_alertCooldown
    property bool cfg_showProcesses
    property int cfg_processCount

    property var cfg_sensorsDefault
    property string cfg_stylesDefault
    property bool cfg_colorizeDefault
    property bool cfg_hideUnavailableDefault
    property int cfg_updateIntervalDefault
    property string cfg_clickActionDefault
    property int cfg_percentWarnDefault
    property int cfg_percentCritDefault
    property int cfg_tempWarnDefault
    property int cfg_tempCritDefault
    property bool cfg_showIconsDefault
    property int cfg_iconSizeDefault
    property string cfg_fontFamilyDefault
    property int cfg_fontSizeDefault
    property bool cfg_fontBoldDefault
    property int cfg_itemSpacingDefault
    property bool cfg_panelGraphDefault
    property int cfg_panelGraphWidthDefault
    property string cfg_desktopStyleDefault
    property int cfg_desktopColumnsDefault
    property int cfg_desktopHistoryDefault
    property bool cfg_desktopCardBackgroundDefault
    property bool cfg_alertsEnabledDefault
    property int cfg_alertSecondsDefault
    property int cfg_alertCooldownDefault
    property bool cfg_showProcessesDefault
    property int cfg_processCountDefault

    // Keys and expected types for export/import
    readonly property var keys: ({
        sensors: "list", styles: "string", colorize: "bool", hideUnavailable: "bool",
        updateInterval: "int", clickAction: "string", percentWarn: "int", percentCrit: "int",
        tempWarn: "int", tempCrit: "int", showIcons: "bool", iconSize: "int", fontFamily: "string",
        fontSize: "int", fontBold: "bool", itemSpacing: "int", panelGraph: "bool",
        panelGraphWidth: "int", desktopStyle: "string", desktopColumns: "int",
        desktopHistory: "int", desktopCardBackground: "bool", alertsEnabled: "bool",
        alertSeconds: "int", alertCooldown: "int", showProcesses: "bool", processCount: "int"
    })

    property string message
    property int messageType: Kirigami.MessageType.Positive

    function exportJson() {
        const out = { pulso: 1 }
        for (const k in keys) {
            const v = page["cfg_" + k]
            out[k] = k === "styles" ? Logic.parseStyles(v) : (keys[k] === "list" ? Array.from(v || []) : v)
        }
        return JSON.stringify(out, null, 2)
    }

    function importJson(text) {
        let data
        try { data = JSON.parse(text) } catch (e) { return false }
        if (!data || typeof data !== "object" || data.pulso === undefined) return false
        for (const k in keys) {
            if (!(k in data)) continue
            const v = data[k], type = keys[k]
            if (k === "styles" && typeof v === "object") {
                // Re-normalize every entry: unknown fields and actions are dropped
                const clean = {}
                for (const id in v) {
                    const s = Logic.styleFor(v, id)
                    let out = {}
                    for (const f in s) out = Logic.withStyle(out, id, f, s[f])
                    Object.assign(clean, out)
                }
                page.cfg_styles = JSON.stringify(clean)
            } else if (type === "list" && Array.isArray(v)) {
                page["cfg_" + k] = v.filter(x => typeof x === "string")
            } else if (type === "int" && typeof v === "number") {
                page["cfg_" + k] = Math.round(v)
            } else if (type === "bool" && typeof v === "boolean") {
                page["cfg_" + k] = v
            } else if (type === "string" && typeof v === "string" && k !== "styles") {
                page["cfg_" + k] = v
            }
        }
        return true
    }

    function resetAll() {
        for (const k in keys) page["cfg_" + k] = page["cfg_" + k + "Default"]
    }

    // Applies a style field to every configured sensor, by sensor type
    function styleByType(field, valuesByType) {
        let out = Logic.parseStyles(cfg_styles)
        for (const id of Array.from(cfg_sensors || [])) {
            const t = Logic.iconFor(id)
            out = Logic.withStyle(out, id, field, valuesByType[t] !== undefined ? valuesByType[t] : Logic.styleFor({}, id)[field])
        }
        cfg_styles = JSON.stringify(out)
    }

    readonly property var presets: [
        {
            name: i18n("Default"), description: i18n("Back to the original look and sensors."),
            apply: () => page.resetAll()
        },
        {
            name: i18n("Colorful"), description: i18n("A different color for each kind of sensor."),
            apply: () => page.styleByType("color", {
                cpu: "#3daee9", ram: "#e93d8f", temp: "#f67400", gpu: "#9b59b6",
                down: "#27ae60", up: "#1abc9c", net: "#27ae60", disk: "#fdbc4b",
                fan: "#95a5a6", battery: "#2ecc71", pulse: "#3daee9"
            })
        },
        {
            name: i18n("Text labels"), description: i18n("Short names instead of icons: CPU, RAM, TEMP…"),
            apply: () => {
                page.cfg_showIcons = false
                page.styleByType("label", {
                    cpu: "CPU", ram: "RAM", temp: "TEMP", gpu: "GPU", down: "↓", up: "↑",
                    net: "NET", disk: "DISK", fan: "FAN", battery: "BAT", pulse: ""
                })
            }
        },
        {
            name: i18n("Graphs"), description: i18n("A small history line next to each value."),
            apply: () => { page.cfg_panelGraph = true; page.cfg_panelGraphWidth = 36 }
        },
        {
            name: i18n("Compact"), description: i18n("Tighter spacing and no graphs."),
            apply: () => { page.cfg_itemSpacing = 4; page.cfg_panelGraph = false; page.cfg_iconSize = 0 }
        }
    ]

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: page.message !== ""
            type: page.messageType
            text: page.message
        }

        Kirigami.Heading { level: 3; text: i18n("Presets") }
        QQC2.Label {
            text: i18n("Pick one, then press Apply. You can combine them.")
            opacity: 0.7
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        Flow {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            Repeater {
                model: page.presets
                delegate: QQC2.Button {
                    required property var modelData
                    text: modelData.name
                    QQC2.ToolTip.text: modelData.description
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                    onClicked: {
                        modelData.apply()
                        page.messageType = Kirigami.MessageType.Positive
                        page.message = i18n("“%1” is ready. Press Apply to use it.", modelData.name)
                    }
                }
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        Kirigami.Heading { level: 3; text: i18n("Backup and share") }
        QQC2.Label {
            text: i18n("Your whole setup as text. Copy it to back it up or share it; paste one here and press Import to load it.")
            opacity: 0.7
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 12
            QQC2.TextArea {
                id: jsonArea
                text: page.exportJson()
                font.family: "monospace"
                wrapMode: TextEdit.NoWrap
                selectByMouse: true
            }
        }

        RowLayout {
            QQC2.Button {
                icon.name: "edit-copy"
                text: i18n("Copy")
                onClicked: {
                    jsonArea.selectAll()
                    jsonArea.copy()
                    jsonArea.deselect()
                    page.messageType = Kirigami.MessageType.Positive
                    page.message = i18n("Copied to the clipboard.")
                }
            }
            QQC2.Button {
                icon.name: "document-import"
                text: i18n("Import")
                onClicked: {
                    const ok = page.importJson(jsonArea.text)
                    page.messageType = ok ? Kirigami.MessageType.Positive : Kirigami.MessageType.Error
                    page.message = ok ? i18n("Imported. Press Apply to use it.")
                                      : i18n("This doesn't look like a Pulso setup.")
                }
            }
            QQC2.Button {
                icon.name: "view-refresh"
                text: i18n("Show current")
                onClicked: jsonArea.text = Qt.binding(() => page.exportJson())
            }
        }
    }
}

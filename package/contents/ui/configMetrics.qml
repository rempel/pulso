// SPDX-License-Identifier: GPL-3.0-or-later
// Settings › Sensors: per-sensor label, icon (bundled, theme or your own SVG/PNG),
// color, decimals and click action.
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.iconthemes as KIconThemes
import org.kde.kquickcontrols as KQuickControls
import org.kde.ksysguard.sensors as Sensors
import "logic.js" as Logic

KCM.SimpleKCM {
    id: page

    property var cfg_sensors: []
    property string cfg_styles: "{}"
    property var cfg_sensorsDefault
    property string cfg_stylesDefault

    readonly property var styles: Logic.parseStyles(cfg_styles)
    readonly property string iconsBase: Qt.resolvedUrl("../icons/")

    function setStyle(sensorId, key, value) {
        cfg_styles = JSON.stringify(Logic.withStyle(styles, sensorId, key, value))
    }

    // One shared picker of each kind; `target` is the sensor being edited
    KIconThemes.IconDialog {
        id: iconDialog
        property string target
        onIconNameChanged: name => {
            if (target !== "" && name !== "") page.setStyle(target, "icon", "theme:" + name)
        }
    }
    Dialogs.FileDialog {
        id: fileDialog
        property string target
        title: i18n("Choose an icon")
        nameFilters: [i18n("Images (*.svg *.svgz *.png)")]
        onAccepted: page.setStyle(target, "icon", String(selectedFile))
    }

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: true
            text: i18n("Sensors added in “General” show up here after you apply them.")
        }

        Repeater {
            model: page.cfg_sensors

            delegate: Kirigami.AbstractCard {
                id: card
                required property string modelData
                readonly property var style: Logic.styleFor(page.styles, modelData)

                Layout.fillWidth: true

                Sensors.Sensor { id: sensor; sensorId: card.modelData }

                contentItem: GridLayout {
                    columns: 2
                    columnSpacing: Kirigami.Units.largeSpacing
                    rowSpacing: Kirigami.Units.smallSpacing

                    // Title row: preview + sensor name
                    RowLayout {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        Kirigami.Icon {
                            source: Logic.iconSource(card.style, card.modelData, page.iconsBase)
                            isMask: card.style.iconMask
                            color: card.style.color !== "" ? card.style.color : Kirigami.Theme.textColor
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        }
                        ColumnLayout {
                            spacing: 0
                            Layout.fillWidth: true
                            Kirigami.Heading { level: 4; text: sensor.name || card.modelData; elide: Text.ElideRight; Layout.fillWidth: true }
                            QQC2.Label { text: card.modelData; opacity: 0.6; font: Kirigami.Theme.smallFont; elide: Text.ElideRight; Layout.fillWidth: true }
                        }
                        QQC2.Button {
                            icon.name: "edit-reset"
                            text: i18n("Reset")
                            onClicked: {
                                const out = JSON.parse(JSON.stringify(page.styles))
                                delete out[card.modelData]
                                page.cfg_styles = JSON.stringify(out)
                            }
                        }
                    }

                    QQC2.Label { text: i18n("Label:") }
                    QQC2.TextField {
                        Layout.fillWidth: true
                        text: card.style.label
                        placeholderText: i18n("None (icon only)")
                        onEditingFinished: page.setStyle(card.modelData, "label", text)
                    }

                    QQC2.Label { text: i18n("Icon:") }
                    RowLayout {
                        QQC2.Button {
                            text: i18n("Automatic")
                            checkable: true
                            checked: card.style.icon === ""
                            onClicked: page.setStyle(card.modelData, "icon", "")
                        }
                        QQC2.Button {
                            text: i18n("From theme…")
                            icon.name: "preferences-desktop-icons"
                            checkable: true
                            checked: card.style.icon.indexOf("theme:") === 0
                            onClicked: { checked = Qt.binding(() => card.style.icon.indexOf("theme:") === 0); iconDialog.target = card.modelData; iconDialog.open() }
                        }
                        QQC2.Button {
                            text: i18n("File…")
                            icon.name: "document-open"
                            checkable: true
                            checked: card.style.icon.indexOf("file:") === 0
                            onClicked: { checked = Qt.binding(() => card.style.icon.indexOf("file:") === 0); fileDialog.target = card.modelData; fileDialog.open() }
                        }
                    }

                    Item { width: 1 }
                    QQC2.CheckBox {
                        text: i18n("Paint the icon with the text color (for single-color icons)")
                        checked: card.style.iconMask
                        onToggled: page.setStyle(card.modelData, "iconMask", checked)
                    }

                    QQC2.Label { text: i18n("Color:") }
                    RowLayout {
                        QQC2.CheckBox {
                            id: customColor
                            text: i18n("Custom")
                            checked: card.style.color !== ""
                            onToggled: page.setStyle(card.modelData, "color", checked ? colorButton.color.toString() : "")
                        }
                        KQuickControls.ColorButton {
                            id: colorButton
                            enabled: customColor.checked
                            showAlphaChannel: false
                            color: card.style.color !== "" ? card.style.color : Kirigami.Theme.textColor
                            onAccepted: c => page.setStyle(card.modelData, "color", c.toString())
                        }
                        QQC2.Label {
                            text: i18n("Orange/red above the limits still win.")
                            opacity: 0.6
                            font: Kirigami.Theme.smallFont
                        }
                    }

                    QQC2.Label { text: i18n("Decimals:") }
                    QQC2.ComboBox {
                        model: [i18n("Automatic"), "0", "1", "2", "3"]
                        currentIndex: card.style.decimals + 1
                        onActivated: index => page.setStyle(card.modelData, "decimals", index - 1)
                    }

                    QQC2.Label { text: i18n("When clicked:") }
                    QQC2.ComboBox {
                        readonly property var options: [
                            { value: "",         text: i18n("Same as the widget") },
                            { value: "popup",    text: i18n("Open the details popup") },
                            { value: "monitor",  text: i18n("Open System Monitor") },
                            { value: "terminal", text: i18n("Open a terminal with htop") },
                            { value: "none",     text: i18n("Do nothing") }
                        ]
                        model: options
                        textRole: "text"
                        valueRole: "value"
                        currentIndex: Math.max(0, options.findIndex(o => o.value === card.style.action))
                        onActivated: page.setStyle(card.modelData, "action", currentValue)
                    }
                }
            }
        }

        QQC2.Label {
            visible: page.cfg_sensors.length === 0
            text: i18n("No sensors selected yet.")
            opacity: 0.7
        }
    }
}

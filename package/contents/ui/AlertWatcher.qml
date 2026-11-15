// SPDX-License-Identifier: GPL-3.0-or-later
// Sends a desktop notification when a sensor stays at the critical level
// for a while, then waits for the cooldown before warning again.
import QtQuick
import org.kde.notification
import "logic.js" as Logic

QtObject {
    id: watcher

    property string sensorId
    property var cfg
    property var styles: ({})

    property real criticalSince: 0
    property real lastNotified: 0

    readonly property MetricModel model: MetricModel {
        sensorId: watcher.sensorId
        cfg: watcher.cfg
        styles: watcher.styles
    }

    readonly property Notification notification: Notification {
        componentName: "plasma_workspace"
        eventId: "notification"
        iconName: "dialog-warning"
        title: i18n("%1 is critical", watcher.model.title)
        text: i18n("%1 for more than %2 seconds.", watcher.model.valueText, watcher.cfg.alertSeconds)
    }

    readonly property Timer timer: Timer {
        interval: 1000
        repeat: true
        running: watcher.cfg.alertsEnabled && (watcher.model.isPercent || watcher.model.isTemp)
        onTriggered: watcher.check()
    }

    function check() {
        const now = Date.now()
        const crit = model.isPercent ? cfg.percentCrit : cfg.tempCrit
        if (!model.ready || Logic.level(model.value, crit, crit) < 2) {
            criticalSince = 0
            return
        }
        if (criticalSince === 0) criticalSince = now
        const longEnough = now - criticalSince >= cfg.alertSeconds * 1000
        const cooledDown = now - lastNotified >= cfg.alertCooldown * 60000
        if (longEnough && cooledDown) {
            lastNotified = now
            notification.sendEvent()
        }
    }
}

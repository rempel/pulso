// SPDX-License-Identifier: GPL-3.0-or-later
// Pure helpers shared by the panel and the popup.
.pragma library

function valid(v) {
    return v !== undefined && v !== null && v !== "" && !isNaN(v);
}

// Picks one of the bundled icons (contents/icons/pulso-<name>.svg) from the sensor id.
// Order matters: a GPU temperature should get the thermometer, not the GPU icon.
function iconFor(sensorId) {
    const id = String(sensorId).toLowerCase();
    if (/temp|tctl|tdie|thermal/.test(id)) return "temp";
    if (/fan|rpm/.test(id)) return "fan";
    if (/battery|power\/|charge/.test(id)) return "battery";
    if (/^gpu\//.test(id)) return "gpu";
    if (/^cpu\//.test(id)) return "cpu";
    if (/^memory\//.test(id)) return "ram";
    if (/^network\/.*(download|receiv)/.test(id)) return "down";
    if (/^network\/.*(upload|transmit|sent)/.test(id)) return "up";
    if (/^network\//.test(id)) return "net";
    if (/^disk\//.test(id)) return "disk";
    return "pulse";
}

// Compact transfer rate for the panel: "512 B/s", "84 K/s", "1.2 M/s"
function speed(bytes) {
    if (!valid(bytes)) return "–";
    if (bytes < 1024) return Math.round(bytes) + " B/s";
    if (bytes < 1024 * 1024) return Math.round(bytes / 1024) + " K/s";
    if (bytes < 1024 * 1024 * 1024) return (bytes / 1048576).toFixed(1) + " M/s";
    return (bytes / 1073741824).toFixed(1) + " G/s";
}

// "2d 3h 15min"
function duration(seconds) {
    if (!valid(seconds)) return "–";
    const d = Math.floor(seconds / 86400);
    const h = Math.floor(seconds % 86400 / 3600);
    const m = Math.floor(seconds % 3600 / 60);
    return (d > 0 ? d + "d " : "") + (d > 0 || h > 0 ? h + "h " : "") + m + "min";
}

// 0 = normal, 1 = warning, 2 = critical
function level(value, warn, crit) {
    if (!valid(value)) return 0;
    if (value >= crit) return 2;
    if (value >= warn) return 1;
    return 0;
}

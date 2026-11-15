// SPDX-License-Identifier: GPL-3.0-or-later
// Pure helpers shared by the panel, the desktop cards, the popup and the settings.
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

// Compact transfer rate: "512 B/s", "84 K/s", "1.2 M/s"
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

function fixed(value, decimals) {
    return Number(value).toFixed(Math.max(0, Math.min(3, decimals)));
}

// ── Per-sensor styles (stored as JSON in the "styles" config key) ──────────

function parseStyles(json) {
    try {
        const o = JSON.parse(json || "{}");
        return o && typeof o === "object" && !Array.isArray(o) ? o : {};
    } catch (e) {
        return {};
    }
}

const ACTIONS = ["", "popup", "monitor", "terminal", "none"];

// Normalized style for one sensor, with defaults filled in.
function styleFor(styles, sensorId) {
    const s = (styles && styles[sensorId]) || {};
    return {
        label: typeof s.label === "string" ? s.label : "",
        icon: typeof s.icon === "string" ? s.icon : "",
        iconMask: s.iconMask !== false,
        color: typeof s.color === "string" && /^#[0-9a-fA-F]{6,8}$/.test(s.color) ? s.color : "",
        decimals: typeof s.decimals === "number" && s.decimals >= 0 && s.decimals <= 3 ? s.decimals : -1,
        action: ACTIONS.indexOf(s.action) >= 0 ? s.action : ""
    };
}

// Returns a copy of `styles` with one field of one sensor changed.
// Default values are dropped so the stored JSON stays small.
function withStyle(styles, sensorId, key, value) {
    const out = JSON.parse(JSON.stringify(styles || {}));
    const s = out[sensorId] || {};
    s[key] = value;
    const defaults = { label: "", icon: "", iconMask: true, color: "", decimals: -1, action: "" };
    for (const k in defaults) {
        if (s[k] === defaults[k]) delete s[k];
    }
    if (Object.keys(s).length === 0) delete out[sensorId];
    else out[sensorId] = s;
    return out;
}

// Icon source for Kirigami.Icon: custom file, theme icon name, or bundled icon.
// `bundledBase` is the URL of the icons folder (ends with "/").
function iconSource(style, sensorId, bundledBase) {
    if (style.icon.indexOf("file:") === 0) return style.icon;
    if (style.icon.indexOf("theme:") === 0) return style.icon.substring(6);
    return bundledBase + "pulso-" + iconFor(sensorId) + ".svg";
}

// Only fixed, built-in commands: nothing from the config is ever executed.
function command(action) {
    if (action === "monitor") return "plasma-systemmonitor";
    if (action === "terminal")
        return "sh -c 'T=$(command -v konsole || command -v x-terminal-emulator); "
             + "exec \"$T\" -e sh -c \"command -v htop >/dev/null && exec htop || exec top\"'";
    return "";
}

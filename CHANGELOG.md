# Changelog

## Unreleased

- Gauges get a little breathing room inside the desktop cards.
- New README with a banner, logo and screenshots of every view and settings page.

## 2.0.0 — 2026-11-15

- **Per-sensor customization**: label, icon (automatic, from the icon theme, or your own SVG/PNG), color, decimals and click action.
- **Appearance settings**: font family, size and weight, icon size, spacing between items.
- **History line** next to each value in the panel (optional).
- **Desktop mode**: on the desktop, Pulso shows cards with a gauge, a history graph or a big number; automatic or fixed columns.
- **Alerts**: desktop notification when a sensor stays at the critical level for a configurable time, with a cooldown.
- **Top processes** in the popup, normalized to total CPU, with a two-click "end process" button.
- **Click actions**: details popup, System Monitor, terminal with htop, or nothing — for the whole widget or per sensor.
- **Presets** (Default, Colorful, Text labels, Graphs, Compact) and **export/import** of the whole setup as JSON.
- Friendlier default names for common sensors (CPU, Memory, CPU temperature…).
- Settings are now split into six pages: General, Sensors, Appearance, Desktop, Alerts & popup, Presets.

## 1.0.1 — 2026-11-15

- Fix: the sensor list in the settings opened empty every time, even though the sensors were saved.

## 1.0.0 — 2026-11-15

- First public version.
- Panel view: icon + value for any ksystemstats sensor, chosen with KDE's sensor picker.
- Bundled monochrome icons, picked automatically from the sensor type (CPU, RAM, temperature, GPU, fan, network, disk, battery).
- Orange/red colors above configurable limits for percentages and temperatures.
- Hides sensors that don't exist on the machine (or temperatures stuck at 0).
- Horizontal and vertical panels.
- Popup with processor, temperature, graphics card, memory, network and disk details.
- English and Brazilian Portuguese.

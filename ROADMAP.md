# Roadmap

What Pulso does today and what may come next. Ideas and pull requests are welcome.

## Done

### 1.0 — the essentials
- [x] Any ksystemstats sensor, picked with KDE's own sensor picker and reordered by drag
- [x] Bundled monochrome icons chosen from the sensor type
- [x] Warning/critical colors for percentages and temperatures
- [x] Hides sensors that don't exist on the machine (or temperatures stuck at 0)
- [x] Horizontal and vertical panels
- [x] English base + Brazilian Portuguese
- [x] `.plasmoid` built and released by GitHub Actions on every `v*` tag

### 2.0 — make it yours
- [x] **Per-sensor customization**: label, icon (automatic, from the icon theme, or your own SVG/PNG), color, decimals, click action
- [x] **Global look**: font family, size and weight, icon size, spacing
- [x] **History line in the panel** next to each value
- [x] **Desktop mode**: cards with a gauge, a history graph or a big number; automatic or fixed columns; works with the standard/translucent/no-background setting of Plasma
- [x] **Presets**: Default, Colorful, Text labels, Graphs, Compact
- [x] **Backup and share**: the whole setup as JSON, copy and import
- [x] **Alerts**: notification when a sensor stays critical for N seconds, with a cooldown
- [x] **Top processes** in the popup, with a two-click "end process" button
- [x] **Click actions**: popup, System Monitor, terminal with htop, or nothing — per sensor or for the whole widget

## Next

- [ ] Publish on the KDE Store
- [ ] Per-sensor thresholds (today they are per type: percentages and temperatures)
- [ ] Per-sensor history line toggle in the panel
- [ ] More translations (copy `po/pt_BR.po` and translate)
- [ ] Network speed: choose bits or bytes
- [ ] Optional sensor groups in the popup (pick which sections to show)

## Not planned

- **Running custom shell commands on click.** Presets can be shared as JSON; letting a preset carry a command
  would make importing one a way to run code. Actions stay a fixed, built-in list.

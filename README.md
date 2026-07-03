# K1C + CFS-C: Change Filament G-code — External Poop

Filament change G-code for the **Creality K1C + CFS-C** (multicolor printing via OrcaSlicer). Instead of relying on a giant purge tower, it poops externally at the corner of the bed and ejects the purged filament by shaking the Y axis.

📄 **The code lives in [`k1c_cfs_poop.gcode`](k1c_cfs_poop.gcode)** — every line commented.

## Installation

1. In Slicer: **Printer Settings → Machine G-code → Change filament G-code**
2. Paste the contents of [`k1c_cfs_poop.gcode`](k1c_cfs_poop.gcode) into the printer settings, under the **Machine G-code** tab, inside the **Change filament G-code** field
3. Calibrate the values flagged in the file header (poop position, purge volume, shake travel range)

## Full operation sequence

```
1. Spiral lift          → Raises 1mm in a spiral (anti-blob, stock code)
2. X215 Y215            → Moves to the poop corner (rear right)
3. Z{z_after_toolchange}→ Returns to the toolchange height
4. T[next_extruder]     → CFS-C performs the physical filament swap
5. G91 / Z+15           → Raises 15mm in relative mode (safe)
6. G90 / M83            → Absolute for X/Y, relative for E
7. X215 Y215            → Repositions at the poop corner
8. M106 S10 / G4 P500   → Fan very low + 0.5s dwell (fan spin-up)
9. E{flush_length}      → Poop with the NEW filament (volume from the color matrix, capped at E160)
10. G4 P1000            → 1s dwell (relieves nozzle pressure)
11. E-1.0               → Light retraction (prevents ooze)
12. M106 S220           → Fan high (solidifies the poop, blows it away from the bed)
13. G92 E0              → Resets the extruder counter
14. G4 P1000            → Waits for the poop to cool and harden
15. X213 Y200 / Z4      → Positions low for the shake
16. Y223 ↔ Y200 ×5     → Shakes back and forth (detaches the poop)
17. G4 P500             → Final dwell before resuming the print
```

---

## Calibration

Values to tune in the G-code header for your machine:

| Parameter | Default | What it is |
|---|---|---|
| Poop position | `X215 Y215` | A free corner of your bed |
| Purge volume | `E{flush_length}` | Computed by the slicer per color pair (see below) |
| Purge ceiling | `E160` | Applied when the matrix asks for more than 150mm — a bigger poop may not detach on the shake |
| Shake travel | `X213`, `Y200–Y223` | The move that ejects the poop |
| Shake height | `Z4` | Never use Z0 — risk of crashing into the bed |

---

## Dynamic purge volume (color-aware)

The purge volume is **not fixed** — the G-code uses the `{flush_length}` placeholder, which the slicer computes for each specific color transition:

1. Open **Flushing volumes** (button next to the filament list) and click **Auto-calc** — the slicer fills the matrix based on each filament's color: dark → light transitions get large volumes, light → dark get small ones
2. The **Flushing multiplier** (`0.3`) scales the whole matrix down for minimal waste — raise it toward `0.5` only if light colors still come out contaminated
3. Fine-tune individual matrix cells if one specific transition needs more (or less) purge — the cell value is in mm³ (1mm of 1.75mm filament ≈ 2.4mm³)

Expected `E` values after the multiplier, as a sanity reference:

| Transition | Expected purge |
|---|---|
| ⬛ Black → ⬜ White / 🟡 Yellow | `~E120–E150` |
| ⬛ Black → 🔴 Red / 🟠 Orange | `~E80–E100` |
| 🔵 Dark → 🟡 Light (any) | `~E60–E80` |
| 🟡 Light → ⬛ Dark | `~E25–E40` |

**Validate before printing**: slice a small multicolor test and search the generated G-code for the `DEBUG: purge computed` lines — they show the exact volume calculated for each transition.

---

## OrcaSlicer Settings alongside this G-code

Goal: all the purging happens in the external poop, keeping the prime tower as small as possible.

| Where | Setting | Value |
|---|---|---|
| Printer Settings | **Purge in prime tower** | ❌ disabled — the poop already purges; the tower must not repeat it |
| Process → Others | **Flushing multiplier** | `0.3` |
| Process → Others | **Minimal purge on wipe tower** | `15 mm³` |
| Process → Others | **Prime tower width** | `25 mm` (just enough to stabilize pressure after the swap) |
| Process → Flush options | **Flush into objects' infill** | optional — diverts purge into hidden infill for extra savings (avoid with translucent parts) |

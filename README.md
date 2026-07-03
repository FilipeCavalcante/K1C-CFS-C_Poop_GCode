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
7. M106 S50             → Fan low during the purge
8. X215 Y215            → Repositions at the poop corner
9. E100                 → Poop with the NEW filament (purges previous color)
10. G4 P1000            → 1s dwell (relieves nozzle pressure)
11. E-1.0               → Light retraction (prevents ooze)
12. M106 S220           → Fan high (solidifies the poop)
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
| Purge volume | `E100` | Adjust using the transition table below |
| Shake travel | `X213`, `Y200–Y223` | The move that ejects the poop |
| Shake height | `Z4` | Never use Z0 — risk of crashing into the bed |

---

## Poop Volume per Color Transition

| Transition | Suggested `E` value |
|---|---|
| ⬛ Black → ⬜ White / 🟡 Yellow | `E120–E150` |
| ⬛ Black → 🔴 Red / 🟠 Orange | `E80–E100` |
| 🔵 Dark → 🟡 Light (any) | `E60–E80` |
| 🟡 Light → ⬛ Dark | `E20–E40` |

---

## OrcaSlicer Settings alongside this G-code

| Where | Setting | Value |
|---|---|---|
| Process → Others | **Flushing volume** | `30–50 mm³` |
| Process → Others | **Minimal purge on wipe tower** | `15 mm³` |
| Process → Others | **Flushing multiplier** | `0.3` |

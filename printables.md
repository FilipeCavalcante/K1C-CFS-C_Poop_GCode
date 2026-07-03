# Printables.com Listing — K1C + CFS-C External Poop G-code

> Draft content for the Printables publication. Copy each section into the corresponding field on printables.com.

---

## Title

**K1C + CFS-C: External Poop Filament Change G-code (Bambu-style, color-aware purge)**

## Summary (short description)

Change filament G-code for the Creality K1C + CFS-C that replaces the giant purge tower with an external "poop": it purges at a free corner of the bed, adjusts the purge volume automatically per color transition, and flings the waste off the bed by shaking the Y axis.

---

## Description

### 🎯 What it does

Multicolor printing on the K1C + CFS-C normally wastes a lot of filament on the purge/prime tower. This G-code moves the purging **off the print area**, Bambu Lab style:

- 💩 **External poop** — after each filament swap, the nozzle purges at the rear-right corner of the bed instead of on a tall purge tower
- 🎨 **Color-aware purge volume** — uses the slicer's `{flush_length}` placeholder, so black → white purges a lot while light → dark purges almost nothing (computed from your Flushing volumes matrix, capped at E160)
- 🪃 **Shake-off ejection** — the fan solidifies the poop, then the toolhead shakes back and forth on Y at high speed to fling it off the bed
- 🗼 **Minimal prime tower** — the tower shrinks to a small pressure-stabilizer instead of a purge dump

### ⚙️ How it works (sequence)

1. CFS-C performs the physical filament swap (`T[next_extruder]`)
2. Nozzle lifts 15mm and moves to the poop corner (X215 Y215)
3. Purges `{flush_length}` mm of the new filament with the part fan very low
4. Short dwell + light retraction to relieve pressure and prevent ooze
5. Fan goes high to solidify the poop
6. Toolhead drops to Z4 and shakes Y200 ↔ Y223 five times — the poop falls off the back of the bed
7. Control returns to the slicer and the print resumes

Every line of the G-code is commented — open the file to see exactly what each command does.

### 📥 Installation (OrcaSlicer)

1. Download `k1c_cfs_poop.gcode` from the Files section
2. Open **Printer Settings → Machine G-code** tab
3. Paste the contents into the **Change filament G-code** field

### 🔧 Required configuration

**Flushing volumes matrix** (button next to the filament list):

- Click **Auto-calc** so the slicer computes purge volumes from your filament colors
- Fine-tune individual cells if a specific transition needs more or less purge (cell values are in mm³; 1mm of 1.75mm filament ≈ 2.4mm³)

**Process → Others / Flush options:**

| Setting | Value |
|---|---|
| Flushing multiplier | `0.3` (raise toward `0.5` if light colors come out contaminated) |
| Minimal purge on wipe tower | `15 mm³` |
| Prime tower width | `25 mm` |
| Flush into objects' infill | optional — extra savings, avoid on translucent parts |

**Printer Settings:**

| Setting | Value |
|---|---|
| Purge in prime tower | ❌ disabled — the poop already purges; the tower must not repeat it |

### 📐 Calibration for your machine

Values you may need to adjust in the G-code header:

- **X215 Y215** — poop position; pick a free corner of *your* bed
- **X213, Y200–Y223** — shake travel that ejects the poop
- **Z4** — height during the shake (never use Z0 — bed crash risk)
- **E160 ceiling** — bigger poops may not detach on the shake

### ✅ Validate before printing

Slice a small multicolor test and search the generated G-code for the `DEBUG: purge computed` lines — they show the exact purge volume calculated for each color transition.

### ⚠️ Disclaimer

Tested on a Creality K1C + CFS-C with OrcaSlicer. Coordinates assume a stock K1C bed (220×220). Watch the first color changes of your first print closely — every machine and bed setup is slightly different. Use at your own risk.

### 🔗 Source

Latest version, issues and contributions: https://github.com/FilipeCavalcante/K1C-CFS-C_Poop_GCode

---

## License

Select **CC BY 4.0 (Attribution)** in the Printables license picker — free use, including commercial, with attribution. The GitHub repository is published under the MIT license (its closest software equivalent).

## Suggested category

3D Printer Accessories → (or) Other

## Suggested tags

`k1c` `cfs` `creality` `multicolor` `purge` `poop` `gcode` `orcaslicer` `filament-change` `waste-reduction`

## Files to upload

- `k1c_cfs_poop.gcode`

G2 Z{z_after_toolchange + 1} I0.86 J0.86 P1 F10000 ; spiral lift: raise 1mm in a spiral (prevents blob at the toolchange point)
;G1 X42 Y180 F30000                                ; (disabled) old poop position
G1 X215 Y215 F30000                                ; fast move to the rear-right corner (poop area)
G1 Z{z_after_toolchange} F600                      ; return to the toolchange height set by the slicer

; ============================================================
; K1C + CFS-C: External poop with shake-off ejection
; Printer Settings → Machine G-code → Change filament G-code
; ============================================================
; ⚠️  CALIBRATION REQUIRED:
;   X215 Y215 → free corner of your bed for the poop
;   Purge volume → dynamic via {flush_length}: comes from the
;     Flushing volumes matrix × Flushing multiplier (0.3);
;     capped at E160 whenever the matrix asks for more than 150mm
;   X213 Y200–Y223 → shake travel range to eject the poop
;   Z4        → height during the shake (never use Z0)
; ============================================================

{if previous_extruder >= 0 and previous_extruder != next_extruder}   ; only runs on an actual color change

    ; --- STEP 1: Swap the filament in the CFS-C BEFORE pooping ---
    T[next_extruder]        ; CFS-C unloads the current filament and loads the new one

    ; --- STEP 2: Lift in relative mode ---
    G91                     ; relative mode (safe move regardless of current Z)
    G1 Z15 F30000           ; raise 15mm to move the nozzle away from the part
    G90                     ; back to absolute mode for X/Y/Z
    M83                     ; extruder in relative mode (E becomes an amount, not a position)

    ; --- STEP 3: External poop (dynamic purge volume) ---
    G1 X215 Y215 F10000     ; reposition at the poop corner
    M106 P0 S10             ; part fan very low (~4%) during the purge
    G4 P500                 ; dwell 0.5s (fan spin-up before purging)
    ; DEBUG: purge computed for this transition = {flush_length}mm
    {if flush_length > 150}
    G1 E160 F300            ; ceiling: caps the purge at 160mm (a bigger poop may not detach on the shake)
    {else}
    G1 E{flush_length} F300 ; purge exactly what the color matrix computed
    {endif}
    G4 P1000                ; dwell 1s to relieve nozzle pressure
    G1 E-1.0 F600           ; light 1mm retraction (prevents ooze)
    M106 P0 S220            ; part fan high (~86%) to solidify the poop and blow away from bed
    G92 E0                  ; reset the extruder counter


    ; --- STEP 4: Fling the poop away ---
    G4 P1000                ; wait 1s for the poop to cool and harden while stuck to the nozzle
    G1 X213 Y200 F10000     ; position at the start of the shake
    G1 Z4 F10000            ; lower to Z4 (safe height, clear of the bed)
    G1 Y223 F20000          ; shake 1: move back at high speed
    G1 Y200 F20000          ; shake 1: return forward
    G1 Y223 F20000          ; shake 2: move back
    G1 Y200 F20000          ; shake 2: return forward
    G1 Y223 F20000          ; shake 3: final pass (poop falls off the bed)
    G4 P500                 ; dwell 0.5s before handing control back to the slicer

{endif}                     ; end of the toolchange conditional block

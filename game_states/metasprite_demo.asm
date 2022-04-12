.bank 0 slot 0
; -----------------------------------------------------------------------------
.section "Metasprite Demo" free
; -----------------------------------------------------------------------------
  initialize_metasprite_demo:
    di
    INITIALIZE_VDP sweetie16_palette 1
    jp +
      sweetie16_palette:
        .db $00 $00 $11 $12 $17 $1B $2E $19 $14 $10 $35 $38 $3D $3F $2A $15
        .db $23 $00 $11 $12 $17 $1B $2E $19 $14 $10 $35 $38 $3D $3F $2A $15
    +:

    call refresh_sat_handler
    call refresh_input_ports

    ei
    halt
    halt
    call load_sat
    
    ld a,ENABLED
    call set_display

    SET_GAME_STATE run_metasprite_demo

  jp main_loop


  run_metasprite_demo:
    call wait_for_vblank
    
    ; Begin vblank critical code (DRAW) ---------------------------------------
    call load_sat

    ; End of critical vblank routines. ----------------------------------------

    ; Begin general updating (UPDATE).
    
    call refresh_sat_handler
    call refresh_input_ports

  jp main_loop
.ends
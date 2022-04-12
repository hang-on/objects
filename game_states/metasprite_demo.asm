.bank 0 slot 0
; -----------------------------------------------------------------------------
.section "Metasprite Demo" free
; -----------------------------------------------------------------------------
  initialize_metasprite_demo:
    di
    ld hl,vdp_register_init
    call initialize_vdp_registers    
    call clear_vram

    ld a,1
    ld b,BORDER_COLOR
    call set_register

    call refresh_sat_handler
    call refresh_input_ports

    ei
    halt
    halt
    call load_sat
    
    ld a,ENABLED
    call set_display

    ld a,RUN_METASPRITE_DEMO
    ld (game_state),a
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
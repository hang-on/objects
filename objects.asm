; Objects. 
.sdsctag 1.0, "Objects", "...", "hang-on Entertainment"
; -----------------------------------------------------------------------------
.memorymap
; -----------------------------------------------------------------------------
  defaultslot 0
  slotsize $4000
  slot 0 $0000
  slot 1 $4000
  slot 2 $8000
  slotsize $2000
  slot 3 $c000
.endme
.rombankmap ; 128K rom
  bankstotal 8
  banksize $4000
  banks 8
.endro
;
.include "libraries/sms_constants.asm"

;.equ TEST_MODE           ; Enable/disable test mode.
.ifdef TEST_MODE
  .equ USE_TEST_KERNEL
.endif

.bank 0 slot 0
.section "Game states" free
  ; ---------------------------------------------------------------------------
  game_states:
    .dw initialize_metasprite_demo, run_metasprite_demo
    __:
  ; ---------------------------------------------------------------------------
.ends

; Hierarchy: Most fundamental first. 
.include "libraries/vdp_lib.asm"
.include "libraries/input_lib.asm"
.include "libraries/tiny_games.asm"
.include "libraries/subroutines.asm"

; -----------------------------------------------------------------------------
.ramsection "Variables" slot 3
; -----------------------------------------------------------------------------
  temp_byte db                  ; Temporary variable - byte.
  temp_word db                  ; Temporary variable - word.
  temp_counter dw               ; Temporary counter.
  temp_composite_counter dsb 3
  ;
  vblank_counter db
  hline_counter db
  pause_flag db
  ;
  rnd_seed dw
  game_state db
.ends

.org 0
.bank 0 slot 0
; -----------------------------------------------------------------------------
.section "Boot" force
; -----------------------------------------------------------------------------
  boot:
  di
  im 1
  ld sp,$dff0
  ;
  ; Initialize the memory control registers.
  ld de,$fffc
  ld hl,initial_memory_control_register_values
  ld bc,4
  ldir
  FILL_MEMORY $00
  ;
  jp init
  ;
  initial_memory_control_register_values:
    .db $00,$00,$01,$02
.ends
.org $0038
; ---------------------------------------------------------------------------
.section "!VDP interrupt" force
; ---------------------------------------------------------------------------
  push af
  push hl
    in a,CONTROL_PORT
    bit INTERRUPT_TYPE_BIT,a  ; HLINE or VBLANK interrupt?
    jp z,+
      ld hl,vblank_counter
      inc (hl)
      jp ++
    +:
      ld hl,hline_counter
      inc (hl)
    ++:
  pop hl
  pop af
  ei
  reti
.ends
.org $0066
; ---------------------------------------------------------------------------
.section "!Pause interrupt" force
; ---------------------------------------------------------------------------
  push af
    ld a,(pause_flag)
    cpl
    ld (pause_flag),a
  pop af
  retn
.ends
; -----------------------------------------------------------------------------
.section "main" free
; -----------------------------------------------------------------------------
  init:
  ; Run this function once (on game load/reset). 
    ld hl,vdp_register_init
    call initialize_vdp_registers
    call clear_vram
    
    ld a,1
    ld b,BORDER_COLOR
    call set_register
    ld a,0
    ld b,32
    ld hl,all_black_palette
    call load_cram
    jp +
      sweetie16_palette:
        .db $00 $00 $11 $12 $17 $1B $2E $19 $14 $10 $35 $38 $3D $3F $2A $15
        .db $00 $00 $11 $12 $17 $1B $2E $19 $14 $10 $35 $38 $3D $3F $2A $15
      all_black_palette:
        .db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
        .db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
      test_palette:
        .db $00 $2E $17 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
        .db $00 $2E $17 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00
    +:

    ; Seed the randomizer.
    ld hl,my_seed
    ld a,(hl)
    ld (rnd_seed),a
    inc hl
    ld a,(hl)
    ld (rnd_seed+1),a
    jp +
      my_seed:
      .dbrnd 2, 0, 255
    +:


    .ifdef TEST_MODE
      ld a,0
      ld b,32
      ld hl,test_palette
      call load_cram

      ld a,ENABLED
      call set_display
      jp test_bench
    .endif

    SET_GAME_STATE initialize_metasprite_demo

  jp main_loop

    vdp_register_init:
    .db %01100110  %10100000 $ff $ff $ff
    .db $ff $fb $f0 $00 $00 $00

  ; ---------------------------------------------------------------------------
  main_loop:
    ld a,(game_state)   ; Get current game state - it will serve as JT offset.
    add a,a             ; Double it up because jump table is word-sized.
    ld h,0              ; Set up HL as the jump table offset.
    ld l,a
    ld de,game_states   ; Point to JT base address
    add hl,de           ; Apply offset to base address.
    ld a,(hl)           ; Get LSB from table.
    inc hl              ; Increment pointer.
    ld h,(hl)           ; Get MSB from table.
    ld l,a              ; HL now contains the address of the state handler.
    jp (hl)             ; Jump to this handler - note, not call!
  ; ---------------------------------------------------------------------------
.ends

.include "subroutine_workshop.asm"
.include "game_states/tests.asm"
.include "game_states/metasprite_demo.asm"        

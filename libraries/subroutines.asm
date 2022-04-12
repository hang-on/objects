; General project-specific subroutines, helper functions and macros.

.macro SET_GAME_STATE ARGS GAME_STATE
  ld hl,GAME_STATE
  ld de,game_states
  ld b,_sizeof_game_states
  call search_word_array
  ld (game_state),a
.endm

.macro INITIALIZE_VDP ARGS PALETTE BORDERCOL
  ld hl,vdp_register_init
  call initialize_vdp_registers    
  call clear_vram
  ld a,0
  ld b,32
  ld hl,PALETTE
  call load_cram
  ld a,BORDERCOL
  ld b,BORDER_COLOR
  call set_register
.endm

.bank 0 slot 0
; -----------------------------------------------------------------------------
.section "Subroutines" free
; -----------------------------------------------------------------------------

.ends
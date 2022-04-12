; General project-specific subroutines, helper functions and macros.

.macro SET_GAME_STATE ARGS GAME_STATE
  ld hl,GAME_STATE
  ld de,game_states
  ld b,_sizeof_game_states
  call search_word_array
  ld (game_state),a
.endm

.bank 0 slot 0
.section "Subroutines" free

.ends
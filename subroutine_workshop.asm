
.ramsection "Ram section for library being developed" slot 3

.ends

.bank 0 slot 0
; -----------------------------------------------------------------------------
.section "Subroutine workshop" free
; -----------------------------------------------------------------------------
  get_index:
    ; In: HL: Label
    ;     DE: Jump table base addresse

  ret

  compare_words:
    ; In: HL and DE holds the words to compare.
    ; Out: Carry set if hl = de, else carry reset.
    ; Uses: A
    push hl
      sbc hl,de
    pop hl
    jp nz,+
      scf
      ret
    +:
    or a
  ret

  search_byte_array:
    ; In: A = Byte to search for.
    ;     HL = Pointer to byte array.
    ;     B = Length of byte array.
    ; Out: Carry set = byte found, else carry reset.
    ;     A = Index of byte (if found).
    ; Uses: A, BC, D, HL
    ld d,0
    ld c,a
    -:
      ld a,(hl)
      cp c
      jp nz,+
        ld a,d
        scf
        ret
      +:
      inc hl
      inc d
    djnz -
    or a
    ld a,d
  ret

  search_word_array:
   scf 

  ret
.ends

.ramsection "Ram section for library being developed" slot 3

.ends

.bank 0 slot 0
; -----------------------------------------------------------------------------
.section "Subroutine workshop" free
; -----------------------------------------------------------------------------

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
    ; Search for a given word in an array, and return with carry and index
    ; if word is found. 
    ; In:   HL = Word to search for.
    ;       DE = Pointer to word array to search.
    ;       B = Word items to search.
    ; Out:  Carry set if word is found, else carry reset.
    ;       A = Index of wound found (if any).
    ; Uses: A, BC, DE, HL.

    ld a,h    ; Preserve MSB of search item.         
    ld c,l    ; Preserve LSB of search item.
    ex de,hl  ; Get the word array pointer into HL.
    ld e,a    ; Load search item MSB into E.
    ld d,c    ; Load search item LSB into D  
    ld c,0    ; Reset C to count table index.
    -:
      ld a,(hl)       ; Load table item LSB.
      cp d            ; Compare to search item LSB.
      jp nz,+         ; If no match, then skip ahead...
        ld a,e        ; Match! Get the search item MSB.
        inc hl        ; Point to table item MSB.
        cp (hl)       ; Compare search item MSB to table item MSB.
        dec hl        ; Back to table item LSB (see the 2 x inc hl below).
        jp nz,+       ; If no match, skip ahead...
          ld a,c      ; Match! Load the table index into A
          scf         ; Set the carry flag.
          ret         ; Return.
      +:    
      inc hl          ; Skip MSB of table item.
      inc hl          ; Point to LSB of next table item.
      inc c           ; Increment index counter.
    djnz -            ; Next item...
    or a              ; Fall through to here... reset carry flag.
  ret                 ; Return: Word not found.
.ends
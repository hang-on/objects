; tiny_games.asm.
; General library of definitions, macros and functions.

.equ ENABLED $ff
.equ DISABLED 0
.equ TRUE $ff
.equ FALSE 0

; -----------------------------------------------------------------------------
.macro FILL_MEMORY args value
; -----------------------------------------------------------------------------
;  Fills work RAM ($C001 to $DFF0) with the specified value.
  ld    hl, $C001
  ld    de, $C002
  ld    bc, $1FEE
  ld    (hl), value
  ldir
.endm
; -----------------------------------------------------------------------------
.macro RESTORE_REGISTERS
; -----------------------------------------------------------------------------
  ; Restore all registers, except IX and IY
  pop iy
  pop ix
  pop hl
  pop de
  pop bc
  pop af
.endm
; -----------------------------------------------------------------------------
.macro SAVE_REGISTERS
; -----------------------------------------------------------------------------
  ; Save all registers, except IX and IY
  push af
  push bc
  push de
  push hl
  push ix
  push iy
.endm
; -----------------------------------------------------------------------------
.macro SELECT_BANK_IN_REGISTER_A
; -----------------------------------------------------------------------------
  ; Select a bank for slot 2, - put value in register A.
  .ifdef USE_TEST_KERNEL
    ld (test_kernel_bank),a
  .else
    ld (SLOT_2_CONTROL),a
  .endif
.endm
; -----------------------------------------------------------------------------
.macro RESET_VARIABLES ARGS VALUE
; -----------------------------------------------------------------------------
  ; Set one or more byte-sized vars in RAM with the specified value.
  ld a,VALUE
  .rept NARGS-1
    .shift
    ld (\1),a
  .endr
.endm
; -----------------------------------------------------------------------------
.macro RESET_BLOCK ARGS VALUE, START, SIZE
; -----------------------------------------------------------------------------
  ; Reset af block of RAM of SIZE bytes to VALUE, starting from label START.
  ld a,VALUE
  ld hl,START
  .rept SIZE
    ld (hl),a
    inc hl
  .endr
.endm

; -----------------------------------------------------------------------------
.macro LOAD_BYTES
; -----------------------------------------------------------------------------
  ; Load byte-sized variables with matching values. Useful for initializing. 
  ; IN: Pair of byte-sized variable and value to load
  .rept (NARGS/2)
    ld a,\2
    ld (\1),a
    .shift
    .shift
  .endr
.endm

.bank 0 slot 0
; -----------------------------------------------------------------------------
.section "Tiny Games Library" free
; -----------------------------------------------------------------------------
  detect_collision:
    ; Axis-aligned bounding box.
    ;    if (rect1.x < rect2.x + rect2.w &&
    ;    rect1.x + rect1.w > rect2.x &&
    ;    rect1.y < rect2.y + rect2.h &&
    ;    rect1.h + rect1.y > rect2.y)
    ;    ---> collision detected!
    ; In: ix = y,x,h,w of box 1.
    ;     iy = y,x,h,w of box 2.
    ; Out: Carry is set if the boxes overlap.
    
    ; Test 1: rect1.x < rect2.x + rect2.w
    ld a,(iy+1)         
    add a,(iy+3)
    ld b,a
    ld a,(ix+1)
    cp b
    ret nc
      ; Test 2: rect1.x + rect1.w > rect2.x
      ld a,(ix+1)
      add a,(ix+3)
      ld b,a
      ld a,(iy+1)
      cp b
      ret nc
        ;Test 3: rect1.y < rect2.y + rect2.h
        ld a,(iy+0)
        add a,(iy+2)
        ld b,a
        ld a,(ix+0)
        cp b
        ret nc
          ; Test 4: rect1.h + rect1.y > rect2.y
          ld a,(ix+0)
          add a,(ix+2)
          ld b,a
          ld a,(iy+0)
          cp b
          ret nc
    ; Fall through to collision!
    scf
  ret

FadeInScreen:
    ;call PSGSilenceChannels
    halt                   ; wait for Vblank

    xor a
    out ($bf),a            ; palette index (0)
    ld a,$c0
    out ($bf),a            ; palette write identifier

    ld b,32                ; number of palette entries: 32 (full palette)
    ld hl,sweetie16_palette    ; source
 -: ld a,(hl)              ; load raw palette data
    and %00101010          ; modify color values: 3 becomes 2, 1 becomes 0
    srl a                  ; modify color values: 2 becomes 1
    out ($be),a            ; write modified data to CRAM
    inc hl
    djnz -

    ld b,4                 ; delay 4 frames
 -: halt
    djnz -

    ld b,32                ; number of palette entries: 32 (full palette)
    ld hl,sweetie16_palette    ; source
 -: ld a,(hl)              ; load raw palette data
    and %00101010          ; modify color values: 3 becomes 2, 1 becomes 0
    out ($be),a            ; write modified data to CRAM
    inc hl
    djnz -

    ld b,4                 ; delay 4 frames
 -: halt
    djnz -

    ld b,32                ; number of palette entries: 32 (full palette)
    ld hl,sweetie16_palette    ; source
 -: ld a,(hl)              ; load raw palette data
    out ($be),a            ; write unfodified data to CRAM, palette load complete
    inc hl
    djnz -
    ;call PSGRestoreVolumes

ret

FadeOutScreen:
    ;call PSGSilenceChannels
    halt                   ; wait for Vblank

    xor a
    out ($bf),a            ; palette index (0)
    ld a,$c0
    out ($bf),a            ; palette write identifier

    ld b,32                ; number of palette entries: 32 (full palette)
    ld hl,sweetie16_palette    ; source
 -: ld a,(hl)              ; load raw palette data
    and %00101010          ; modify color values: 3 becomes 2, 1 becomes 0
    out ($be),a            ; write modified data to CRAM
    inc hl
    djnz -

    ld b,4                 ; delay 4 frames
 -: halt
    djnz -

    ld b,32                ; number of palette entries: 32 (full palette)
    ld hl,sweetie16_palette    ; source
 -: ld a,(hl)              ; load raw palette data
    and %00101010          ; modify color values: 3 becomes 2, 1 becomes 0
    srl a                  ; modify color values: 2 becomes 1
    out ($be),a            ; write modified data to CRAM
    inc hl
    djnz -

    ld b,4                 ; delay 4 frames
 -: halt
    djnz -

    ld b, 32               ; number of palette entries: 32 (full palette)
    xor a                  ; we want to blacken the palette, so a is set to 0
 -: out ($be), a           ; write zeros to CRAM, palette fade complete
    djnz -
    ;call PSGRestoreVolumes

ret

  function_at_hl:
    ; Emulate a call (hl) function.
    jp (hl)

  get_random_number:
    ; SMS-Power!
    ; Returns an 8-bit pseudo-random number in a
    .ifdef TEST_MODE
      ld a,(rnd_seed)
      ret
    .endif
    push hl
      ld hl,(rnd_seed)
      ld a,h         ; get high byte
      rrca           ; rotate right by 2
      rrca
      xor h          ; xor with original
      rrca           ; rotate right by 1
      xor l          ; xor with low byte
      rrca           ; rotate right by 4
      rrca
      rrca
      rrca
      xor l          ; xor again
      rra            ; rotate right by 1 through carry
      adc hl,hl      ; add RandomNumberGeneratorWord to itself
      jr nz,+
        ld hl,$733c  ; if last xor resulted in zero then re-seed.
      +:
      ld a,r         ; r = refresh register = semi-random number
      xor l          ; xor with l which is fairly random
      ld (rnd_seed),hl
    pop hl
  ret              ; return random number in a

  get_word:
    ; Get the 16-bit value (word) at the address pointed to by HL.
    ; In: Pointer in HL.
    ; Out: Word pointed to in HL.
    ; Uses: DE, HL.
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
  ret

  lookup_byte:
    ; IN: a = value, hl = look-up table (ptr).
    ; OUT: a = converted value.
    ld d,0
    ld e,a
    add hl,de
    ld a,(hl)
  ret

  lookup_word:
    ; IN: a = value, hl = look-up table (ptr).
    ; OUT: hl = converted value (word).
    add a,a
    ld d,0
    ld e,a
    add hl,de
    ld a,(hl)
    ld b,a
    inc hl
    ld a,(hl)
    ld h,a
    ld l,b
  ret

  offset_byte_table:
    ; Offset base address (in HL) of a table of bytes or words. 
    ; Entry: A  = Offset to apply.
    ;        HL = Pointer to table of values (bytes or words).  
    ; Exit:  HL = Offset table address.
    ; Uses:  A, HL
    add a,l
    ld l,a
    ld a,0
    adc a,h
    ld h,a
  ret
  
  offset_word_table:
    add a,a              
    add a,l
    ld l,a
    ld a,0
    adc a,h
    ld h,a
  ret

  offset_custom_table:
    ; IN: A = Table index, HL = Base address of table, 
    ;     B = Size of table item.
    ; OUT: HL = Address of item at specified index.
    cp 0
    ret z    
    ld d,0
    ld e,b
    ld b,a
    -:
      add hl,de
    djnz -
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

  tick_counter:
    ; Decrement a counter (byte) in ram. Reset the counter when it reaches 0, 
    ; and return with carry flag set. Counter format in RAM (word): cc rr, 
    ; where cc is the current counter value and rr is the reset value.
    ; IN: HL = Pointer to counter + reset value.
    ; OUT: Value in counter is decremented or reset, carry set or reset.
    ; Uses: A, HL.
    ld a,(hl)                 ; Get counter.
    dec a                     ; Decrement it ("tick it").
    jp nz,+                   ; Is it 0 now?
      inc hl                  ; If so, point to reset value.
      ld a,(hl)               ; Load it into A.
      dec hl                  ; Point to counter value
      ld (hl),a               ; Load reset value into counter value.
      scf                     ; Set carry flag.
      ret                     ; Return with carry set.
    +:              
    ld (hl),a                 ; Else, load the decremented value into counter.
    or a                      ; Reset carry flag.
  ret                         ; Return with carry reset.

  .macro RESET_COUNTER ARGS COUNTER, VALUE
    ; Easy way to reset a word-sized counter for the tick_counter routine.
    ld a,VALUE
    ld hl,COUNTER
    ld (hl),a
    inc hl
    ld (hl),a
  .endm

  tick_composite_counter:
    ; A composite counter consists of two counter bytes + one reset byte: 
    ; The fine and the coarse counter.
    ; When the composite counter is ticked, the fine counter is decremented.
    ; If itreaches 0, then the coarse counter is decremented. When the coarse
    ; counter reaches 0, it is reset to the specified value, and carry is set.
    ; The composite counter is a 3-byte variable: ff cc rr, where ff is the 
    ; fine counter, cc is the coarse counter, and rr is the coarse counter 
    ; reset value.
    ; In: HL = Pointer to composite counter.
    ; Out: Carry set/reset depending on counter. 
    ; Uses: A, HL
    ld a,(hl)                 ; Get fine counter.
    dec a                     ; Decrement it ("tick it").
    jp nz,+
      ld (hl),a
      ; Decrement the coarse counter.
      ; The fine counter will auto overflow to 255 on next tick.
      inc hl
      ld a,(hl)
      cp 0
      jp nz,++
        ; Reset coarse counter, exit with carry set.
        inc hl
        ld a,(hl)
        dec hl
        ld (hl),a
        scf
        ret
      ++:
      dec a
      ld (hl),a
      ret
    +:
    ld (hl),a                 ;
    or a                      ; Reset carry. 
  ret                         ; 

  .macro RESET_COMPOSITE_COUNTER ARGS VAR, VALUE
    ld hl,VAR
    ld (hl),0
    inc hl
    ld (hl),VALUE
    inc hl
    ld (hl),VALUE
  .endm

  wait_for_scanline:
    ; In: A = scanline to wait for 
    ld b,a
    -:
      in a,($7e)
      cp b
    jp nz,- 
  ret
.ends
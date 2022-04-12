    
        jp +
      jump_table:
        .dw label_0 label_1 label_2
        __:

      label_0:
        nop
      label_1:
        nop
      label_2:
        nop
      label_3:
        nop
      word_table:
        .dw $0001 $0002 $0003
    +:

    ; Test 0:
    ld hl,$0001
    ld a,h
    ASSERT_A_EQUALS $00
    ld a,l
    ASSERT_A_EQUALS $01

    ; Test 1:
    ld hl,$0001
    ld de,word_table
    ld b,3
    call search_word_array
    ASSERT_CARRY_SET
    ASSERT_A_EQUALS 0

    ; Test 2:
    ld hl,$0002
    ld de,word_table
    ld b,3
    call search_word_array
    ASSERT_CARRY_SET
    ASSERT_A_EQUALS 1
    
    ; Test 3:
    ld hl,$0003
    ld de,word_table
    ld b,3
    call search_word_array
    ASSERT_CARRY_SET
    ASSERT_A_EQUALS 2

    ; Test 3:
    ld hl,$0004
    ld de,word_table
    ld b,3
    call search_word_array
    ASSERT_CARRY_RESET

    ; Test 4
    ld hl,label_0
    ld de,jump_table
    ld b,_sizeof_jump_table/2
    call search_word_array
    ASSERT_CARRY_SET
    ASSERT_A_EQUALS 0

    ; Test 5
    ld hl,label_2
    ld de,jump_table
    ld b,_sizeof_jump_table/2
    call search_word_array
    ASSERT_CARRY_SET
    ASSERT_A_EQUALS 2

    ld b,_sizeof_jump_table/2
    ld a,b
    ASSERT_A_EQUALS 3


    
    jp +
      my_byte_array:
        .db $ff $fe $fd
    +:
;

    ld a,$ff
    ld hl,my_byte_array
    ld b,3
    call search_byte_array
    ASSERT_CARRY_SET
    ASSERT_A_EQUALS 0

    ; Test 1a:
    ld a,$fe
    ld hl,my_byte_array
    ld b,3
    call search_byte_array
    ASSERT_CARRY_SET
    ASSERT_A_EQUALS 1

    ; Test 2:
    ld a,0
    ld hl,my_byte_array
    ld b,3
    call search_byte_array
    ASSERT_CARRY_RESET
    ASSERT_A_EQUALS 3

    ; Test 3:
    ld a,$fd
    ld hl,my_byte_array
    ld b,3
    call search_byte_array
    ASSERT_CARRY_SET
    ASSERT_A_EQUALS 2


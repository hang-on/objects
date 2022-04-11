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


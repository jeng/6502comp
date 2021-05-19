    .org $8000
main:
    lda #$ff
loop:
    sta $1000
    ldx $1000
    dex
    stx $1001
    ldy $1001
    dey
    sty $1002
    tya
    jmp loop

    .org $fffc
    .word main
    .word $0000 ;padding

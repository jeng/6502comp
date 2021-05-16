; dasblink2
;
; Run a number of different LEDs patterns
;
; This program can run with the setup at the end of the second video of Ben
; Eater's breadboard 6502. (65c22 hooked up to 8 leds)

    *= $8000
    lda #$ff
    sta $6002

mainLoop:
    lda #$01
    ldy #$0a
cylons:

    ldx #$7
innerloop1:
    sta $6000
    rol
    dex
    bne innerloop1

    ldx #$7
innerloop2:
    sta $6000
    ror
    dex
    bne innerloop2

    dey
    bne cylons

;back and forth
    ldx #$0a
backAndForth:
    lda #$55
    sta $6000
    lda #$aa
    sta $6000
    dex
    bne backAndForth

;move left
    lda #$01
    ldx #$1e
moveLeft:
    sta $6000
    rol
    dex
    bne moveLeft

; noise
    ldy #50 ;load the table length
loadtable:
    lda noise, y ;get a random byte from the table
    sta $6000 ;display the byte
    dey
    bne loadtable ;loop until we are out of table entries

    jmp mainLoop

noise:
    .byte $fa, $1a, $cf, $09, $65, $5e, $fe, $22, $20, $d0, $30 
    .byte $17, $2c, $27, $d2, $b4, $82, $be, $3c, $00, $c6, $89
    .byte $a8, $18, $50, $6e, $65, $10, $e6, $b0, $54, $ac, $1f
    .byte $f0, $ca, $9c, $de, $b6, $7c, $b4, $b3, $8b, $45, $f6
    .byte $a0, $a9, $29, $c4, $49, $b6


    .org $fffc
    .word $8000 ;reset vector
    .word $0000 ;padding


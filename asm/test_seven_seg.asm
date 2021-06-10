; Make sure that PORTA on the 6522 is working by sending stuff to a seven
; segment display
;
; Jeremy English 2021 jhe@jeremyenglish.org

PORTB = $6000
PORTA = $6001
DDRB  = $6002 ; Data direction
DDRA  = $6003

    .org $8000

blank:
    ldx #%00000000
    stx PORTA
    rts

main:
    lda #%11111111       ;set all pins on port A as output
    sta DDRA

    ldx #%00000001
    stx PORTA

main_loop:
    
    ldx #%01111000 ;h
    stx PORTA
    jsr blank

    ldx #%11110010 ;E
    stx PORTA
    jsr blank

    ldx #%10110000 ;L
    stx PORTA
    jsr blank

    ldx #%10110000 ;L
    stx PORTA
    jsr blank

    ldx #%11101000 ;o
    stx PORTA
    jsr blank

    jmp main_loop

nmi:
irq:
    pha
    pla
    rti

    .org $fffa
    .word nmi
    .word main
    .word irq


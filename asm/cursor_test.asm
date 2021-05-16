; test cursor
;
; Move from home to second row and then back to home
;
; This program can run with the setup at the end of the forth video of Ben
; Eater's breadboard 6502.


PORTB = $6000
PORTA = $6001
DDRB  = $6002 ; Data direction
DDRA  = $6003

E  = %10000000
RW = %01000000
RS = %00100000

CHR_PER_DISP   = 16
LINE_PER_DISP  = 2

    .org $8000


reset:
    lda #%11111111 ;set all pins on port B to output
    sta DDRB

    lda #%11100000 ;Set top 3 pins on port A to output
    sta DDRA

    lda #%00111000 ;set 8 bit mode, 2-line display, 5x8 font
    sta PORTB

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    lda #E         ;set the enable bit to send the instruction
    sta PORTA

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    lda #%00001111 ;Display on, cursor on, bink off
    sta PORTB

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    lda #E         ;set the enable bit to send the instruction
    sta PORTA

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    lda #%00000110 ;increment and shift the cursor, do not shift display
    sta PORTB

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    lda #E         ;set the enable bit to send the instruction
    sta PORTA

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    ;
    ; Move to the second line
    ;
    lda #%11000000 ; set DDRAM address to the start of the second line
    sta PORTB

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    lda #E         ;set the enable bit to send the instruction
    sta PORTA

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    ;
    ; Return to the home cursor postion if we stil have junk to print
    ;
    lda #%00000010 ; return home
    sta PORTB

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    lda #E         ;set the enable bit to send the instruction
    sta PORTA

    lda #$0        ;clear RS/RW/E bits
    sta PORTA
 


loop:
    jmp loop

hello:
    .byte "Hello, World!"

    .org $fffc
    .word reset
    .word $0000 ;padding

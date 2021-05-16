; hello world
;
; Pull the string from ROM
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

    lda #%00001110 ;Display on, cursor on, bink off
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


    ldy #0         ; start at the first char in the string
print:
    lda hello,y    ; get a character from the string
    sta PORTB

    lda #RS        ; Set RS
    sta PORTA

    lda #(RS | E)  ; set the enable bit and RS bit to send the instruction
    sta PORTA

    lda #RS        ; set RS
    sta PORTA

    iny            ; move to the next character string
    tya            ; transfer so we can compare
    cmp #13        ; are we at the end of the string
    bne print      ; no? keep printing

loop:
    jmp loop

hello:
    .byte "Hello, World!"

    .org $fffc
    .word reset
    .word $0000 ;padding

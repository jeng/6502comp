; junk scroll
;
; Keep scrolling through the complete character set of the lcd
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

    lda #%00001110 ;Display on, cursor on, blink off
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

print:

    ;
    ; Return to the home cursor position if we still have junk to print
    ;
    lda #%00000010 ; return home
    sta PORTB

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    lda #E         ;set the enable bit to send the instruction
    sta PORTA

    lda #$0        ;clear RS/RW/E bits
    sta PORTA
    jmp print


    ldy #$ff       ; loop over all of the display characters


    ldx #CHR_PER_DISP
print_line1:
    tya            ; print junk
    sta PORTB

    lda #RS        ; Set RS
    sta PORTA

    lda #(RS | E)  ; set the enable bit and RS bit to send the instruction
    sta PORTA

    lda #RS        ; set RS
    sta PORTA

    dey            ; move to the next character
    beq end_print  ; are we done?
    dex            ; move to the next cursor position
    bne print_line1; loop if we still have cursor positions

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
                    
    
    ldx #CHR_PER_DISP
print_line2:
    tya            ; print junk
    sta PORTB

    lda #RS        ; Set RS
    sta PORTA

    lda #(RS | E)  ; set the enable bit and RS bit to send the instruction
    sta PORTA

    lda #RS        ; set RS
    sta PORTA

    dey             ; move to the next character 
    beq end_print   ; are we done?
    dex             ; move to the next cursor position
    bne print_line2 ; loop if we still have cursor positions

end_print:
    jmp print

    .org $fffc
    .word reset
    .word $0000 ;padding

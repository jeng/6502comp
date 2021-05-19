; happy trees
;
; Print some Bob Ross ipsum. https://www.bobrosslipsum.com
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

MSG_LEN = 220

    .org $8000

send_lcd_cmd:
    sta PORTB

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    lda #E         ;set the enable bit to send the instruction
    sta PORTA

    lda #$0        ;clear RS/RW/E bits
    sta PORTA
    rts

put_lcd_char:
    sta PORTB

    lda #RS        ; Set RS
    sta PORTA

    lda #(RS | E)  ; set the enable bit and RS bit to send the instruction
    sta PORTA

    lda #RS        ; set RS
    sta PORTA
    rts


reset:
    lda #%11111111 ;set all pins on port B to output
    sta DDRB

    lda #%11100000 ;Set top 3 pins on port A to output
    sta DDRA

    lda #%00111000 ;set 8 bit mode, 2-line display, 5x8 font
    jsr send_lcd_cmd

    lda #%00001110 ;Display on, cursor on, blink off
    jsr send_lcd_cmd

    lda #%00000110 ;increment and shift the cursor, do not shift display
    jsr send_lcd_cmd

    ldy #0       ; loop over all of the display characters
print:

    ;TODO instead of returning home we really want to scroll down one line.  Is that possible.
    ;Not as a built in feature.  Both the lines scroll at the same time it doesn't scroll up
    ;Also doesn't look like they have a memcopy so the second line would need to be shifted
    ;up by the MPU, cursor moved to the start of the second line and the contents of
    ;the second line overwritten.

    ;
    ; Return to the home cursor position if we still have junk to print
    ;
    lda #%00000010 ; return home
    jsr send_lcd_cmd


    ldx #CHR_PER_DISP
print_line1:
    lda trees,y    ; get a character from the message
    jsr put_lcd_char

    iny            ; move to the next character
    tya
    cmp #MSG_LEN
    beq end_print  ; are we done?
    dex            ; move to the next cursor position
    bne print_line1; loop if we still have cursor positions

    ;
    ; Move to the second line
    ;
    lda #%11000000 ; set DDRAM address to the start of the second line
    jsr send_lcd_cmd
                    
    
    ldx #CHR_PER_DISP
print_line2:
    lda trees,y    ; get a character from the message
    jsr put_lcd_char

    iny             ; move to the next character 
    tya
    cmp #MSG_LEN
    beq end_print   ; are we done?
    dex             ; move to the next cursor position
    bne print_line2 ; loop if we still have cursor positions

end_print:
    tya
    cmp #MSG_LEN ; if we are at the end of the message we need to reset the index
    bne print
    ldy #0       ; loop over all of the display characters
    jmp print

trees:
    .byte "Let's make some happy little clouds in our world. Pretend you're water. Just floating without any effort. Having a good day. Trees grow in all kinds of ways. They're not all perfectly straight. Not every limb is perfect."
    .org $fffc
    .word reset
    .word $0000 ;padding


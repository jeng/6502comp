; display numbers on the lcd
;
; This program is covered in the "Binary to decimal can't be that hard, right?"
; as part of Ben Eater's breadboard 6502.
;

; I change the push_char and write_string routines to work with pascal style
; strings


PORTB = $6000
PORTA = $6001
DDRB  = $6002 ; Data direction
DDRA  = $6003

value = $0200 ; dealing with 16-bit numbers so we need two bytes
mod10 = $0202
message = $0204 ;max 6; zero byte is the length.  
; example string 5|65535
;                L 12345

E  = %10000000
RW = %01000000
RS = %00100000

CHR_PER_DISP   = 16
LINE_PER_DISP  = 2

    .org $8000

lcd_wait:
    pha
    lda #%00000000 ; set port b as input
    sta DDRB 
lcdbusy:
    lda #RW        ; read the busy flag
    sta PORTA
    lda #(RW | E)
    sta PORTA
    lda PORTB
    and #%10000000 ; just get the busy flag
    bne lcdbusy   ; loop when the bit is set

    lda #RW        ; read the busy flag
    sta PORTA
    lda #%11111111 ; set port b as output
    sta DDRB 
    pla
    rts
 
send_lcd_cmd:
    jsr lcd_wait
    sta PORTB

    lda #$0        ;clear RS/RW/E bits
    sta PORTA

    lda #E         ;set the enable bit to send the instruction
    sta PORTA

    lda #$0        ;clear RS/RW/E bits
    sta PORTA
    rts

put_lcd_char:
    pha
    jsr lcd_wait
    sta PORTB

    lda #RS        ; Set RS
    sta PORTA

    lda #(RS | E)  ; set the enable bit and RS bit to send the instruction
    sta PORTA

    lda #RS        ; set RS
    sta PORTA
    pla
    rts

; I wrote this part different from Ben Eater to show how it would
; be handled with a pascal style string
; 
; Push a new character onto a pascal style string
push_char:
    pha
    ;increment the length of the string by one
    inc message

    ;move all of the characters down
    lda message + 4
    sta message + 5 ; 6 

    lda message + 3
    sta message + 4 ; 3

    lda message + 2 
    sta message + 3 ; 5

    lda message + 1
    sta message + 2 ; 5

    pla
    sta message + 1 ; 6
    rts


write_string:
    pha ;save a

    txa ;save x
    pha

    tya ;save y
    pha

    ldx message ; get the length of the string
    ldy #1

write_string_loop:
    lda message,y ; get a character from the message
    jsr put_lcd_char; print it
    iny ; move to the next character
    dex ; decrease the number of chars to print
    bne write_string_loop ; loop if we still have chars to print

    pla
    tay ; restore y
    pla
    tax ; restore x
    pla ; restore a
    rts


main:
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

    lda #%00000010 ; return home
    jsr send_lcd_cmd

    ; set the length of the string to zero
    lda #0
    sta message

    lda number      ; Store both parts of the 16bit number into ram
    sta value
    lda number + 1
    sta value  + 1 

divide:
    lda #0          ; initialize the remainder to zero
    sta mod10
    sta mod10 + 1
    clc

    ldx #16
divloop:
    rol value      ; shift everything to the left
    rol value + 1
    rol mod10
    rol mod10 + 1

   
    sec            ; a, y = dividend - divisor
    lda mod10
    sbc #10
    tay            ; save low byte in Y
    lda mod10 + 1  ; load the high byte
    sbc #0
    bcc ignore_result ; branch if dividend < divisor
    sty mod10
    sta mod10 + 1
    
ignore_result:
    dex
    bne divloop
    rol value       ;shift in the last bit of the quotient
    rol value + 1

    lda mod10
    clc
    adc #"0"   ; if we have 0 in ad
    jsr push_char ; add the character to the message

    ;if value != 0, then continue dividing
    lda value
    ora value + 1
    bne divide ; branch if value not zero

    jsr write_string

loop:
    jmp loop

number: .word 1729

    .org $fffc
    .word main
    .word $0000 ;padding


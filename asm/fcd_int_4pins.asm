; count down from 1729 and wrap when we hit zero
;
; this version works with the LCD in 4-bit mode
;
;
; This program can be used with the first interrupt handling video as part of
; Ben Eater's breadboard 6502.



PORTB = $6000
PORTA = $6001
DDRB  = $6002 ; Data direction
DDRA  = $6003

value = $0200 ; dealing with 16-bit numbers so we need two bytes
mod10 = $0202

message = $0204 ;max 6; zero byte is the length.  
; example string 5|65535
;                L 12345

number = $020A ;keep this in ram so we can decrement it
put_char_local = $020C

E  = %01000000
RS = %00100000
RW = %00010000

CHR_PER_DISP   = 16
LINE_PER_DISP  = 2

    .org $8000
                    ; cycles
delay:
    pha ;save a     ; 3
    txa             ; 2
    pha ;save x     ; 3
    ldx #$ff        ; 2
delay_loop:
    dex             ; 2
    nop             ; 2 x 10 
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    bne delay_loop ; 2  Total 256 x 2 x 10 = 5120
    pla            ; 4
    tax            ; 2
    pla            ; 4
    rts            ; 6  Total 5120 + 16 + 10 = 5146

; we are running at 1mhz so 48 delays is approx 0.25 seconds
delay_quarter_sec:
    pha ;save a
    txa
    pha ;save x
    ldx #48
dqs_loop:
    jsr delay
    dex
    bne dqs_loop
    pla
    tax ;restore x
    pla ;restore a
    rts

lcd_wait:
    pha
    ;      Pins
    ;-------------
    ;      ERRDDDD
    ;       SW7654
    lda #%01110000 ; we want E, RS and RW to be output and D as input
    sta DDRB 
lcdbusy:
    lda #RW        ; read the busy flag
    sta PORTB
    lda #(RW | E)
    sta PORTB
    lda PORTB
    and #%1000    ; just get the busy flag from D7
    bne lcdbusy   ; loop when the bit is set

    lda #RW        ; read the busy flag
    sta PORTB
    lda #%01111111  ; set port b as output. Only 7 pins rs rw e db7 db6 db5 db4
    sta DDRB 
    pla
    rts
 
send_lcd_cmd:
    ora #E
    sta PORTB
    lda #0
    sta PORTB
    rts

put_lcd_char:
    jsr lcd_wait
    sta put_char_local
    lsr
    lsr
    lsr
    lsr
    ora #RS
    ora #E
    sta PORTB
    lda #0
    sta PORTB

    lda put_char_local
    and #%1111
    ora #RS
    ora #E
    sta PORTB
    lda #0
    sta PORTB

    lda put_char_local
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
    cli ; enable interrupts

    lda #%01111111 ;set 7 pins on port B to output rs rw e db7 db6 db5
    sta DDRB

    ;set to 4-bit operation
    lda #%00000010   
    jsr send_lcd_cmd
    jsr lcd_wait

    ;set 4 bit mode, 1-line display, 5x8 font
    lda #%00000010   
    jsr send_lcd_cmd
    lda #%00000000
    jsr send_lcd_cmd
    jsr lcd_wait

    ;Display on, cursor on, blink off
    lda #%00000000 
    jsr send_lcd_cmd
    lda #%00001110
    jsr send_lcd_cmd
    jsr lcd_wait

    ;increment and shift the cursor, do not shift display
    lda #%00000000
    jsr send_lcd_cmd
    lda #%00000110 
    jsr send_lcd_cmd
    jsr lcd_wait

    ;store 1729 in memory
    lda #$C1
    sta number
    lda #$06
    sta number + 1

 
main_loop:
    ; return home
    lda #%00000000
    jsr send_lcd_cmd
    lda #%00000010 
    jsr send_lcd_cmd
    jsr lcd_wait

    ; Clear the display
    lda #%00000000
    jsr send_lcd_cmd
    lda #%00000001 
    jsr send_lcd_cmd
    jsr lcd_wait

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
    jsr delay_quarter_sec

    ;decrease number by one
    sec
    lda number ; load the low byte
    sbc #1
    sta number
    lda number + 1 ; load the high byte
    sbc #0         
    sta number + 1

    jmp main_loop

exit:
    jmp exit

nmi:
irq:
    ; increment the number
    pha
    lda number
    clc
    adc #1
    sta number
    lda number + 1
    adc #0
    sta number + 1
    pla
 
    rti

    .org $fffa
    .word nmi
    .word main
    .word irq


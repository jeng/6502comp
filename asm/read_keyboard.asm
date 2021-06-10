; Read in ascii keyboard codes from the arduino.  Eventually this will come straight from the atmega328p.
;
; This works with Ben Eater's breadboard 6502. The LCD needs to be in 4-bit mode
; to free up 8 pins on the 6522.  An arduino sketch reads the PS/2 scan codes,
; converts them to ascii, sends them to PORTA, and triggers and interrupt.  
; 
; This program gets the ascii codes from PORTA and sends them to the LCD.
;
; Jeremy English 2021 jhe@jeremyenglish.org

PORTB = $6000
PORTA = $6001
DDRB  = $6002 ; Data direction
DDRA  = $6003
PCR   = $600C
IFR   = $600D
IER   = $600E

REGA_TMP = $020C

E  = %01000000
RS = %00100000
RW = %00010000

CHR_PER_DISP   = 16
LINE_PER_DISP  = 2

ESCAPE = $1B
RETURN = $0a ; '\n'

    .org $8000

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
    pha
    ora #E
    sta PORTB
    lda #0
    sta PORTB
    pla
    rts

send_lcd_cmd_8bit:
    jsr lcd_wait
    sta REGA_TMP
    ; get the high nibble
    lsr
    lsr
    lsr
    lsr
    jsr send_lcd_cmd

    ; get the low nibble
    lda REGA_TMP
    and #%1111
    jsr send_lcd_cmd

    ; restore a
    lda REGA_TMP
    rts

put_lcd_char:
    jsr lcd_wait
    sta REGA_TMP
    ; get the high nibble
    lsr
    lsr
    lsr
    lsr
    ; enable writing data
    ora #RS  
    jsr send_lcd_cmd

    ; get the low nibble
    lda REGA_TMP
    and #%1111
    ; enable writing data
    ora #RS
    jsr send_lcd_cmd

    ; restore a
    lda REGA_TMP
    rts

main:
    cli ; enable interrupts

    lda #%01111111 ;set 7 pins on port B to output e rs rw db7 db6 db5 db4
    sta DDRB
    
    lda #%00000000 ;set all pins on port A as input
    sta DDRA       ;keyboard input will come to this port

    ;set the interrupt flag on the 6522
    lda #$82; set the interrupt enable for CA1
    sta IER
    lda #$0
    sta PCR; when it transitions to a low state

    ;set to 4-bit operation
    lda #%00000010   
    jsr send_lcd_cmd
    jsr lcd_wait

    ;TODO make send_lcd_cmd take 8 bits, create the nibbles and send out both

    ;set 4 bit mode, 1-line display, 5x8 font
    ;lda #%00110000
    ;jsr send_lcd_cmd_8bit
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

main_loop:
    ; just loop, the interrupt will do all of the work
    jmp main_loop

nmi:
irq:
    pha
    
    ; REMOVE
    ; return home
    ; lda #%00000000
    ; jsr send_lcd_cmd
    ; lda #%00000010 
    ; jsr send_lcd_cmd
    ; jsr lcd_wait

    ; ; Clear the display
    ; lda #%00000000
    ; jsr send_lcd_cmd
    ; lda #%00000001 
    ; jsr send_lcd_cmd
    ; jsr lcd_wait
    ; END REMOVE

    ; get the character from PORTA
    lda PORTA; This will also clear the interrupt

    cmp #ESCAPE  ; if they pressed the esc key clear the display
    beq clear_display
    
    cmp #RETURN  ; if return was pressed go to line 2
    beq next_line

    ; send it to the display
    jsr put_lcd_char
    jmp exit_irq

clear_display:
    ; Clear the display
    lda #%00000000
    jsr send_lcd_cmd
    lda #%00000001 
    jsr send_lcd_cmd
    jsr lcd_wait
    jmp exit_irq

next_line:
    ;
    ; Move to the second line
    ;
    lda #%11000000 ; set DDRAM address to the start of the second line
    jsr send_lcd_cmd_8bit
    sta PORTB


exit_irq:
    pla
    rti

    .org $fffa
    .word nmi
    .word main
    .word irq


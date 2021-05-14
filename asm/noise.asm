; noise
;
; Show some random numbers on the LEDs.  
; This program can run with the setup at the end of the second video of Ben
; Eater's breadboard 6502. (65c22 hooked up to 8 leds)

*=$8000
lda #$ff ;setup  the port
sta $6002
loop:
ldy #50 ;load the table length
loadtable:
lda noise, y ;get a random byte from the table
sta $6000 ;display the byte
dey
bne loadtable ;loop until we are out of table entries
jmp loop

noise:
dcb $fa, $1a, $cf, $09, $65, $5e, $fe, $22, $20, $d0, $30 
dcb $17, $2c, $27, $d2, $b4, $82, $be, $3c, $00, $c6, $89
dcb $a8, $18, $50, $6e, $65, $10, $e6, $b0, $54, $ac, $1f
dcb $f0, $ca, $9c, $de, $b6, $7c, $b4, $b3, $8b, $45, $f6
dcb $a0, $a9, $29, $c4, $49, $b6

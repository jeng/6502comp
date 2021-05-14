; Cylons

; This program can run with the setup at the end of the second video of Ben
; Eater's breadboard 6502. (65c22 hooked up to 8 leds)

*= $8000
lda #$ff
sta $6002

lda #$01
loop:

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

jmp loop


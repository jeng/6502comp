; mvleft 

; This program can run with the setup at the end of the second video of Ben
; Eater's breadboard 6502. (65c22 hooked up to 8 leds)

*= $8000
lda #$ff
sta $6002

lda #$01
loop:
sta $6000
rol
jmp loop


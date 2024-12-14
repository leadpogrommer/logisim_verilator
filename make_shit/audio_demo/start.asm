asect 0x00
main:ext
dc _start, 0
dc 0, 0
dc 0, 0
dc 0, 0
dc 0, 0
align 0x80



_start:
    ldi r0, 0xb000
    stsp r0
    ldi r0, 0

    jsr main
    halt

some_counter> ds 2

asect 0xBFF2
DSP_RUNNING> ds 2
asect 0xBFF4
FREE_HALF> ds 2
asect 0xBFF6
BUTTONS> ds 2
asect 0xBFF8
LEDS> ds 8
asect 0xC000
AUDIO_FIRST> ds 0x2000
asect 0xE000
AUDIO_SECOND> ds 0x2000

end.
asect 0x00
main:ext
dc _start, 0
align 0x80

_start:
    # ldi r0, 0xff00
    # ldi r1, 0xffff
    # st r0, r1

    # ldi r0, 0xff02
    # ldi r1, str

    # loop:
    # ldb r1, r2
    # st r0, r2
    # inc r1
    # tst r2
    # bnz loop

    # halt
    ldi r0, 0xff00
    stsp r0
    ldi r0, 0

    jsr main
    halt



asect 0xff00
VRAM_ADDR> ds 2
VRAM_DATA> ds 2

end.
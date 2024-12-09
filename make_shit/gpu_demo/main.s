### SECTION: .text
rsect _main_c_1804289383

VRAM_DATA: ext
VRAM_ADDR: ext


macro movens/2
push $1
pop $2
mend

putc>                                   # -- Begin function putc
# %bb.0:                                # %entry
	push	fp
	ldsp	fp
	addsp	-2
	ssw	r4, -2                          # 2-byte Folded Spill
	ldi	r1, VRAM_DATA
	stw	r1, r0
	ldi	r0, ccol
	ldw	r0, r1
	movens	r1, r2
	add	r2, 1
	stw	r0, r2
	ldi	r2, 79
	cmp	r1, r2
	blt	__LBB0_4
	br	__LBB0_1
__LBB0_1:                               # %if.then
	ldi	r1, cline
	ldw	r1, r3
	ldi	r2, 0
	ldi	r4, 28
	cmp	r3, r4
	movens	r2, r4
	bgt	__LBB0_3
# %bb.2:                                # %if.then
	add	r3, 1
	movens	r3, r4
__LBB0_3:                               # %if.then
	stw	r0, r2
	stw	r1, r4
__LBB0_4:                               # %if.end5
	lsw	r4, -2                          # 2-byte Folded Reload
	addsp	2
	pop	fp
	rts
                                        # -- End function
puts>                                   # -- Begin function puts
# %bb.0:                                # %entry
	push	fp
	ldsp	fp
	addsp	-8
	ssw	r4, -2                          # 2-byte Folded Spill
	ssw	r5, -4                          # 2-byte Folded Spill
	ssw	r6, -6                          # 2-byte Folded Spill
	ldi	r6, cline
	ldi	r5, 32
__LBB1_1:                               # %while.cond
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_4 Depth 2
	ldb	r0, r1
	ldi	r2, 10
	cmp	r1, r2
	ssw	r0, -8                          # 2-byte Folded Spill
	beq	__LBB1_3
	br	__LBB1_2
__LBB1_2:                               # %while.cond
                                        #   in Loop: Header=BB1_1 Depth=1
	ldi	r2, 0
	cmp	r1, r2
	beq	__LBB1_7
	br	__LBB1_5
__LBB1_5:                               # %if.else
                                        #   in Loop: Header=BB1_1 Depth=1
	sxt	r1, r0
	jsr	putc
__LBB1_6:                               # %if.end
                                        #   in Loop: Header=BB1_1 Depth=1
	lsw	r0, -8                          # 2-byte Folded Reload
	add	r0, 1
	br	__LBB1_1
__LBB1_3:                               # %if.then
                                        #   in Loop: Header=BB1_1 Depth=1
	ldw	r6, r4
__LBB1_4:                               # %while.body8
                                        #   Parent Loop BB1_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movens	r5, r0
	jsr	putc
	ldw	r6, r0
	cmp	r0, r4
	beq	__LBB1_4
	br	__LBB1_6
__LBB1_7:                               # %while.end9
	lsw	r6, -6                          # 2-byte Folded Reload
	lsw	r5, -4                          # 2-byte Folded Reload
	lsw	r4, -2                          # 2-byte Folded Reload
	addsp	8
	pop	fp
	rts
                                        # -- End function
n_to_hex>                               # -- Begin function n_to_hex
# %bb.0:                                # %entry
	ldi	r1, 55
	ldi	r2, 9
	cmp	r0, r2
	bgt	__LBB2_2
# %bb.1:                                # %entry
	ldi	r1, 48
__LBB2_2:                               # %entry
	add r1, r0, r0
	sxt	r0, r0
	rts
                                        # -- End function
print_hext>                             # -- Begin function print_hext
# %bb.0:                                # %entry
	push	fp
	ldsp	fp
	addsp	-2
	ssw	r4, -2                          # 2-byte Folded Spill
	movens	r0, r4
	ldi	r0, 240
	and r4, r0, r0
	shr	r0, r0, 4
	jsr	n_to_hex
	jsr	putc
	ldi	r0, 15
	and r4, r0, r0
	jsr	n_to_hex
	jsr	putc
	lsw	r4, -2                          # 2-byte Folded Reload
	addsp	2
	pop	fp
	rts
                                        # -- End function
main>                                   # -- Begin function main
# %bb.0:                                # %entry
	push	fp
	ldsp	fp
	addsp	-6
	ssw	r4, -2                          # 2-byte Folded Spill
	ssw	r5, -4                          # 2-byte Folded Spill
	ssw	r6, -6                          # 2-byte Folded Spill
	ldi	r0, VRAM_ADDR
	ldi	r1, -1
	stw	r0, r1
	ldi	r2, 2400
	ldi	r3, VRAM_DATA
	ldi	r5, 0
	br	__LBB4_2
__LBB4_2:                               # %for.body
                                        # =>This Inner Loop Header: Depth=1
	stw	r3, r5
	sub	r2, 1
	cmp	r2, r5
	beq	__LBB4_1
	br	__LBB4_2
__LBB4_1:                               # %for.cond.cleanup
	stw	r0, r1
	ldi	r0, __L.str
	jsr	puts
	movens	r5, r4
	movens	r5, r6
	br	__LBB4_4
__LBB4_9:                               # %if.then10
                                        #   in Loop: Header=BB4_4 Depth=1
	sxt	r4, r0
	jsr	print_hext
__LBB4_10:                              # %if.end11
                                        #   in Loop: Header=BB4_4 Depth=1
	ldi	r0, __L.str.3
	jsr	puts
	add	r6, 1
	add	r5, 1
	add	r4, 1
	ldi	r0, 29
	cmp	r4, r0
	beq	__LBB4_3
	br	__LBB4_4
__LBB4_4:                               # %for.body5
                                        # =>This Inner Loop Header: Depth=1
	ldi	r0, 3
	cmp	r5, r0
	ldi	r0, 0
	bne	__LBB4_6
	br	__LBB4_5
__LBB4_5:                               # %if.then
                                        #   in Loop: Header=BB4_4 Depth=1
	ldi	r0, __L.str.1
	jsr	puts
	ldi	r5, 0
	ldi	r0, 1
__LBB4_6:                               # %if.end
                                        #   in Loop: Header=BB4_4 Depth=1
	ldi	r1, 5
	cmp	r6, r1
	bne	__LBB4_8
	br	__LBB4_7
__LBB4_7:                               # %if.then8
                                        #   in Loop: Header=BB4_4 Depth=1
	ldi	r0, __L.str.2
	jsr	puts
	ldi	r6, 0
	ldi	r0, 1
__LBB4_8:                               # %if.end9
                                        #   in Loop: Header=BB4_4 Depth=1
	ldi	r1, 0
	cmp	r0, r1
	bne	__LBB4_10
	br	__LBB4_9
__LBB4_3:                               # %for.cond.cleanup4
	ldi	r0, 0
	lsw	r6, -6                          # 2-byte Folded Reload
	lsw	r5, -4                          # 2-byte Folded Reload
	lsw	r4, -2                          # 2-byte Folded Reload
	addsp	6
	pop	fp
	rts
                                        # -- End function
### SECTION: .bss
ccol:                                   # @ccol
	dc	0                               # 0x0

cline:                                  # @cline
	dc	0                               # 0x0

### SECTION: .rodata.str1.1
__L.str:                                # @.str
	db	67
	db	100
	db	77
	db	49
	db	54
	db	32
	db	70
	db	105
	db	122
	db	122
	db	66
	db	117
	db	122
	db	122
	db	32
	db	118
	db	48
	db	46
	db	48
	db	46
	db	49
	db	10
	db	0

__L.str.1:                              # @.str.1
	db	70
	db	105
	db	122
	db	122
	db	0

__L.str.2:                              # @.str.2
	db	66
	db	117
	db	122
	db	122
	db	0

__L.str.3:                              # @.str.3
	db	10
	db	0

end.

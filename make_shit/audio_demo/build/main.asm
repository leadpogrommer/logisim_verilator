### SECTION: .text
rsect _main_c_1804289383

DSP_RUNNING: ext
BUTTONS: ext
FREE_HALF: ext
AUDIO_FIRST: ext
AUDIO_SECOND: ext
LEDS: ext


macro movens/2
push $1
pop $2
mend

dsp_pass>                               # -- Begin function dsp_pass
# %bb.0:                                # %entry
	rts
                                        # -- End function
dsp_triangle>                           # -- Begin function dsp_triangle
# %bb.0:                                # %entry
	push	fp
	ldsp	fp
	addsp	-6
	ssw	r4, -2                          # 2-byte Folded Spill
	ssw	r5, -4                          # 2-byte Folded Spill
	ssw	r6, -6                          # 2-byte Folded Spill
	ldi	r1, 0
	ldi	r2, 255
	ldi	r3, 28672
	ldi	r4, 8192
	movens	r1, r5
	br	__LBB1_2
__LBB1_2:                               # %for.body
                                        # =>This Inner Loop Header: Depth=1
	and r5, r2, r6
	shl	r6, r6, 6
	add r6, r3, r6
	stw	r0, r1, r6
	add	r5, 1
	add	r1, 2
	cmp	r1, r4
	beq	__LBB1_1
	br	__LBB1_2
__LBB1_1:                               # %for.cond.cleanup
	lsw	r6, -6                          # 2-byte Folded Reload
	lsw	r5, -4                          # 2-byte Folded Reload
	lsw	r4, -2                          # 2-byte Folded Reload
	addsp	6
	pop	fp
	rts
                                        # -- End function
dsp_lo>                                 # -- Begin function dsp_lo
# %bb.0:                                # %entry
	push	fp
	ldsp	fp
	addsp	-6
	ssw	r4, -2                          # 2-byte Folded Spill
	ssw	r5, -4                          # 2-byte Folded Spill
	ssw	r6, -6                          # 2-byte Folded Spill
	ldi	r2, 0
	ldi	r1, prev_val
	ldw	r1, r3
	ldi	r4, -16384
	ldi	r5, -32768
	ldi	r6, 8192
	br	__LBB2_2
__LBB2_2:                               # %for.body
                                        # =>This Inner Loop Header: Depth=1
	ldw	r0, r2, r1
	shr	r1, r1, 1
	sub r1, r3, r1
	add r1, r4, r1
	shra	r1, r1, 5
	add r1, r3, r3
	shl	r3, r1, 1
	xor r1, r5, r1
	stw	r0, r2, r1
	add	r2, 2
	cmp	r2, r6
	beq	__LBB2_1
	br	__LBB2_2
__LBB2_1:                               # %for.cond.cleanup
	ldi	r0, prev_val
	stw	r0, r3
	lsw	r6, -6                          # 2-byte Folded Reload
	lsw	r5, -4                          # 2-byte Folded Reload
	lsw	r4, -2                          # 2-byte Folded Reload
	addsp	6
	pop	fp
	rts
                                        # -- End function
run_dsp>                                # -- Begin function run_dsp
# %bb.0:                                # %entry
	push	fp
	ldsp	fp
	addsp	-2
	ssw	r4, -2                          # 2-byte Folded Spill
	ldi	r4, DSP_RUNNING
	ldi	r1, 1
	stw	r4, r1
	ldi	r2, current_dsp
	ldw	r2, r2
	ldi	r3, 2
	cmp	r2, r3
	beq	__LBB3_3
	br	__LBB3_1
__LBB3_1:                               # %entry
	cmp	r2, r1
	bne	__LBB3_4
	br	__LBB3_2
__LBB3_2:                               # %sw.bb1
	jsr	dsp_triangle
	br	__LBB3_4
__LBB3_3:                               # %sw.bb2
	jsr	dsp_lo
__LBB3_4:                               # %sw.epilog
	ldi	r0, 0
	stw	r4, r0
	lsw	r4, -2                          # 2-byte Folded Reload
	addsp	2
	pop	fp
	rts
                                        # -- End function
check_buttons>                          # -- Begin function check_buttons
# %bb.0:                                # %entry
	push	fp
	ldsp	fp
	addsp	-12
	ssw	r4, -2                          # 2-byte Folded Spill
	ssw	r5, -4                          # 2-byte Folded Spill
	ssw	r6, -6                          # 2-byte Folded Spill
	ldi	r1, 0
	ldi	r0, dsp_names
	ssw	r0, -8                          # 2-byte Folded Spill
	ldi	r0, BUTTONS
	ldw	r0, r0
	ldi	r4, 3
	ldi	r6, LEDS
	ldi	r5, 4
	ssw	r1, -10                         # 2-byte Folded Spill
	br	__LBB4_2
__LBB4_5:                               # %if.end
                                        #   in Loop: Header=BB4_2 Depth=1
	lsw	r0, -8                          # 2-byte Folded Reload
	add	r0, 6
	ssw	r0, -8                          # 2-byte Folded Spill
	lsw	r0, -12                         # 2-byte Folded Reload
	shra	r0, r0, 1
	lsw	r1, -10                         # 2-byte Folded Reload
	add	r1, 1
	ssw	r1, -10                         # 2-byte Folded Spill
	cmp	r1, r4
	beq	__LBB4_1
	br	__LBB4_2
__LBB4_2:                               # %for.body
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_4 Depth 2
	ssw	r0, -12                         # 2-byte Folded Spill
	ldi	r1, 1
	and r0, r1, r1
	ldi	r0, 0
	cmp	r1, r0
	beq	__LBB4_5
	br	__LBB4_3
__LBB4_3:                               # %if.then
                                        #   in Loop: Header=BB4_2 Depth=1
	ldi	r0, current_dsp
	lsw	r1, -10                         # 2-byte Folded Reload
	stw	r0, r1
	lsw	r1, -8                          # 2-byte Folded Reload
	ldi	r3, 0
__LBB4_4:                               # %for.body.i
                                        #   Parent Loop BB4_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	xor r3, r4, r2
	shl	r2, r2, 1
	ldw	r1, r0
	stw	r2, r6, r0
	add	r1, 2
	add	r3, 1
	cmp	r3, r5
	bne	__LBB4_4
	br	__LBB4_5
__LBB4_1:                               # %for.cond.cleanup
	lsw	r6, -6                          # 2-byte Folded Reload
	lsw	r5, -4                          # 2-byte Folded Reload
	lsw	r4, -2                          # 2-byte Folded Reload
	addsp	12
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
	ldi	r0, 0
	ldi	r1, dsp_names
	ldi	r2, 3
	ldi	r3, LEDS
	ldi	r4, 4
__LBB5_1:                               # %for.body.i
                                        # =>This Inner Loop Header: Depth=1
	xor r0, r2, r5
	shl	r5, r5, 1
	ldw	r1, r6
	stw	r5, r3, r6
	add	r1, 2
	add	r0, 1
	cmp	r0, r4
	bne	__LBB5_1
	br	__LBB5_2
__LBB5_2:                               # %while.cond.preheader
	ldi	r6, FREE_HALF
	ldi	r4, 0
__LBB5_3:                               # %while.cond
                                        # =>This Inner Loop Header: Depth=1
	ldw	r6, r0
	cmp	r0, r4
	beq	__LBB5_3
	br	__LBB5_4
__LBB5_4:                               # %while.cond1
	ldw	r6, r0
	ldi	r5, 1
	cmp	r0, r5
	bne	__LBB5_10
	br	__LBB5_5
__LBB5_5:                               # %while.body5
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB5_6 Depth 2
                                        #     Child Loop BB5_8 Depth 2
	jsr	check_buttons
__LBB5_6:                               # %while.cond6
                                        #   Parent Loop BB5_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	ldw	r6, r0
	cmp	r0, r4
	beq	__LBB5_6
	br	__LBB5_7
__LBB5_7:                               # %while.end9
                                        #   in Loop: Header=BB5_5 Depth=1
	ldi	r0, AUDIO_FIRST
	jsr	run_dsp
	jsr	check_buttons
__LBB5_8:                               # %while.cond10
                                        #   Parent Loop BB5_5 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	ldw	r6, r0
	cmp	r0, r5
	beq	__LBB5_8
	br	__LBB5_9
__LBB5_9:                               # %while.end13
                                        #   in Loop: Header=BB5_5 Depth=1
	ldi	r0, AUDIO_SECOND
	jsr	run_dsp
	br	__LBB5_5
__LBB5_10:                              # %while.end14
	lsw	r6, -6                          # 2-byte Folded Reload
	lsw	r5, -4                          # 2-byte Folded Reload
	lsw	r4, -2                          # 2-byte Folded Reload
	addsp	6
	pop	fp
	rts
                                        # -- End function
### SECTION: .data
font>                                   # @font
	dc	252                             # 0xfc
	dc	96                              # 0x60
	dc	218                             # 0xda
	dc	242                             # 0xf2
	dc	102                             # 0x66
	dc	182                             # 0xb6
	dc	190                             # 0xbe
	dc	224                             # 0xe0
	dc	254                             # 0xfe
	dc	230                             # 0xe6
	dc	238                             # 0xee
	dc	62                              # 0x3e
	dc	156                             # 0x9c
	dc	122                             # 0x7a
	dc	158                             # 0x9e
	dc	142                             # 0x8e

### SECTION: .bss
current_dsp>                            # @current_dsp
	dc	0                               # 0x0

### SECTION: .data
dsp_names>                              # @dsp_names
	dc	206                             # 0xce
	dc	238                             # 0xee
	dc	182                             # 0xb6
	dc	30                              # 0x1e
	dc	10                              # 0xa
	dc	96                              # 0x60
	dc	28                              # 0x1c
	dc	252                             # 0xfc
	dc	0                               # 0x0

### SECTION: .bss
prev_val:                               # @prev_val
	dc	0                               # 0x0

end.

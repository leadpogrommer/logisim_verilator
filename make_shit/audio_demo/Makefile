CC=/home/ilya/work/cdm_clang/llvm-project/llvm/cmake-build-debug-clang/bin/clang
C_OPTS=-target cdm -S -O1

ASM=cocas
ASM_OPTS=-t cdm16 --debug


build/%.asm: %.c $(CC)
	$(CC) $(C_OPTS) -o $@ $+

build/audio.img: build/main.asm start.asm
	$(ASM) $(ASM_OPTS) -o $@ $+

run: build/audio.img
	EBAZ_ADDR=127.0.0.1:8000 python ../run_img.py build/audio.img

.SECONDARY:
.PHONY: run
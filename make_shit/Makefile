verilog/gen_ucode_normal.sv: gen_ucode.py ucode/cdm16_decoder.def
	python gen_ucode.py ucode/cdm16_decoder.def $@ 0

verilog/gen_ucode_exc.sv: gen_ucode.py ucode/cdm16_decoder_exc.def
	python gen_ucode.py ucode/cdm16_decoder_exc.def $@ 0x8000400

build/verilog_top_%: $(shell find verilog -type f) verilog/gen_ucode_normal.sv verilog/gen_ucode_exc.sv
	verilator -Iverilog/include -CFLAGS "-fPIC" --cc --trace --build --top-module $* -Mdir $@ $^

build/%.cpp: build/verilog_top_% gen_wrapper.py
	python gen_wrapper.py $</V$*.h verilog/$*.sv $@

build/%.so: build/%.cpp model_api.h
	gcc -shared -fPIC  -I/usr/share/verilator/include -Ibuild/verilog_top_$* -I.  -lstdc++ -latomic $< build/verilog_top_$*/libV$*.a build/verilog_top_$*/libverilated.a -o $@

all: build/ALU.so build/branch_logic.so build/bus_control.so build/cdm16.so build/decoder.so build/registers.so

.SECONDARY:
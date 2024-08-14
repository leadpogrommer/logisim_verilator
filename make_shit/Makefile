

build/verilog_top_%: $(shell find verilog -type f)
	verilator -Iverilog/include -CFLAGS "-fPIC" --cc --trace --build --top-module $* -Mdir $@ $+

build/%.cpp: build/verilog_top_% gen_wrapper.py
	python gen_wrapper.py $</V$*.h verilog/$*.sv $@

build/%.so: build/%.cpp model_api.h
	gcc -shared -fPIC  -I/usr/share/verilator/include -Ibuild/verilog_top_$* -I.  -lstdc++ -latomic $< build/verilog_top_$*/libV$*.a build/verilog_top_$*/libverilated.a -o $@

all: build/ALU.so build/branch_logic.so build/bus_control.so build/cdm16.so build/decoder.so build/registers.so

.SECONDARY:
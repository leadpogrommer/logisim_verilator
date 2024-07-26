

build/verilog_top_%: $(shell find verilog -type f)
	verilator -Iverilog/include -CFLAGS "-fPIC" --cc --build --top-module $* -Mdir $@ $+

build/%.cpp: build/verilog_top_% gen_wrapper.py
	python gen_wrapper.py $</V$*.h verilog/$*.v $@

build/%.so: build/%.cpp model_api.h
	gcc -shared -I/usr/share/verilator/include -Ibuild/verilog_top_$* -I.  -lstdc++ -latomic $< build/verilog_top_$*/libV$*.a build/verilog_top_$*/libverilated.a -o $@

all: build/decoder.so

.SECONDARY:
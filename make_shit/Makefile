

build/verilog_top_%: $(shell find verilog -type f)
	verilator -CFLAGS "-fPIC" --cc --build --top-module $* -Mdir $@ $+

build/%.cpp: build/verilog_top_% gen_wrapper.py
	python gen_wrapper.py $</V$*.h $@

build/%.so: build/%.cpp model_api.h
	gcc -shared -I/usr/share/verilator/include -Ibuild/verilog_top_$* -I.  -lstdc++ -latomic $< build/verilog_top_$*/libV$*.a build/verilog_top_$*/libverilated.a -o $@

all_libs: build/adder16.so build/test.so

.SECONDARY:
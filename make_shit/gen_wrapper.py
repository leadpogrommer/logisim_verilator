import sys
import re
from dataclasses import dataclass

in_header = sys.argv[1]
out_code = sys.argv[2]

type_suffixes = {
    "8": 8,
    "16": 16,
    "": 32,
    # "64": 64 // 64 bits are not supported by logisim
}

port_re = r'VL_(IN|OUT)(\d*)\(&(\w+),(\d+),(\d+)\);'


@dataclass
class Port:
    kind: str
    var_width: int
    name: str
    width: int
    # TODO: maybe msb and lsb are needed


in_ports: list[Port] = []
out_ports: list[Port] = []

class_prefix = 'class alignas(VL_CACHE_LINE_BYTES) '

class_name = None

for line in open(in_header, 'r'):
    if line.startswith(class_prefix):
        class_name = line.removeprefix(class_prefix).split(' ')[0]
        continue

    line = line.strip()
    if (match := re.match(port_re, line)) is None:
        continue
    kind, suffix, name, msb, lsb = match.groups()
    real_width = int(msb) - int(lsb) + 1
    if suffix not in type_suffixes:
        print(f'WARNING: port {name} has unknown type {suffix}')
        continue
    width = type_suffixes[suffix]
    if kind == 'IN':
        in_ports.append(Port(kind, width, name, real_width))
    elif kind == 'OUT':
        out_ports.append(Port(kind, width, name, real_width))
    else:
        print(f'WARNING: port {name} has unknown kind {kind}')

print(class_name)
print(in_ports, out_ports)


res_code = f'''
#include <verilated.h>
// #include "verilated_vpi.h"
#include "{in_header.split("/")[-1]}"

#include "model_api.h"

extern "C" {{

static VerilatedContext *contextp;

void init(){{
    contextp = new VerilatedContext;
}}

void deinit(){{
    delete contextp;
}}

void* create_state(){{
    return (void*)(new {class_name}{{contextp}});
}}
void destroy_state(void* state){{
    delete (({class_name} *) state);
}}


static char*  port_names[] = {{ {", ".join(map(lambda a: f'(char*)"{a.name}"',  in_ports+out_ports))} }};
static int port_widths[] = {{ {", ".join(map(lambda a: f'{a.width}', in_ports+out_ports))} }};

int get_input_port_count(){{
    return {len(in_ports)};
}}

int get_output_port_count(){{
    return {len(out_ports)};
}}

char** get_port_names(){{
    return port_names;
}}

int* get_port_widths(){{
    return port_widths; 
}}

void eval(void* state, const uint32_t *ins, uint32_t *outs){{
{
    "\n".join(map(lambda a: f"    (({class_name}*)state)->{a[1].name} = (uint{a[1].var_width}_t) (ins[{a[0]}]);", enumerate(in_ports)))
}
    (({class_name}*)state)->eval();
{
    "\n".join(map(lambda a: f"    (outs[{a[0]}]) = (({class_name}*)state)->{a[1].name};", enumerate(out_ports)))
}

    // for(int i = 0; i < {len(in_ports) + len(out_ports)}; i++){{
    //     printf("%s=%04X\\t", port_names[i], i < {len(in_ports)} ? ins[i] : outs[i - {len(in_ports)}]);
    // }}
    // printf("\\n");

}}

}}
'''

open(out_code, 'w').write(res_code)
import sys
import re
from dataclasses import dataclass
from typing import Literal

in_header = sys.argv[1]
in_verilog = sys.argv[2]
out_code = sys.argv[3]
print(f'{in_header=} {in_verilog=} {out_code=}')

type_suffixes = {
    "8": 8,
    "16": 16,
    "": 32,
    # "64": 64 // 64 bits are not supported by logisim
}

port_re = r'VL_(IN|OUT)(\d*)\({1,2}&(\w+)\)?(\[\d+\])?,(\d+),(\d+)\);'
verilog_port_re = r'(?:input|output)\s+(?:wire|reg)\s*(?:\[[^]]*]\s*)?([_a-zA-Z][_a-zA-Z0-9]*)(?:\s+/\*!(.*?)\*/)?'

# metadata format: tag1:value1,tag2:value2
# supported tags:
# p (placement): t (top), b (bottom), l (left), r (right)
# s (step): int value, step before next port
# t (text): text replacement (for top/bottom ports text drawn only if this is present)
# w: component width


port_placement_order = {}
port_metadata = {}
with open(in_verilog, 'r') as f:
    matches = re.findall(verilog_port_re, f.read())
    for i, match in enumerate(matches):
        pname, metadata = match
        port_placement_order[pname] = i
        port_metadata[pname] = metadata or ''



@dataclass
class Port:
    kind: Literal['IN'] | Literal['OUT']
    var_width: int
    name: str
    width: int
    shape: list[int]
    metadata: str
    place_order: int
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
    kind, suffix, name, shape, msb, lsb = match.groups() # TODO: 2+d arrays
    if shape is None:
        shape = []
    else:
        shape = [int(shape[1:-1])]
    real_width = int(msb) - int(lsb) + 1
    if suffix not in type_suffixes:
        print(f'WARNING: port {name} has unknown type {suffix}')
        continue
    width = type_suffixes[suffix]
    if kind == 'IN':
        in_ports.append(Port(kind, width, name, real_width, shape, port_metadata[name], port_placement_order[name]))
    elif kind == 'OUT':
        out_ports.append(Port(kind, width, name, real_width, shape, port_metadata[name], port_placement_order[name]))
    else:
        print(f'WARNING: port {name} has unknown kind {kind}')

print(class_name)
print('PORT LIST:')
print(*(in_ports + out_ports), sep='\n')

res_port_names = []
res_port_width = []
res_port_metadata = []
res_port_set_statements = []
res_port_get_statements = []
res_port_place_orders = []

place_order_offset = 0
in_po_offset = 0
out_po_offset = 0

for li, port in list(enumerate(in_ports)) + list(enumerate(out_ports)):
    arr_elems = [('', [])]
    for dim in port.shape:
        new_elems = []
        for elem in arr_elems:
            for i in range(dim):
                new_elems.append((elem[0]+f'[{i}]', elem[1]+[i]))
        arr_elems = new_elems

    for elem_num, elem in enumerate(arr_elems):
        if elem_num != 0:
            place_order_offset += 1
        suffix, dims = elem
        name = port.name + suffix
        res_port_names.append(name)
        res_port_width.append(port.width)
        res_port_metadata.append(port.metadata if elem_num == 0 else '')
        res_port_place_orders.append(port.place_order + place_order_offset)
        if port.kind == 'IN':
            if elem_num != 0:
                in_po_offset += 1
            res_port_set_statements.append(f"    (({class_name}*)state)->{name} = (uint{port.var_width}_t) (ins[{li + in_po_offset}]);")
        elif port.kind == 'OUT':
            if elem_num != 0:
                out_po_offset += 1
            res_port_get_statements.append(f"    (outs[{li + out_po_offset}]) = (({class_name}*)state)->{name};")
        else:
            print('Unknown port kind')
            exit(1)






res_code = f'''
#include <verilated.h>
// #include "verilated_vpi.h"
#include "{in_header.split("/")[-1]}"
#include <cstdio>

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


static char*  port_names[] = {{ {", ".join(map(lambda a: f'(char*)"{a}"',  res_port_names))} }};
static int port_widths[] = {{ {", ".join(map(str, res_port_width))} }};
static char*  port_metadata[] = {{ {", ".join(map(lambda a: f'(char*)"{a}"',  res_port_metadata))} }};
static int port_placement[] = {{ {", ".join(map(str, res_port_place_orders))} }};


int get_input_port_count(){{
    return {len(res_port_set_statements)};
}}

int get_output_port_count(){{
    return {len(res_port_get_statements)};
}}

char** get_port_names(){{
    return port_names;
}}

int* get_port_widths(){{
    return port_widths; 
}}

char** get_port_metadata(){{
    return port_metadata;
}}

int* get_port_placement(){{
    return port_placement; 
}}

void eval(void* state, const uint32_t *ins, uint32_t *outs){{
    if (!state){{
        printf("State is  zero!\\n");
        return;
    }}
{
    "\n".join(res_port_set_statements)
}
    (({class_name}*)state)->eval();
{
    "\n".join(res_port_get_statements)
}

    // for(int i = 0; i < {len(in_ports) + len(out_ports)}; i++){{
    //     printf("%s=%04X\\t", port_names[i], i < {len(in_ports)} ? ins[i] : outs[i - {len(in_ports)}]);
    // }}
    // printf("\\n");

}}

}}
'''

open(out_code, 'w').write(res_code)
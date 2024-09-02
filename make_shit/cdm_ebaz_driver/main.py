import time
from math import trunc

# IMPORTANT
# https://www.reddit.com/r/FPGA/comments/4chizo/confusion_with_axi_bram_controller/

import mmap
import os
from time import sleep
import random

RAM_ADDR =  0x4120_0000
CTRL_ADDR = 0x4121_0000

print('Mapping')
fd = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)
ram_map = mmap.mmap(fd, 2**16, offset=RAM_ADDR)
ctrl_map = mmap.mmap(fd, 4096, offset=CTRL_ADDR)
print('ok')

is_reset_active = 0

def set_reset(value: bool):
    print(f'Reset <- {value}')
    global is_reset_active
    is_reset_active = 1 if value else 0
    ctrl_map[0] = is_reset_active << 4

def get_regs():
    res = []
    for i in range(11):
        ctrl_map[0] = (is_reset_active << 4) | i
        res.append(int.from_bytes(ctrl_map[8:10], byteorder='little', signed=False))
    return res

def print_regs(vals: list[int] | None = None):
    if vals is None:
        vals = get_regs()
    reg_names = [f'r{i}' for i in range(8)] + ['SP', 'PC', 'PS']
    print('-'*10 + ' REG DUMP ' + '-'*10)
    for i in range(11):
        print(f'{reg_names[i]} : {vals[i]:04X}', end='')
        if i in (3, 7, 10):
            print()
        else:
            print('\t', end='')
    print(f'Status: {ctrl_map[10]:02b}')

for addr, val in enumerate([0x04, 0x00, 0x00, 0x00, 0x10, 0x20, 0xe4, 0x00, 0x11, 0x20, 0x39, 0x05, 0x04, 0x00, ]):
    ram_map[addr] = val

set_reset(True)
time.sleep(0.1)
print_regs()
set_reset(False)
time.sleep(1)
print_regs()
# time.sleep(0.1)
# ctrl_map[0] = 0b101001
# print(bin(ctrl_map[8]), bin(ctrl_map[9]), bin(ctrl_map[10])) # should halt
# exit(0)
# ram_map[0] = 228

# time.sleep(3)
#
# print('Writing')
# for i in range(512):
#     ram_map[i] = (i+1) % 256
# print('ok')
#
# time.sleep(3)
#
# print('Reading')
# for i in range(512):
#     print(i, ram_map[i])
# print('ok')

## begin memtest
# test_data = bytes([random.randint(0, 255) for _ in range(2**16)])
#
# # print(ram_map[9])
#
# print('Writing...')
# for i in range(2**16):
#     ram_map[i] = test_data[i]
# #     ram_map[i] = 0
# # ram_map[4] = 228
# print('ok')
#
# print('Verifying...')
# for i in range(2**16):
#     if (actual := ram_map[i]) != (expected := test_data[i]):
#         print(f'Incorrect data: addr={i:04x} actual={actual:02x} expected={expected:02x}')
# #         # exit(0)
# print('ok')
## end memtest

# for i in range(2**16):
#     ram_map[i] = i % 255
# ram_map[4] = 228

# for i in range(1536):
#     print(i, i%256, ram_map[i])
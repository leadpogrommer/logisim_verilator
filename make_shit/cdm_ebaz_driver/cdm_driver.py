import os

import mmap


RAM_ADDR =  0x4120_0000
CTRL_ADDR = 0x4121_0000

class CdmDriver:
    def __init__(self):
        self._fd = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)
        self._ram_map = mmap.mmap(self._fd, 2**16, offset=RAM_ADDR)
        self._ctrl_map = mmap.mmap(self._fd, 4096, offset=CTRL_ADDR)
        self._is_reset_active = 0

    def __del__(self):
        self._ctrl_map.close()
        self._ram_map.close()
        os.close(self._fd)

    def set_reset(self, value: bool):
        print(f'Reset <- {value}')
        self._is_reset_active = 1 if value else 0
        self._ctrl_map[0] = self._is_reset_active << 4

    def get_regs(self) -> list[int]:
        res = []
        for i in range(11):
            self._ctrl_map[0] = (self._is_reset_active << 4) | i
            res.append(int.from_bytes(self._ctrl_map[8:10], byteorder='little', signed=False))
        return res

    def get_status(self) -> int:
        return self._ctrl_map[10] & 0b11

    def print_regs(self, vals: list[int] | None = None):
        if vals is None:
            vals = self.get_regs()
        reg_names = [f'r{i}' for i in range(8)] + ['SP', 'PC', 'PS']
        print('-'*10 + ' REG DUMP ' + '-'*10)
        for i in range(11):
            print(f'{reg_names[i]} : {vals[i]:04X}', end='')
            if i in (3, 7, 10):
                print()
            else:
                print('\t', end='')
        print(f'Status: {self.get_status():02b}')

    def load_ram(self, image: list[int]):
        if len(image) >= 2**16:
            raise ValueError('Image too large')
        self._ram_map[:] = bytes([0]*(2**16))
        self._ram_map[:len(image)] = bytes(image)

    def get_ram(self) -> bytes:
        return self._ram_map[:]
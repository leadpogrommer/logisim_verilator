import os

import spidev

CMD_REG_READ = 1
CMD_RESET_SET = 2
CMD_MEM_WRITE = 3
CMD_MEM_READ = 4

REG_SP = 8
REG_PC = 9
REG_PS = 10
REG_STA = 11

class CdmDriver:
    def _xfer(self, cmd: int, addr: int, data: int) -> int:
        to_send = bytes([cmd]) + addr.to_bytes(2, byteorder='big') + data.to_bytes(length=2, byteorder='big')
        res = self._spi.xfer3(to_send)
        # print('Xfer res:', res)
        return int.from_bytes(res[-2:], byteorder='big', signed=False)

    def __init__(self):
        self._spi = spidev.SpiDev()
        self._spi.open(0, 0)
        self._spi.max_speed_hz = 1000_000
        self._spi.mode = 0b00
        self._spi.read0 = True
        self._is_reset_active = 0

    def __del__(self):
        self._spi.close()

    def set_reset(self, value: bool):
        print(f'Reset <- {value}')
        self._is_reset_active = 1 if value else 0
        self._xfer(CMD_RESET_SET, 0, self._is_reset_active)

    def write_mem(self, addr: int, data: int):
        self._xfer(CMD_MEM_WRITE, addr, data)

    def read_mem(self, addr: int):
        return self._xfer(CMD_MEM_READ, addr, 0)
        # return self._xfer(CMD_MEM_READ, addr, 0)

    def get_regs(self) -> list[int]:
        res = []
        for i in range(11):
            res.append(self._xfer(CMD_REG_READ, i, 0))
        return res

    def get_status(self) -> int:
        return self._xfer(CMD_REG_READ, REG_STA, 0) & 0b11

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
        if len(image) %2 != 0:
            image.append(0)
        for i in range(2**15):
            if i * 2 >= len(image):
                val = 0
            else:
                val = int.from_bytes(bytes(image[i*2:i*2+2]), byteorder='little', signed=False)
            self.write_mem(i*2, val)

    def get_ram(self) -> bytes:
        res = bytearray()
        for i in range(0, 2**16, 2):
            val = self.read_mem(i)
            res += val.to_bytes(2, byteorder='little', signed=False)
        return res
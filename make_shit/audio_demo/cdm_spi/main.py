from cdm_driver import CdmDriver

from time import sleep

d = CdmDriver()

# while True:
#     d._xfer(0b10000001, 0b1000000000000001, 0b1000000000000001)
#

some_data = [0x04, 0x00, 0x00, 0x00, 0x10, 0x20, 0xe4, 0x00, 0x11, 0x20, 0x39, 0x05, 0x04, 0x00]
d.set_reset(True)
# for i in range(len(some_data)):
#     d.write_mem(i*2, some_data[i])
#
# for i in range(len(some_data)):
#     print(hex(d.read_mem(i*2)))

d.load_ram(some_data)
print(d.get_ram()[:20])
# while True:
#     d.set_reset(True)
#     sleep(0.3)
#     d.set_reset(False)
#     sleep(0.3)
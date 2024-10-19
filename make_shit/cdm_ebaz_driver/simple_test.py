import time

# IMPORTANT
# https://www.reddit.com/r/FPGA/comments/4chizo/confusion_with_axi_bram_controller/

from cdm_driver import CdmDriver


cdm = CdmDriver()

cdm.set_reset(True)
cdm.load_ram([0x04, 0x00, 0x00, 0x00, 0x10, 0x20, 0xe4, 0x00, 0x11, 0x20, 0x39, 0x05, 0x04, 0x00])
cdm.print_regs()
cdm.set_reset(False)
time.sleep(0.1)
cdm.print_regs()


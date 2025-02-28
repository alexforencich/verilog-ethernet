# Dependencies
from pynq import Overlay
from pynq import allocate
from pynq.lib import AxiGPIO
from pynq import MMIO
import time
import numpy as np

# Overlay
overlay = Overlay("fpga.bit")

# Allocate memory shared with PL
shared_mem = allocate(shape=(256,), dtype='u8') # 256 x 64b = 2KB
print( "Base address of shared region: " + str(hex(shared_mem.device_address)) )

# Dump a message to shared memory
tx_message_str = "Hi from KR260 PS Ubuntu targeting workstation"
tx_message_unicode_arr = np.array([ord(c) for c in tx_message_str], dtype=np.uint64)
for array_index in range(len(tx_message_unicode_arr)):
    shared_mem[array_index] = tx_message_unicode_arr[array_index]

# Send base address to gpio in the PL (this will trigger a read transaction to the shared memory from the PL side)
mmio_gpio = MMIO(0xA0000000, 0x10000)
gpio_offset = 0 # Offset for 32b data for gpio channel 1
gpio_data = shared_mem.device_address
mmio_gpio.write(gpio_offset, gpio_data)

# Continuously print region where the incoming packet should be placed
while True:
    shared_mem.invalidate()
    print("\n")
    for i in range(256):
        hex_word = shared_mem[i]
        input_bytes = hex_word.tobytes()
        unicode_string = "".join([chr(b) for b in input_bytes])
        print(str(unicode_string), end="")
    time.sleep(1) 

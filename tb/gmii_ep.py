"""

Copyright (c) 2014 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

"""

from myhdl import *

def GMIISource(clk, rst,
               txd,
               tx_en,
               tx_er,
               fifo=None,
               name=None):

    @instance
    def logic():
        frame = []
        ifg_cnt = 0

        while True:
            yield clk.posedge, rst.posedge

            if rst:
                frame = []
                txd.next = 0
                tx_en.next = 0
                tx_er.next = 0
                ifg_cnt = 0
            else:
                if ifg_cnt > 0:
                    ifg_cnt -= 1
                    tx_en.next = 0
                elif len(frame) > 0:
                    txd.next = frame.pop(0)
                    tx_en.next = 1
                    if len(frame) == 0:
                        ifg_cnt = 12
                elif not fifo.empty():
                    frame = list(fifo.get())
                    if name is not None:
                        print("[%s] Sending frame %s" % (name, repr(frame)))
                    txd.next = frame.pop(0)
                    tx_en.next = 1
                else:
                    tx_en.next = 0

    return logic


def GMIISink(clk, rst,
             rxd,
             rx_dv,
             rx_er,
             fifo=None,
             name=None):

    @instance
    def logic():
        frame = None

        while True:
            yield clk.posedge, rst.posedge

            if rst:
                frame = None
            else:
                if rx_dv:
                    if frame is None:
                        frame = []
                    frame.append(int(rxd))
                elif frame is not None:
                    if len(frame) > 0:
                        frame = bytearray(frame)
                        if fifo is not None:
                            fifo.put(frame)
                        if name is not None:
                            print("[%s] Got frame %s" % (name, repr(frame)))
                    frame = None

    return logic

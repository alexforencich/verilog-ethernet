"""

Copyright (c) 2015-2019 Alex Forencich

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

class PtpClock(object):
    def __init__(self, period_ns=0x6, period_fns=0x6666, drift_ns=0x0, drift_fns=0x0002, drift_rate=5):
        self.period_ns = period_ns
        self.period_fns = period_fns
        self.drift_ns = drift_ns
        self.drift_fns = drift_fns
        self.drift_rate = drift_rate

        self.set_96_l = []
        self.set_64_l = []

    def set_96(self, ts):
        self.set_96_l.append(ts)

    def set_64(self, ts):
        self.set_64_l.append(ts)

    def create_logic(self,
            clk,
            rst,
            ts_96=Signal(intbv(0)[96:]),
            ts_64=Signal(intbv(0)[64:]),
            ts_step=Signal(bool(0))
        ):

        @instance
        def logic():

            ts_96_s = 0
            ts_96_ns = 0
            ts_96_fns = 0

            ts_64_ns = 0
            ts_64_fns = 0

            drift_cnt = 0

            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    ts_96_s = 0
                    ts_96_ns = 0
                    ts_96_fns = 0
                    ts_64_ns = 0
                    ts_64_fns = 0
                    drift_cnt = 0
                    ts_96.next = 0
                    ts_64.next = 0
                else:
                    ts_step.next = 0

                    t = ((ts_96_ns << 16) + ts_96_fns) + ((self.period_ns << 16) + self.period_fns)

                    if drift_cnt > 0:
                        t += (self.drift_ns << 16) + self.drift_fns
                        ts_step.next = 1

                    if t > (1000000000<<16):
                        ts_96_s += 1
                        t -= (1000000000<<16)

                    ts_96_fns = t & 0xffff
                    ts_96_ns = t >> 16

                    if self.set_96_l:
                        ts = self.set_96_l.pop(0)

                        ts_96_s = ts >> 48
                        ts_96_ns = (ts >> 16) & 0x3fffffff
                        ts_96_fns = ts & 0xffff

                        ts_step.next = 1

                    ts_96.next = (ts_96_s << 48) | (ts_96_ns << 16) | (ts_96_fns)

                    t = ((ts_64_ns << 16) + ts_64_fns) + ((self.period_ns << 16) + self.period_fns)

                    if drift_cnt > 0:
                        t += ((self.drift_ns << 16) + self.drift_fns)
                        ts_step.next = 1

                    ts_64_fns = t & 0xffff
                    ts_64_ns = t >> 16

                    if self.set_64_l:
                        ts = self.set_64_l.pop(0)

                        ts_64_ns = ts >> 16
                        ts_64_fns = ts & 0xffff

                        ts_step.next = 1

                    ts_64.next = (ts_64_ns << 16) | ts_64_fns

                    if drift_cnt > 0:
                        drift_cnt -= 1
                    else:
                        drift_cnt = self.drift_rate-1

        return instances()

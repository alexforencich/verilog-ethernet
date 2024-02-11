"""

Copyright (c) 2023 Alex Forencich

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

import logging
from decimal import Decimal, Context
from fractions import Fraction

import cocotb
from cocotb.triggers import RisingEdge, Event
from cocotb.utils import get_sim_time

from cocotbext.eth.reset import Reset


class PtpTdSource(Reset):
    def __init__(self,
            data=None,
            clock=None,
            reset=None,
            reset_active_level=True,
            period_ns=6.4,
            td_delay=32,
            *args, **kwargs):

        self.log = logging.getLogger(f"cocotb.{data._path}")
        self.data = data
        self.clock = clock
        self.reset = reset

        self.log.info("PTP time distribution source")
        self.log.info("Copyright (c) 2023 Alex Forencich")
        self.log.info("https://github.com/alexforencich/verilog-ethernet")

        super().__init__(*args, **kwargs)

        self.ctx = Context(prec=60)

        self.period_ns = 0
        self.period_fns = 0
        self.drift_num = 0
        self.drift_denom = 0
        self.drift_cnt = 0
        self.set_period_ns(period_ns)

        self.ts_fns = 0

        self.ts_rel_ns = 0
        self.ts_rel_updated = False

        self.ts_tod_s = 0
        self.ts_tod_ns = 0
        self.ts_tod_updated = False

        self.ts_tod_offset_ns = 0

        self.ts_tod_alt_s = 0
        self.ts_tod_alt_offset_ns = 0

        self.td_delay = td_delay

        self.timestamp_delay = [(0, 0, 0, 0)]

        self.data.setimmediatevalue(1)

        self.pps = Event()

        self._run_cr = None

        self._init_reset(reset, reset_active_level)

    def set_period(self, ns, fns):
        self.period_ns = int(ns)
        self.period_fns = int(fns) & 0xffffffff

    def set_drift(self, num, denom):
        self.drift_num = int(num)
        self.drift_denom = int(denom)

    def set_period_ns(self, t):
        t = Decimal(t)
        period, drift = self.ctx.divmod(Decimal(t) * Decimal(2**32), Decimal(1))
        period = int(period)
        frac = Fraction(drift).limit_denominator(2**16-1)
        self.set_period(period >> 32, period & 0xffffffff)
        self.set_drift(frac.numerator, frac.denominator)

        self.log.info("Set period: %s ns", t)
        self.log.info("Period: 0x%x ns 0x%08x fns", self.period_ns, self.period_fns)
        self.log.info("Drift: 0x%04x / 0x%04x fns", self.drift_num, self.drift_denom)

    def get_period_ns(self):
        p = Decimal((self.period_ns << 32) | self.period_fns)
        if self.drift_denom:
            p += Decimal(self.drift_num) / Decimal(self.drift_denom)
        return p / Decimal(2**32)

    def set_ts_tod(self, ts_s, ts_ns, ts_fns):
        self.ts_tod_s = int(ts_s)
        self.ts_tod_ns = int(ts_ns)
        self.ts_fns = int(ts_fns)
        self.ts_tod_updated = True

    def set_ts_tod_64(self, ts):
        ts = int(ts)
        self.set_ts_tod(ts >> 48, (ts >> 32) & 0x3fffffff, (ts & 0xffff) << 16)

    def set_ts_tod_ns(self, t):
        ts_s, ts_ns = self.ctx.divmod(Decimal(t), Decimal(1000000000))
        ts_ns, ts_fns = self.ctx.divmod(ts_ns, Decimal(1))
        ts_ns = ts_ns.to_integral_value()
        ts_fns = (ts_fns * Decimal(2**32)).to_integral_value()
        self.set_ts_tod(ts_s, ts_ns, ts_fns)

    def set_ts_tod_s(self, t):
        self.set_ts_tod_ns(Decimal(t).scaleb(9, self.ctx))

    def set_ts_tod_sim_time(self):
        self.set_ts_tod_ns(Decimal(get_sim_time('fs')).scaleb(-6))

    def get_ts_tod(self):
        ts_tod_s, ts_tod_ns, ts_rel_ns, ts_fns = self.timestamp_delay[0]
        return (ts_tod_s, ts_tod_ns, ts_fns)

    def get_ts_tod_96(self):
        ts_tod_s, ts_tod_ns, ts_fns = self.get_ts_tod()
        return (ts_tod_s << 48) | (ts_tod_ns << 16) | (ts_fns >> 16)

    def get_ts_tod_ns(self):
        ts_tod_s, ts_tod_ns, ts_fns = self.get_ts_tod()
        ns = Decimal(ts_fns) / Decimal(2**32)
        ns = self.ctx.add(ns, Decimal(ts_tod_ns))
        return self.ctx.add(ns, Decimal(ts_tod_s).scaleb(9))

    def get_ts_tod_s(self):
        return self.get_ts_tod_ns().scaleb(-9, self.ctx)

    def set_ts_rel(self, ts_ns, ts_fns):
        self.ts_rel_ns = int(ts_ns)
        self.ts_fns = int(ts_fns)
        self.ts_rel_updated = True

    def set_ts_rel_64(self, ts):
        ts = int(ts)
        self.set_ts_rel(ts >> 16, (ts & 0xffff) << 16)

    def set_ts_rel_ns(self, t):
        ts_ns, ts_fns = self.ctx.divmod(Decimal(t), Decimal(1))
        ts_ns = ts_ns.to_integral_value()
        ts_fns = (ts_fns * Decimal(2**32)).to_integral_value()
        self.set_ts_rel(ts_ns, ts_fns)

    def set_ts_rel_s(self, t):
        self.set_ts_rel_ns(Decimal(t).scaleb(9, self.ctx))

    def set_ts_rel_sim_time(self):
        self.set_ts_rel_ns(Decimal(get_sim_time('fs')).scaleb(-6))

    def get_ts_rel(self):
        ts_tod_s, ts_tod_ns, ts_rel_ns, ts_fns = self.timestamp_delay[0]
        return (ts_rel_ns, ts_fns)

    def get_ts_rel_64(self):
        ts_rel_ns, ts_fns = self.get_ts_rel()
        return (ts_rel_ns << 16) | (ts_fns >> 16)

    def get_ts_rel_ns(self):
        ts_rel_ns, ts_fns = self.get_ts_rel()
        return self.ctx.add(Decimal(ts_fns) / Decimal(2**32), Decimal(ts_rel_ns))

    def get_ts_rel_s(self):
        return self.get_ts_rel_ns().scaleb(-9, self.ctx)

    def _handle_reset(self, state):
        if state:
            self.log.info("Reset asserted")
            if self._run_cr is not None:
                self._run_cr.kill()
                self._run_cr = None

            self.ts_tod_s = 0
            self.ts_tod_ns = 0
            self.ts_rel_ns = 0
            self.ts_fns = 0
            self.drift_cnt = 0

            self.data.value = 1
        else:
            self.log.info("Reset de-asserted")
            if self._run_cr is None:
                self._run_cr = cocotb.start_soon(self._run())

    async def _run(self):
        clock_edge_event = RisingEdge(self.clock)
        msg_index = 0
        msg = None
        msg_delay = 0
        word = None
        bit_index = 0

        while True:
            await clock_edge_event

            # delay timestamp
            self.timestamp_delay.append((self.ts_tod_s, self.ts_tod_ns, self.ts_rel_ns, self.ts_fns))
            while len(self.timestamp_delay) > 14*17+self.td_delay:
                self.timestamp_delay.pop(0)

            # increment fns portion
            self.ts_fns += ((self.period_ns << 32) + self.period_fns)

            if self.drift_denom:
                if self.drift_cnt > 0:
                    self.drift_cnt -= 1
                else:
                    self.drift_cnt = self.drift_denom-1
                    self.ts_fns += self.drift_num

            ns_inc = self.ts_fns >> 32
            self.ts_fns &= 0xffffffff

            # increment relative timestamp
            self.ts_rel_ns = (self.ts_rel_ns + ns_inc) & 0xffffffffffff

            # increment ToD timestamp
            self.ts_tod_ns = self.ts_tod_ns + ns_inc

            if self.ts_tod_ns >= 1000000000:
                self.log.info("Seconds rollover")
                self.pps.set()
                self.ts_tod_s += 1
                self.ts_tod_ns -= 1000000000

            # compute offset for current second
            self.ts_tod_offset_ns = (self.ts_tod_ns - self.ts_rel_ns) & 0xffffffff

            # compute alternate offset
            if self.ts_tod_ns >> 27 == 7:
                # latter portion of second; compute offset for next second
                self.ts_tod_alt_s = self.ts_tod_s+1
                self.ts_tod_alt_offset_ns = (self.ts_tod_offset_ns - 1000000000) & 0xffffffff
            else:
                # former portion of second; compute offset for previous second
                self.ts_tod_alt_s = self.ts_tod_s-1
                self.ts_tod_alt_offset_ns = (self.ts_tod_offset_ns + 1000000000) & 0xffffffff

            if msg_delay <= 0:
                # build message

                msg = []

                # word 0: control
                ctrl = 0
                ctrl |= msg_index & 0xf
                ctrl |= bool(self.ts_rel_updated) << 8
                ctrl |= bool(self.ts_tod_s & 1) << 9
                self.ts_rel_updated = False
                msg.append(ctrl)

                if msg_index == 0:
                    # msg 0 word 1: current ToD TS ns 15:0
                    msg.append(self.ts_tod_ns & 0xffff)
                    # msg 0 word 2: current ToD TS ns 29:16 and flag bit
                    msg.append(((self.ts_tod_ns >> 16) & 0x3fff) | (0x8000 if self.ts_tod_updated else 0))
                    self.ts_tod_updated = False
                    # msg 0 word 3: current ToD TS seconds 15:0
                    msg.append(self.ts_tod_s & 0xffff)
                    # msg 0 word 4: current ToD TS seconds 31:16
                    msg.append((self.ts_tod_s >> 16) & 0xffff)
                    # msg 0 word 5: current ToD TS seconds 47:32
                    msg.append((self.ts_tod_s >> 32) & 0xffff)
                    msg_index = 1
                elif msg_index == 1:
                    # msg 1 word 1: current ToD TS ns offset 15:0
                    msg.append(self.ts_tod_offset_ns & 0xffff)
                    # msg 1 word 2: current ToD TS ns offset 31:16
                    msg.append((self.ts_tod_offset_ns >> 16) & 0xffff)
                    # msg 1 word 3: drift num
                    msg.append(self.drift_num)
                    # msg 1 word 4: drift denom
                    msg.append(self.drift_denom)
                    # msg 1 word 5: drift state
                    msg.append(self.drift_cnt)
                    msg_index = 2
                elif msg_index == 2:
                    # msg 2 word 1: alternate ToD TS ns offset 15:0
                    msg.append(self.ts_tod_alt_offset_ns & 0xffff)
                    # msg 2 word 2: alternate ToD TS ns offset 31:16
                    msg.append((self.ts_tod_alt_offset_ns >> 16) & 0xffff)
                    # msg 2 word 3: alternate ToD TS seconds 15:0
                    msg.append(self.ts_tod_alt_s & 0xffff)
                    # msg 2 word 4: alternate ToD TS seconds 31:16
                    msg.append((self.ts_tod_alt_s >> 16) & 0xffff)
                    # msg 2 word 5: alternate ToD TS seconds 47:32
                    msg.append((self.ts_tod_alt_s >> 32) & 0xffff)
                    msg_index = 0

                # word 6: current fns 15:0
                msg.append(self.ts_fns & 0xffff)
                # word 7: current fns 31:16
                msg.append((self.ts_fns >> 16) & 0xffff)
                # word 8: current relative TS ns 15:0
                msg.append(self.ts_rel_ns & 0xffff)
                # word 9: current relative TS ns 31:16
                msg.append((self.ts_rel_ns >> 16) & 0xffff)
                # word 10: current relative TS ns 47:32
                msg.append((self.ts_rel_ns >> 32) & 0xffff)
                # word 11: current phase increment fns 15:0
                msg.append(self.period_fns & 0xffff)
                # word 12: current phase increment fns 31:16
                msg.append((self.period_fns >> 16) & 0xffff)
                # word 13: current phase increment ns 7:0 + crc
                msg.append(self.period_ns & 0xff)

                msg_delay = 255
            else:
                msg_delay -= 1

            # serialize message
            if word is None:
                if msg:
                    word = msg.pop(0)
                    bit_index = 0
                    self.data.value = 0
                else:
                    self.data.value = 1
            else:
                self.data.value = bool((word >> bit_index) & 1)
                bit_index += 1
                if bit_index == 16:
                    word = None


class PtpTdSink(Reset):
    def __init__(self,
            data=None,
            clock=None,
            reset=None,
            reset_active_level=True,
            period_ns=6.4,
            td_delay=32,
            *args, **kwargs):

        self.log = logging.getLogger(f"cocotb.{data._path}")
        self.data = data
        self.clock = clock
        self.reset = reset

        self.log.info("PTP time distribution sink")
        self.log.info("Copyright (c) 2023 Alex Forencich")
        self.log.info("https://github.com/alexforencich/verilog-ethernet")

        super().__init__(*args, **kwargs)

        self.ctx = Context(prec=60)

        self.period_ns = 0
        self.period_fns = 0
        self.drift_num = 0
        self.drift_denom = 0

        self.ts_fns = 0

        self.ts_rel_ns = 0

        self.ts_tod_s = 0
        self.ts_tod_ns = 0

        self.ts_tod_offset_ns = 0

        self.ts_tod_alt_s = 0
        self.ts_tod_alt_offset_ns = 0

        self.td_delay = td_delay

        self.drift_cnt = 0

        self.pps = Event()

        self._run_cr = None

        self._init_reset(reset, reset_active_level)

    def get_period_ns(self):
        p = Decimal((self.period_ns << 32) | self.period_fns)
        if self.drift_denom:
            return p + Decimal(self.drift_num) / Decimal(self.drift_denom)
        return p / Decimal(2**32)

    def get_ts_tod(self):
        return (self.ts_tod_s, self.ts_tod_ns, self.ts_fns)

    def get_ts_tod_96(self):
        ts_tod_s, ts_tod_ns, ts_fns = self.get_ts_tod()
        return (ts_tod_s << 48) | (ts_tod_ns << 16) | (ts_fns >> 16)

    def get_ts_tod_ns(self):
        ts_tod_s, ts_tod_ns, ts_fns = self.get_ts_tod()
        ns = Decimal(ts_fns) / Decimal(2**32)
        ns = self.ctx.add(ns, Decimal(ts_tod_ns))
        return self.ctx.add(ns, Decimal(ts_tod_s).scaleb(9))

    def get_ts_tod_s(self):
        return self.get_ts_tod_ns().scaleb(-9, self.ctx)

    def get_ts_rel(self):
        return (self.ts_rel_ns, self.ts_fns)

    def get_ts_rel_64(self):
        ts_rel_ns, ts_fns = self.get_ts_rel()
        return (ts_rel_ns << 16) | (ts_fns >> 16)

    def get_ts_rel_ns(self):
        ts_rel_ns, ts_fns = self.get_ts_rel()
        return self.ctx.add(Decimal(ts_fns) / Decimal(2**32), Decimal(ts_rel_ns))

    def get_ts_rel_s(self):
        return self.get_ts_rel_ns().scaleb(-9, self.ctx)

    def _handle_reset(self, state):
        if state:
            self.log.info("Reset asserted")
            if self._run_cr is not None:
                self._run_cr.kill()
                self._run_cr = None

            self.ts_tod_s = 0
            self.ts_tod_ns = 0
            self.ts_rel_ns = 0
            self.ts_fns = 0
            self.drift_cnt = 0

            self.data.value = 1
        else:
            self.log.info("Reset de-asserted")
            if self._run_cr is None:
                self._run_cr = cocotb.start_soon(self._run())

    async def _run(self):
        clock_edge_event = RisingEdge(self.clock)
        msg_index = 0
        msg = None
        msg_delay = 0
        cur_msg = []
        word = None
        bit_index = 0

        while True:
            await clock_edge_event

            sdi_sample = self.data.value.integer

            # increment fns portion
            self.ts_fns += ((self.period_ns << 32) + self.period_fns)

            if self.drift_denom:
                if self.drift_cnt > 0:
                    self.drift_cnt -= 1
                else:
                    self.drift_cnt = self.drift_denom-1
                    self.ts_fns += self.drift_num

            ns_inc = self.ts_fns >> 32
            self.ts_fns &= 0xffffffff

            # increment relative timestamp
            self.ts_rel_ns = (self.ts_rel_ns + ns_inc) & 0xffffffffffff

            # increment ToD timestamp
            self.ts_tod_ns = self.ts_tod_ns + ns_inc

            if self.ts_tod_ns >= 1000000000:
                self.log.info("Seconds rollover")
                self.pps.set()
                self.ts_tod_s += 1
                self.ts_tod_ns -= 1000000000

            # process messages
            if msg_delay > 0:
                msg_delay -= 1

            if msg_delay == 0 and msg:
                self.log.info("process message %r", msg)

                # word 0: control
                msg_index = msg[0] & 0xf

                if msg_index == 0:
                    # msg 0 word 1: current ToD TS ns 15:0
                    # msg 0 word 2: current ToD TS ns 29:16
                    val = ((msg[2] & 0x3fff) << 16) | msg[1]
                    if self.ts_tod_ns != val:
                        self.log.info("update ts_tod_ns: old 0x%x, new 0x%x", self.ts_tod_ns, val)
                        self.ts_tod_ns = val
                    # msg 0 word 3: current ToD TS seconds 15:0
                    # msg 0 word 4: current ToD TS seconds 31:16
                    # msg 0 word 5: current ToD TS seconds 47:32
                    val = (msg[5] << 32) | (msg[4] << 16) | msg[3]
                    if self.ts_tod_s != val:
                        self.log.info("update ts_tod_s: old 0x%x, new 0x%x", self.ts_tod_s, val)
                        self.ts_tod_s = val
                elif msg_index == 1:
                    # msg 1 word 1: current ToD TS ns offset 15:0
                    # msg 1 word 2: current ToD TS ns offset 31:16
                    val = (msg[2] << 16) | msg[1]
                    if self.ts_tod_offset_ns != val:
                        self.log.info("update ts_tod_offset_ns: old 0x%x, new 0x%x", self.ts_tod_offset_ns, val)
                        self.ts_tod_offset_ns = val
                    # msg 1 word 3: drift num
                    val = msg[3]
                    if self.drift_num != val:
                        self.log.info("update drift_num: old 0x%x, new 0x%x", self.drift_num, val)
                        self.drift_num = val
                    # msg 1 word 4: drift denom
                    val = msg[4]
                    if self.drift_denom != val:
                        self.log.info("update drift_denom: old 0x%x, new 0x%x", self.drift_denom, val)
                        self.drift_denom = val
                    # msg 1 word 5: drift state
                    val = msg[5]
                    if self.drift_cnt != val:
                        self.log.info("update drift_cnt: old 0x%x, new 0x%x", self.drift_cnt, val)
                        self.drift_cnt = val
                elif msg_index == 2:
                    # msg 2 word 1: alternate ToD TS ns offset 15:0
                    # msg 2 word 2: alternate ToD TS ns offset 31:16
                    val = (msg[2] << 16) | msg[1]
                    if self.ts_tod_alt_offset_ns != val:
                        self.log.info("update ts_tod_alt_offset_ns: old 0x%x, new 0x%x", self.ts_tod_alt_offset_ns, val)
                        self.ts_tod_alt_offset_ns = val
                    # msg 2 word 3: alternate ToD TS seconds 15:0
                    # msg 2 word 4: alternate ToD TS seconds 31:16
                    # msg 2 word 5: alternate ToD TS seconds 47:32
                    val = (msg[5] << 32) | (msg[4] << 16) | msg[3]
                    if self.ts_tod_alt_s != val:
                        self.log.info("update ts_tod_alt_s: old 0x%x, new 0x%x", self.ts_tod_alt_s, val)
                        self.ts_tod_alt_s = val

                # word 6: current fns 15:0
                # word 7: current fns 31:16
                val = (msg[7] << 16) | msg[6]
                if self.ts_fns != val:
                    self.log.info("update ts_fns: old 0x%x, new 0x%x", self.ts_fns, val)
                    self.ts_fns = val
                # word 8: current relative TS ns 15:0
                # word 9: current relative TS ns 31:16
                # word 10: current relative TS ns 47:32
                val = (msg[10] << 32) | (msg[9] << 16) | msg[8]
                if self.ts_rel_ns != val:
                    self.log.info("update ts_rel_ns: old 0x%x, new 0x%x", self.ts_rel_ns, val)
                    self.ts_rel_ns = val
                # word 11: current phase increment fns 15:0
                # word 12: current phase increment fns 31:16
                val = (msg[12] << 16) | msg[11]
                if self.period_fns != val:
                    self.log.info("update period_fns: old 0x%x, new 0x%x", self.period_fns, val)
                    self.period_fns = val
                # word 13: current phase increment ns 7:0 + crc
                val = msg[13] & 0xff
                if self.period_ns != val:
                    self.log.info("update period_ns: old 0x%x, new 0x%x", self.period_ns, val)
                    self.period_ns = val

                msg = None

            # deserialize message
            if word is not None:
                word = word | (sdi_sample << bit_index)
                bit_index += 1

                if bit_index == 16:
                    cur_msg.append(word)
                    word = None
            else:
                if not sdi_sample:
                    # start bit
                    word = 0
                    bit_index = 0
                elif cur_msg:
                    # idle
                    msg = cur_msg
                    msg_delay = self.td_delay
                    cur_msg = []

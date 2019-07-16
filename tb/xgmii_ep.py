"""

Copyright (c) 2015-2018 Alex Forencich

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

ETH_PRE = 0x55
ETH_SFD = 0xD5

XGMII_IDLE   = 0x07
XGMII_LPI    = 0x06
XGMII_START  = 0xfb
XGMII_TERM   = 0xfd
XGMII_ERROR  = 0xfe
XGMII_SEQ_OS = 0x9c
XGMII_RES0   = 0x1c
XGMII_RES1   = 0x3c
XGMII_RES2   = 0x7c
XGMII_RES3   = 0xbc
XGMII_RES4   = 0xdc
XGMII_RES5   = 0xf7
XGMII_SIG_OS = 0x5c

class XGMIIFrame(object):
    def __init__(self, data=b'', error=None, ctrl=None):
        self.data = b''
        self.error = None
        self.ctrl = None

        if type(data) is XGMIIFrame:
            self.data = data.data
            self.error = data.error
            self.ctrl = data.ctrl
        else:
            self.data = bytearray(data)

    def build(self):
        if self.data is None:
            return

        f = list(self.data)
        ctrl = []
        error = []
        d = []
        c = []
        i = 0

        assert_error = False
        if (type(self.error) is int or type(self.error) is bool) and self.error:
            assert_error = True
            error = [0]*len(self.data)
            error[-1] = 1
        elif self.error is None:
            error = [0]*len(self.data)
        else:
            error = list(self.error)

        if self.ctrl is None:
            ctrl = [0]*len(self.data)
        else:
            ctrl = list(self.ctrl)

        assert len(ctrl) == len(f)
        assert len(ctrl) == len(f)

        for i in range(len(f)):
            if error[i]:
                f[i] = XGMII_ERROR
                ctrl[i] = 1

        i = 0
        while len(f) > 0:
            d.append(f.pop(0))
            c.append(ctrl[i])
            i += 1

        return d, c

    def parse(self, d, c):
        if d is None or c is None:
            return

        self.data = bytearray(d)
        self.ctrl = c

        self.error = [0]*len(self.data)

        for i in range(len(self.data)):
            if c[i] and d[i] == XGMII_ERROR:
                self.error[i] = 1

    def __eq__(self, other):
        if type(other) is XGMIIFrame:
            return self.data == other.data

    def __repr__(self):
        return 'XGMIIFrame(data=%s, error=%s, ctrl=%s)' % (repr(self.data), repr(self.error), repr(self.ctrl))

    def __iter__(self):
        return self.data.__iter__()


class XGMIISource(object):
    def __init__(self, ifg=12, enable_dic=True):
        self.has_logic = False
        self.queue = []
        self.ifg = ifg
        self.enable_dic = enable_dic
        self.force_offset_start = False

    def send(self, frame):
        self.queue.append(XGMIIFrame(frame))

    def count(self):
        return len(self.queue)

    def empty(self):
        return not self.queue

    def create_logic(self,
                clk,
                rst,
                txd,
                txc,
                enable=True,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        assert len(txd) in [32, 64]
        assert len(txd) == len(txc)*8

        bw = int(len(txd)/8)

        @instance
        def logic():
            frame = None
            dl = []
            cl = []
            ifg_cnt = 0
            deficit_idle_cnt = 0

            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    frame = None
                    txd.next = 0x0707070707070707 if bw == 8 else 0x07070707
                    txc.next = 0xff if bw == 8 else 0xf
                    dl = []
                    cl = []
                    ifg_cnt = 0
                    deficit_idle_cnt = 0
                elif enable:
                    if ifg_cnt > bw-1 or (not self.enable_dic and ifg_cnt > 0):
                        ifg_cnt = max(ifg_cnt - bw, 0)
                        txd.next = 0x0707070707070707 if bw == 8 else 0x07070707
                        txc.next = 0xff if bw == 8 else 0xf
                    elif dl:
                        d = 0
                        c = 0

                        for i in range(bw):
                            if dl:
                                d |= dl.pop(0) << (8*i)
                                c |= cl.pop(0) << i
                                if not dl:
                                    ifg_cnt = self.ifg - (bw-i) + deficit_idle_cnt
                            else:
                                d |= XGMII_IDLE << (8*i)
                                c |= 1 << i

                        txd.next = d
                        txc.next = c
                    elif self.queue:
                        frame = self.queue.pop(0)
                        dl, cl = frame.build()
                        if name is not None:
                            print("[%s] Sending frame %s" % (name, repr(frame)))

                        assert len(dl) > 0
                        assert dl[0] == ETH_PRE
                        dl[0] = XGMII_START
                        cl[0] = 1
                        dl.append(XGMII_TERM)
                        cl.append(1)

                        if (bw == 8 and ifg_cnt >= 4) or self.force_offset_start:
                            ifg_cnt = max(ifg_cnt-4, 0)
                            dl = [XGMII_IDLE]*4+dl
                            cl = [1]*4+cl

                        deficit_idle_cnt = max(ifg_cnt, 0)
                        ifg_cnt = 0

                        d = 0
                        c = 0

                        for i in range(0,bw):
                            if dl:
                                d |= dl.pop(0) << (8*i)
                                c |= cl.pop(0) << i
                                if not dl:
                                    ifg_cnt = self.ifg - (bw-i) + deficit_idle_cnt
                            else:
                                d |= XGMII_IDLE << (8*i)
                                c |= 1 << i

                        txd.next = d
                        txc.next = c
                    else:
                        ifg_cnt = 0
                        deficit_idle_cnt = 0
                        txd.next = 0x0707070707070707 if bw == 8 else 0x07070707
                        txc.next = 0xff if bw == 8 else 0xf

        return instances()


class XGMIISink(object):
    def __init__(self):
        self.has_logic = False
        self.queue = []
        self.sync = Signal(intbv(0))

    def recv(self):
        if self.queue:
            return self.queue.pop(0)
        return None

    def count(self):
        return len(self.queue)

    def empty(self):
        return not self.queue

    def wait(self, timeout=0):
        yield delay(0)
        if self.queue:
            return
        if timeout:
            yield self.sync, delay(timeout)
        else:
            yield self.sync

    def create_logic(self,
                clk,
                rst,
                rxd,
                rxc,
                enable=True,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        assert len(rxd) in [32, 64]
        assert len(rxd) == len(rxc)*8

        bw = int(len(rxd)/8)

        @instance
        def logic():
            frame = None
            d = []
            c = []

            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    frame = None
                    d = []
                    c = []
                elif enable:
                    if frame is None:
                        if rxc & 1 and rxd & 0xff == XGMII_START:
                            # start in lane 0
                            frame = XGMIIFrame()
                            d = [ETH_PRE]
                            c = [0]
                            for i in range(1,bw):
                                d.append((int(rxd) >> (8*i)) & 0xff)
                                c.append((int(rxc) >> i) & 1)
                        elif bw == 8 and (rxc >> 4) & 1 and (rxd >> 32) & 0xff == XGMII_START:
                            # start in lane 4
                            frame = XGMIIFrame()
                            d = [ETH_PRE]
                            c = [0]
                            for i in range(5,bw):
                                d.append((int(rxd) >> (8*i)) & 0xff)
                                c.append((int(rxc) >> i) & 1)
                    else:
                        for i in range(bw):
                            if (rxc >> i) & 1:
                                # got a control character; terminate frame reception
                                if (rxd >> (8*i)) & 0xff != XGMII_TERM:
                                    # store control character if it's not a termination
                                    d.append((int(rxd) >> (8*i)) & 0xff)
                                    c.append((int(rxc) >> i) & 1)
                                frame.parse(d, c)
                                self.queue.append(frame)
                                self.sync.next = not self.sync
                                if name is not None:
                                    print("[%s] Got frame %s" % (name, repr(frame)))
                                frame = None
                                d = []
                                c = []
                                break
                            else:
                                d.append((int(rxd) >> (8*i)) & 0xff)
                                c.append((int(rxc) >> i) & 1)

        return instances()


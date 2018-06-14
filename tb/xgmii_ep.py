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
                f[i] = 0xfe
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
            if c[i] and d[i] == 0xfe:
                self.error[i] = 1

    def __eq__(self, other):
        if type(other) is XGMIIFrame:
            return self.data == other.data

    def __repr__(self):
        return 'XGMIIFrame(data=%s, error=%s, ctrl=%s)' % (repr(self.data), repr(self.error), repr(self.ctrl))

    def __iter__(self):
        return self.data.__iter__()


class XGMIISource(object):
    def __init__(self):
        self.has_logic = False
        self.queue = []

    def send(self, frame):
        self.queue.append(XGMIIFrame(frame))

    def count(self):
        return len(self.queue)

    def empty(self):
        return self.count() == 0

    def create_logic(self,
                clk,
                rst,
                txd,
                txc,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        assert len(txd) in [32, 64]

        bw = int(len(txd)/8)

        @instance
        def logic():
            frame = None
            dl = []
            cl = []
            ifg_cnt = 0
            deficit_idle_cnt = 0
            nt = False

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
                    nt = False
                else:
                    if ifg_cnt > bw-1:
                        ifg_cnt -= bw
                        txd.next = 0x0707070707070707 if bw == 8 else 0x07070707
                        txc.next = 0xff if bw == 8 else 0xf
                    elif len(dl) > 0 or nt:
                        d = 0
                        c = 0

                        for i in range(bw):
                            if len(dl) > 0:
                                d |= dl.pop(0) << (8*i)
                                c |= cl.pop(0) << i
                                nt = True
                            else:
                                if nt:
                                    d |= 0xfd << (8*i)
                                    nt = False
                                    ifg_cnt = 12 - (bw-i) + deficit_idle_cnt
                                else:
                                    d |= 0x07 << (8*i)
                                c |= 1 << i

                        txd.next = d
                        txc.next = c
                    elif len(self.queue) > 0:
                        frame = self.queue.pop(0)
                        dl, cl = frame.build()
                        if name is not None:
                            print("[%s] Sending frame %s" % (name, repr(frame)))

                        if ifg_cnt >= 4:
                            deficit_idle_cnt = ifg_cnt - 4
                        else:
                            deficit_idle_cnt = ifg_cnt
                            ifg_cnt = 0

                        assert len(dl) > 0
                        assert dl.pop(0) == 0x55
                        cl.pop(0)

                        k = 1
                        d = 0xfb
                        c = 1

                        if ifg_cnt > 0:
                            k = 5
                            d = 0xfb07070707
                            c = 0x1f

                        for i in range(k,bw):
                            if len(dl) > 0:
                                d |= dl.pop(0) << (8*i)
                                c |= cl.pop(0) << i
                                nt = True
                            else:
                                if nt:
                                    d |= 0xfd << (8*i)
                                    nt = False
                                else:
                                    d |= 0x07 << (8*i)
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

    def recv(self):
        if len(self.queue) > 0:
            return self.queue.pop(0)
        return None

    def count(self):
        return len(self.queue)

    def empty(self):
        return self.count() == 0

    def create_logic(self,
                clk,
                rst,
                rxd,
                rxc,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        assert len(rxd) in [32, 64]

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
                else:
                    if frame is None:
                        if rxc & 1 and rxd & 0xff == 0xfb:
                            # start in lane 0
                            frame = XGMIIFrame()
                            d = [0x55]
                            c = [0]
                            for i in range(1,bw):
                                d.append((int(rxd) >> (8*i)) & 0xff)
                                c.append((int(rxc) >> i) & 1)
                        elif bw == 8 and (rxc >> 4) & 1 and (rxd >> 32) & 0xff == 0xfb:
                            # start in lane 4
                            frame = XGMIIFrame()
                            d = [0x55]
                            c = [0]
                            for i in range(5,8):
                                d.append((int(rxd) >> (8*i)) & 0xff)
                                c.append((int(rxc) >> i) & 1)
                    else:
                        for i in range(bw):
                            if (rxc >> i) & 1 and (rxd >> (8*i)) & 0xff == 0xfd:
                                # terminate
                                frame.parse(d, c)
                                self.queue.append(frame)
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


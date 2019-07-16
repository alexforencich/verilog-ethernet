"""

Copyright (c) 2014-2018 Alex Forencich

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

class GMIIFrame(object):
    def __init__(self, data=b'', error=None):
        self.data = b''
        self.error = None

        if type(data) is GMIIFrame:
            self.data = data.data
            self.error = data.error
        else:
            self.data = bytearray(data)

    def build(self):
        if self.data is None:
            return

        f = list(self.data)
        d = []
        er = []
        i = 0

        assert_er = False
        if (type(self.error) is int or type(self.error) is bool) and self.error:
            assert_er = True
            self.error = None

        while len(f) > 0:
            d.append(f.pop(0))
            if self.error is None:
                er.append(0)
            else:
                er.append(self.error[i])
            i += 1

        if assert_er:
            er[-1] = 1
            self.error = 1

        return d, er

    def parse(self, d, er):
        if d is None or er is None:
            return

        self.data = bytearray(d)
        self.error = er

    def __eq__(self, other):
        if type(other) is GMIIFrame:
            return self.data == other.data
        return False

    def __repr__(self):
        return 'GMIIFrame(data=%s, error=%s)' % (repr(self.data), repr(self.error))

    def __iter__(self):
        return self.data.__iter__()


class GMIISource(object):
    def __init__(self):
        self.has_logic = False
        self.queue = []

    def send(self, frame):
        self.queue.append(GMIIFrame(frame))

    def count(self):
        return len(self.queue)

    def empty(self):
        return not self.queue

    def create_logic(self,
                clk,
                rst,
                txd,
                tx_en,
                tx_er,
                clk_enable=True,
                mii_select=False,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        assert len(txd) == 8

        @instance
        def logic():
            frame = None
            d = []
            er = []
            ifg_cnt = 0

            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    frame = None
                    txd.next = 0
                    tx_en.next = 0
                    tx_er.next = 0
                    d = []
                    er = []
                    ifg_cnt = 0
                else:
                    if not clk_enable:
                        pass
                    elif ifg_cnt > 0:
                        ifg_cnt -= 1
                        txd.next = 0
                        tx_er.next = 0
                        tx_en.next = 0
                    elif len(d) > 0:
                        txd.next = d.pop(0)
                        tx_er.next = er.pop(0)
                        tx_en.next = 1
                        if len(d) == 0:
                            if mii_select:
                                ifg_cnt = 12*2
                            else:
                                ifg_cnt = 12
                    elif self.queue:
                        frame = GMIIFrame(self.queue.pop(0))
                        d, er = frame.build()
                        if name is not None:
                            print("[%s] Sending frame %s" % (name, repr(frame)))
                        if mii_select:
                            d2 = []
                            for b in d:
                                d2.append(b & 0x0F)
                                d2.append(b >> 4)
                            d = d2
                            er2 = []
                            for b in er:
                                er2.append(b)
                                er2.append(b)
                            er = er2
                        txd.next = d.pop(0)
                        tx_er.next = er.pop(0)
                        tx_en.next = 1
                    else:
                        txd.next = 0
                        tx_er.next = 0
                        tx_en.next = 0

        return instances()


class GMIISink(object):
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
                rx_dv,
                rx_er,
                clk_enable=True,
                mii_select=False,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        assert len(rxd) == 8

        @instance
        def logic():
            frame = None
            d = []
            er = []

            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    frame = None
                    d = []
                    er = []
                else:
                    if not clk_enable:
                        pass
                    elif rx_dv:
                        if frame is None:
                            frame = GMIIFrame()
                            d = []
                            er = []
                        d.append(int(rxd))
                        er.append(int(rx_er))
                    elif frame is not None:
                        if len(d) > 0:
                            if mii_select:
                                odd = True
                                sync = False
                                b = 0
                                be = 0
                                d2 = []
                                er2 = []
                                for n, e in zip(d, er):
                                    odd = not odd
                                    b = (n & 0x0F) << 4 | b >> 4
                                    be |= e
                                    if not sync and b == 0xD5:
                                        odd = True
                                        sync = True
                                    if odd:
                                        d2.append(b)
                                        er2.append(be)
                                        be = False
                                d = d2
                                er = er2
                            frame.parse(d, er)
                            self.queue.append(frame)
                            self.sync.next = not self.sync
                            if name is not None:
                                print("[%s] Got frame %s" % (name, repr(frame)))
                        frame = None
                        d = []
                        er = []

        return instances()


"""

Copyright (c) 2014-2017 Alex Forencich

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

skip_asserts = False

class AXIStreamFrame(object):
    def __init__(self, data=b'', keep=None, dest=None, user=None):
        self.B = 0
        self.N = 8
        self.M = 1
        self.WL = 8
        self.data = b''
        self.keep = None
        self.dest = 0
        self.user = None

        if type(data) is bytes or type(data) is bytearray:
            self.data = bytearray(data)
            self.keep = keep
            self.dest = dest
            self.user = user
        elif type(data) is AXIStreamFrame:
            self.N = data.N
            self.WL = data.WL
            if type(data.data) is bytearray:
                self.data = bytearray(data.data)
            else:
                self.data = list(data.data)
            if data.keep is not None:
                self.keep = list(data.keep)
            if data.dest is not None:
                if type(data.dest) is int:
                    self.dest = data.dest
                else:
                    self.dest = list(data.dest)
            if data.user is not None:
                if type(data.user) is int or type(data.user) is bool:
                    self.user = data.user
                else:
                    self.user = list(data.user)
        else:
            self.data = list(data)
            self.keep = keep
            self.dest = dest
            self.user = user

    def build(self):
        if self.data is None:
            return

        f = list(self.data)
        tdata = []
        tkeep = []
        tdest = []
        tuser = []
        i = 0

        dest = 0
        if type(self.dest) is int:
            dest = self.dest
            self.dest = None

        assert_tuser = False
        if (type(self.user) is int or type(self.user) is bool) and self.user:
            assert_tuser = True
            self.user = None

        if self.B == 0:
            while len(f) > 0:
                data = 0
                keep = 0
                for j in range(self.M):
                    data = data | (f.pop(0) << (j*self.WL))
                    keep = keep | (1 << j)
                    if len(f) == 0: break
                tdata.append(data)
                if self.keep is None:
                    tkeep.append(keep)
                else:
                    tkeep.append(self.keep[i])
                if self.dest is None:
                    tdest.append(dest)
                else:
                    tdest.append(self.dest[i])
                if self.user is None:
                    tuser.append(0)
                else:
                    tuser.append(self.user[i])
                i += 1
        else:
            # multiple tdata signals
            while len(f) > 0:
                data = 0
                tdata.append(f.pop(0))
                tkeep.append(0)
                if self.dest is None:
                    tdest.append(dest)
                else:
                    tdest.append(self.dest[i])
                if self.user is None:
                    tuser.append(0)
                else:
                    tuser.append(self.user[i])
                i += 1

        if assert_tuser:
            tuser[-1] = 1
            self.user = 1

        if self.dest == None:
            self.dest = dest

        return tdata, tkeep, tdest, tuser

    def parse(self, tdata, tkeep, tdest, tuser):
        if tdata is None or tkeep is None or tuser is None:
            return
        if len(tdata) != len(tkeep) or len(tdata) != len(tdest) or len(tdata) != len(tuser):
            raise Exception("Invalid data")

        self.data = []
        self.keep = []
        self.dest = []
        self.user = []

        if self.B == 0:
            mask = 2**self.WL-1

            for i in range(len(tdata)):
                for j in range(self.M):
                    if tkeep[i] & (1 << j):
                        self.data.append((tdata[i] >> (j*self.WL)) & mask)
                self.keep.append(tkeep[i])
                self.dest.append(tdest[i])
                self.user.append(tuser[i])
        else:
            for i in range(len(tdata)):
                self.data.append(tdata[i])
                self.keep.append(tkeep[i])
                self.dest.append(tdest[i])
                self.user.append(tuser[i])

        if self.WL == 8:
            self.data = bytearray(self.data)

    def __eq__(self, other):
        if type(other) is AXIStreamFrame:
            return self.data == other.data
        return False

    def __repr__(self):
        return 'AXIStreamFrame(data=%s, keep=%s, dest=%s, user=%s)' % (repr(self.data), repr(self.keep), repr(self.dest), repr(self.user))

    def __iter__(self):
        return self.data.__iter__()


class AXIStreamSource(object):
    def __init__(self):
        self.has_logic = False
        self.queue = []

    def send(self, frame):
        self.queue.append(AXIStreamFrame(frame))

    def write(self, data):
        self.send(data)

    def count(self):
        return len(self.queue)

    def empty(self):
        return self.count() == 0

    def create_logic(self,
                clk,
                rst,
                tdata=None,
                tkeep=Signal(bool(True)),
                tvalid=Signal(bool(False)),
                tready=Signal(bool(True)),
                tlast=Signal(bool(False)),
                tdest=Signal(intbv(0)),
                tuser=Signal(bool(False)),
                pause=0,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        tready_int = Signal(bool(False))
        tvalid_int = Signal(bool(False))

        @always_comb
        def pause_logic():
            tready_int.next = tready and not pause
            tvalid.next = tvalid_int and not pause

        @instance
        def logic():
            frame = AXIStreamFrame()
            data = []
            keep = []
            dest = []
            user = []
            B = 0
            N = len(tdata)
            M = len(tkeep)
            WL = int((len(tdata)+M-1)/M)

            if type(tdata) is list or type(tdata) is tuple:
                # multiple tdata signals
                B = len(tdata)
                N = [len(b) for b in tdata]
                M = 1
                WL = [1]*B

            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    if B > 0:
                        for s in tdata:
                            s.next = 0
                    else:
                        tdata.next = 0
                    tkeep.next = 0
                    tdest.next = 0
                    tuser.next = False
                    tvalid_int.next = False
                    tlast.next = False
                else:
                    if tready_int and tvalid:
                        if len(data) > 0:
                            if B > 0:
                                l = data.pop(0)
                                for i in range(B):
                                    tdata[i].next = l[i]
                            else:
                                tdata.next = data.pop(0)
                            tkeep.next = keep.pop(0)
                            tdest.next = dest.pop(0)
                            tuser.next = user.pop(0)
                            tvalid_int.next = True
                            tlast.next = len(data) == 0
                        else:
                            tvalid_int.next = False
                            tlast.next = False
                    if (tlast and tready_int and tvalid) or not tvalid_int:
                        if len(self.queue) > 0:
                            frame = self.queue.pop(0)
                            frame.B = B
                            frame.N = N
                            frame.M = M
                            frame.WL = WL
                            data, keep, dest, user = frame.build()
                            if name is not None:
                                print("[%s] Sending frame %s" % (name, repr(frame)))
                            if B > 0:
                                l = data.pop(0)
                                for i in range(B):
                                    tdata[i].next = l[i]
                            else:
                                tdata.next = data.pop(0)
                            tkeep.next = keep.pop(0)
                            tdest.next = dest.pop(0)
                            tuser.next = user.pop(0)
                            tvalid_int.next = True
                            tlast.next = len(data) == 0

        return logic, pause_logic


class AXIStreamSink(object):
    def __init__(self):
        self.has_logic = False
        self.queue = []
        self.read_queue = []

    def recv(self):
        if len(self.queue) > 0:
            return self.queue.pop(0)
        return None

    def read(self, count=-1):
        while len(self.queue) > 0:
            self.read_queue.extend(self.queue.pop(0).data)
        if count < 0:
            count = len(self.read_queue)
        data = self.read_queue[:count]
        del self.read_queue[:count]
        return data

    def count(self):
        return len(self.queue)

    def empty(self):
        return self.count() == 0

    def create_logic(self,
                clk,
                rst,
                tdata=None,
                tkeep=Signal(bool(True)),
                tvalid=Signal(bool(False)),
                tready=Signal(bool(True)),
                tlast=Signal(bool(True)),
                tdest=Signal(intbv(0)),
                tuser=Signal(bool(False)),
                pause=0,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        tready_int = Signal(bool(False))
        tvalid_int = Signal(bool(False))

        @always_comb
        def pause_logic():
            tready.next = tready_int and not pause
            tvalid_int.next = tvalid and not pause

        @instance
        def logic():
            frame = AXIStreamFrame()
            data = []
            keep = []
            dest = []
            user = []
            B = 0
            N = len(tdata)
            M = len(tkeep)
            WL = int((len(tdata)+M-1)/M)
            first = True

            if type(tdata) is list or type(tdata) is tuple:
                # multiple tdata signals
                B = len(tdata)
                N = [len(b) for b in tdata]
                M = 1
                WL = [1]*B

            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    tready_int.next = False
                    frame = AXIStreamFrame()
                    data = []
                    keep = []
                    dest = []
                    user = []
                    first = True
                else:
                    tready_int.next = True

                    if tvalid_int:

                        if not skip_asserts:
                            # zero tkeep not allowed
                            assert int(tkeep) != 0
                            # tkeep must be contiguous
                            # i.e. 0b00011110 allowed, but 0b00011010 not allowed
                            b = int(tkeep)
                            while b & 1 == 0:
                                b = b >> 1
                            while b & 1 == 1:
                                b = b >> 1
                            assert b == 0
                            # tkeep must not have gaps across cycles
                            if not first:
                                # not first cycle; lowest bit must be set
                                assert int(tkeep) & 1
                            if not tlast:
                                # not last cycle; highest bit must be set
                                assert int(tkeep) & (1 << len(tkeep)-1)

                        if B > 0:
                            l = []
                            for i in range(B):
                                l.append(int(tdata[i]))
                            data.append(l)
                        else:
                            data.append(int(tdata))
                        keep.append(int(tkeep))
                        dest.append(int(tdest))
                        user.append(int(tuser))
                        first = False
                        if tlast:
                            frame.B = B
                            frame.N = N
                            frame.M = M
                            frame.WL = WL
                            frame.parse(data, keep, dest, user)
                            self.queue.append(frame)
                            if name is not None:
                                print("[%s] Got frame %s" % (name, repr(frame)))
                            frame = AXIStreamFrame()
                            data = []
                            keep = []
                            dest = []
                            user = []
                            first = True

        return logic, pause_logic


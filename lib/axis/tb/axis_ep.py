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

skip_asserts = False

class AXIStreamFrame(object):
    def __init__(self, data=b'', keep=None, id=None, dest=None, user=None, last_cycle_user=None):
        self.B = 0
        self.N = 8
        self.M = 1
        self.WL = 8
        self.data = b''
        self.keep = None
        self.id = 0
        self.dest = 0
        self.user = None
        self.last_cycle_user = None

        if type(data) in (bytes, bytearray):
            self.data = bytearray(data)
            self.keep = keep
            self.id = id
            self.dest = dest
            self.user = user
            self.last_cycle_user = last_cycle_user
        elif type(data) is AXIStreamFrame:
            self.N = data.N
            self.WL = data.WL
            if type(data.data) is bytearray:
                self.data = bytearray(data.data)
            else:
                self.data = list(data.data)
            if data.keep is not None:
                self.keep = list(data.keep)
            if data.id is not None:
                if type(data.id) in (int, bool):
                    self.id = data.id
                else:
                    self.id = list(data.id)
            if data.dest is not None:
                if type(data.dest) in (int, bool):
                    self.dest = data.dest
                else:
                    self.dest = list(data.dest)
            if data.user is not None:
                if type(data.user) in (int, bool):
                    self.user = data.user
                else:
                    self.user = list(data.user)
            self.last_cycle_user = data.last_cycle_user
        else:
            self.data = list(data)
            self.keep = keep
            self.id = id
            self.dest = dest
            self.user = user
            self.last_cycle_user = last_cycle_user

    def build(self):
        if self.data is None:
            return

        f = list(self.data)
        tdata = []
        tkeep = []
        tid = []
        tdest = []
        tuser = []
        i = 0

        while len(f) > 0:
            if self.B == 0:
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
            else:
                # multiple tdata signals
                data = 0
                tdata.append(f.pop(0))
                tkeep.append(0)

            if self.id is None:
                tid.append(0)
            elif type(self.id) is int:
                tid.append(self.id)
            else:
                tid.append(self.id[i])

            if self.dest is None:
                tdest.append(0)
            elif type(self.dest) is int:
                tdest.append(self.dest)
            else:
                tdest.append(self.dest[i])

            if self.user is None:
                tuser.append(0)
            elif type(self.user) is int:
                tuser.append(self.user)
            else:
                tuser.append(self.user[i])
            i += 1

        if self.last_cycle_user:
            tuser[-1] = self.last_cycle_user

        return tdata, tkeep, tid, tdest, tuser

    def parse(self, tdata, tkeep, tid, tdest, tuser):
        if tdata is None or tkeep is None or tuser is None:
            return
        if len(tdata) != len(tkeep) or len(tdata) != len(tid) or len(tdata) != len(tdest) or len(tdata) != len(tuser):
            raise Exception("Invalid data")

        self.data = []
        self.keep = []
        self.id = []
        self.dest = []
        self.user = []

        if self.B == 0:
            mask = 2**self.WL-1

            for i in range(len(tdata)):
                for j in range(self.M):
                    if tkeep[i] & (1 << j):
                        self.data.append((tdata[i] >> (j*self.WL)) & mask)
                self.keep.append(tkeep[i])
                self.id.append(tid[i])
                self.dest.append(tdest[i])
                self.user.append(tuser[i])
        else:
            for i in range(len(tdata)):
                self.data.append(tdata[i])
                self.keep.append(tkeep[i])
                self.id.append(tid[i])
                self.dest.append(tdest[i])
                self.user.append(tuser[i])

        if self.WL == 8:
            self.data = bytearray(self.data)

        self.last_cycle_user = self.user[-1]

    def __eq__(self, other):
        if not isinstance(other, AXIStreamFrame):
            return False
        if self.data != other.data:
            return False
        if self.keep is not None and other.keep is not None:
            if self.keep != other.keep:
                return False
        if self.id is not None and other.id is not None:
            if type(self.id) in (int, bool) and type(other.id) is list:
                for k in other.id:
                    if self.id != k:
                        return False
            elif type(other.id) in (int, bool) and type(self.id) is list:
                for k in self.id:
                    if other.id != k:
                        return False
            elif self.id != other.id:
                return False
        if self.dest is not None and other.dest is not None:
            if type(self.dest) in (int, bool) and type(other.dest) is list:
                for k in other.dest:
                    if self.dest != k:
                        return False
            elif type(other.dest) in (int, bool) and type(self.dest) is list:
                for k in self.dest:
                    if other.dest != k:
                        return False
            elif self.dest != other.dest:
                return False
        if self.last_cycle_user is not None and other.last_cycle_user is not None:
            if self.last_cycle_user != other.last_cycle_user:
                return False
            if self.user is not None and other.user is not None:
                if type(self.user) in (int, bool) and type(other.user) is list:
                    for k in other.user[:-1]:
                        if self.user != k:
                            return False
                elif type(other.user) in (int, bool) and type(self.user) is list:
                    for k in self.user[:-1]:
                        if other.user != k:
                            return False
                elif self.user != other.user:
                    return False
        else:
            if self.user is not None and other.user is not None:
                if type(self.user) in (int, bool) and type(other.user) is list:
                    for k in other.user:
                        if self.user != k:
                            return False
                elif type(other.user) in (int, bool) and type(self.user) is list:
                    for k in self.user:
                        if other.user != k:
                            return False
                elif self.user != other.user:
                    return False
        return True

    def __repr__(self):
        return (
                ('AXIStreamFrame(data=%s, ' % repr(self.data)) +
                ('keep=%s, ' % repr(self.keep)) +
                ('id=%s, ' % repr(self.id)) +
                ('dest=%s, ' % repr(self.dest)) +
                ('user=%s, ' % repr(self.user)) +
                ('last_cycle_user=%s)' % repr(self.last_cycle_user))
            )

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
        return not self.queue

    def create_logic(self,
                clk,
                rst,
                tdata=None,
                tkeep=Signal(bool(True)),
                tvalid=Signal(bool(False)),
                tready=Signal(bool(True)),
                tlast=Signal(bool(False)),
                tid=Signal(intbv(0)),
                tdest=Signal(intbv(0)),
                tuser=Signal(intbv(0)),
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
            id = []
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
                    tid.next = 0
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
                            tid.next = id.pop(0)
                            tdest.next = dest.pop(0)
                            tuser.next = user.pop(0)
                            tvalid_int.next = True
                            tlast.next = len(data) == 0
                        else:
                            tvalid_int.next = False
                            tlast.next = False
                    if (tlast and tready_int and tvalid) or not tvalid_int:
                        if self.queue:
                            frame = self.queue.pop(0)
                            frame.B = B
                            frame.N = N
                            frame.M = M
                            frame.WL = WL
                            data, keep, id, dest, user = frame.build()
                            if name is not None:
                                print("[%s] Sending frame %s" % (name, repr(frame)))
                            if B > 0:
                                l = data.pop(0)
                                for i in range(B):
                                    tdata[i].next = l[i]
                            else:
                                tdata.next = data.pop(0)
                            tkeep.next = keep.pop(0)
                            tid.next = id.pop(0)
                            tdest.next = dest.pop(0)
                            tuser.next = user.pop(0)
                            tvalid_int.next = True
                            tlast.next = len(data) == 0

        return instances()


class AXIStreamSink(object):
    def __init__(self):
        self.has_logic = False
        self.queue = []
        self.read_queue = []
        self.sync = Signal(intbv(0))

    def recv(self):
        if self.queue:
            return self.queue.pop(0)
        return None

    def read(self, count=-1):
        while self.queue:
            self.read_queue.extend(self.queue.pop(0).data)
        if count < 0:
            count = len(self.read_queue)
        data = self.read_queue[:count]
        del self.read_queue[:count]
        return data

    def count(self):
        return len(self.queue)

    def empty(self):
        return not self.queue

    def wait(self, timeout=0):
        if self.queue:
            return
        if timeout:
            yield self.sync, delay(timeout)
        else:
            yield self.sync

    def create_logic(self,
                clk,
                rst,
                tdata=None,
                tkeep=Signal(bool(True)),
                tvalid=Signal(bool(False)),
                tready=Signal(bool(True)),
                tlast=Signal(bool(True)),
                tid=Signal(intbv(0)),
                tdest=Signal(intbv(0)),
                tuser=Signal(intbv(0)),
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
            id = []
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
                    id = []
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
                        id.append(int(tid))
                        dest.append(int(tdest))
                        user.append(int(tuser))
                        first = False
                        if tlast:
                            frame.B = B
                            frame.N = N
                            frame.M = M
                            frame.WL = WL
                            frame.parse(data, keep, id, dest, user)
                            self.queue.append(frame)
                            self.sync.next = not self.sync
                            if name is not None:
                                print("[%s] Got frame %s" % (name, repr(frame)))
                            frame = AXIStreamFrame()
                            data = []
                            keep = []
                            id = []
                            dest = []
                            user = []
                            first = True

        return instances()


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
import axis_ep
import eth_ep
import struct

class ARPFrame(object):
    def __init__(self,
                eth_dest_mac=0,
                eth_src_mac=0,
                eth_type=0,
                arp_htype=1,
                arp_ptype=0x0800,
                arp_hlen=6,
                arp_plen=4,
                arp_oper=2,
                arp_sha=0x5A5152535455,
                arp_spa=0xc0a80164,
                arp_tha=0xDAD1D2D3D4D5,
                arp_tpa=0xc0a80164
            ):

        self.eth_dest_mac = eth_dest_mac
        self.eth_src_mac = eth_src_mac
        self.eth_type = eth_type
        self.arp_htype = arp_htype
        self.arp_ptype = arp_ptype
        self.arp_hlen = arp_hlen
        self.arp_plen = arp_plen
        self.arp_oper = arp_oper
        self.arp_sha = arp_sha
        self.arp_spa = arp_spa
        self.arp_tha = arp_tha
        self.arp_tpa = arp_tpa

        if type(eth_dest_mac) is dict:
            self.eth_dest_mac = eth_dest_mac['eth_dest_mac']
            self.eth_src_mac = eth_dest_mac['eth_src_mac']
            self.eth_type = eth_dest_mac['eth_type']
            self.arp_htype = eth_dest_mac['arp_htype']
            self.arp_ptype = eth_dest_mac['arp_ptype']
            self.arp_hlen = eth_dest_mac['arp_hlen']
            self.arp_plen = eth_dest_mac['arp_plen']
            self.arp_oper = eth_dest_mac['arp_oper']
            self.arp_sha = eth_dest_mac['arp_sha']
            self.arp_spa = eth_dest_mac['arp_spa']
            self.arp_tha = eth_dest_mac['arp_tha']
            self.arp_tpa = eth_dest_mac['arp_tpa']
        if type(eth_dest_mac) is ARPFrame:
            self.eth_dest_mac = eth_dest_mac.eth_dest_mac
            self.eth_src_mac = eth_dest_mac.eth_src_mac
            self.eth_type = eth_dest_mac.eth_type
            self.arp_htype = eth_dest_mac.arp_htype
            self.arp_ptype = eth_dest_mac.arp_ptype
            self.arp_hlen = eth_dest_mac.arp_hlen
            self.arp_plen = eth_dest_mac.arp_plen
            self.arp_oper = eth_dest_mac.arp_oper
            self.arp_sha = eth_dest_mac.arp_sha
            self.arp_spa = eth_dest_mac.arp_spa
            self.arp_tha = eth_dest_mac.arp_tha
            self.arp_tpa = eth_dest_mac.arp_tpa

    def build_axis(self):
        return self.build_eth().build_axis()

    def build_eth(self):
        data = b''

        data += struct.pack('>H', self.arp_htype)
        data += struct.pack('>H', self.arp_ptype)
        data += struct.pack('B', self.arp_hlen)
        data += struct.pack('B', self.arp_plen)
        data += struct.pack('>H', self.arp_oper)
        data += struct.pack('>Q', self.arp_sha)[2:]
        data += struct.pack('>L', self.arp_spa)
        data += struct.pack('>Q', self.arp_tha)[2:]
        data += struct.pack('>L', self.arp_tpa)

        return eth_ep.EthFrame(data, self.eth_dest_mac, self.eth_src_mac, self.eth_type)

    def parse_axis(self, data):
        frame = eth_ep.EthFrame()
        frame.parse_axis(data)
        self.parse_eth(frame)

    def parse_eth(self, data):
        self.eth_src_mac = data.eth_src_mac
        self.eth_dest_mac = data.eth_dest_mac
        self.eth_type = data.eth_type

        self.arp_htype = struct.unpack('>H', data.payload.data[0:2])[0]
        self.arp_ptype = struct.unpack('>H', data.payload.data[2:4])[0]
        self.arp_hlen = struct.unpack('B', data.payload.data[4:5])[0]
        self.arp_plen = struct.unpack('B', data.payload.data[5:6])[0]
        self.arp_oper = struct.unpack('>H', data.payload.data[6:8])[0]
        self.arp_sha = struct.unpack('>Q', b'\x00\x00'+data.payload.data[8:14])[0]
        self.arp_spa = struct.unpack('>L', data.payload.data[14:18])[0]
        self.arp_tha = struct.unpack('>Q', b'\x00\x00'+data.payload.data[18:24])[0]
        self.arp_tpa = struct.unpack('>L', data.payload.data[24:28])[0]

    def __eq__(self, other):
        if type(other) is ARPFrame:
            return (
                    self.eth_src_mac == other.eth_src_mac and
                    self.eth_dest_mac == other.eth_dest_mac and
                    self.eth_type == other.eth_type and
                    self.arp_htype == other.arp_htype and
                    self.arp_ptype == other.arp_ptype and
                    self.arp_hlen == other.arp_hlen and
                    self.arp_plen == other.arp_plen and
                    self.arp_oper == other.arp_oper and
                    self.arp_sha == other.arp_sha and
                    self.arp_spa == other.arp_spa and
                    self.arp_tha == other.arp_tha and
                    self.arp_tpa == other.arp_tpa
                )
        return False

    def __repr__(self):
        return (
                ('ArpFrame(eth_dest_mac=0x%012x, ' % self.eth_dest_mac) +
                ('eth_src_mac=0x%012x, ' % self.eth_src_mac) +
                ('eth_type=0x%04x, ' % self.eth_type) +
                ('arp_htype=0x%04x, ' % self.arp_htype) +
                ('arp_ptype=0x%04x, ' % self.arp_ptype) +
                ('arp_hlen=%d, ' % self.arp_hlen) +
                ('arp_plen=%d, ' % self.arp_plen) +
                ('arp_oper=0x%04x, ' % self.arp_oper) +
                ('arp_sha=0x%012x, ' % self.arp_sha) +
                ('arp_spa=0x%08x, ' % self.arp_spa) +
                ('arp_tha=0x%012x, ' % self.arp_tha) +
                ('arp_tpa=0x%08x)' % self.arp_tpa)
            )


class ARPFrameSource():
    def __init__(self):
        self.active = False
        self.has_logic = False
        self.queue = []
        self.clk = Signal(bool(0))

    def send(self, frame):
        self.queue.append(ARPFrame(frame))

    def count(self):
        return len(self.queue)

    def empty(self):
        return not self.queue

    def idle(self):
        return not self.queue and not self.active

    def wait(self):
        while not self.idle():
            yield self.clk.posedge

    def create_logic(self,
                clk,
                rst,
                frame_valid=None,
                frame_ready=None,
                eth_dest_mac=Signal(intbv(0)[48:]),
                eth_src_mac=Signal(intbv(0)[48:]),
                eth_type=Signal(intbv(0)[16:]),
                arp_htype=Signal(intbv(0)[16:]),
                arp_ptype=Signal(intbv(0)[16:]),
                arp_hlen=Signal(intbv(6)[8:]),
                arp_plen=Signal(intbv(4)[8:]),
                arp_oper=Signal(intbv(0)[16:]),
                arp_sha=Signal(intbv(0)[48:]),
                arp_spa=Signal(intbv(0)[32:]),
                arp_tha=Signal(intbv(0)[48:]),
                arp_tpa=Signal(intbv(0)[32:]),
                pause=0,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        self.clk = clk

        @instance
        def logic():
            frame = dict()

            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    frame_valid.next = False
                    self.active = False
                else:
                    frame_valid.next = self.active and (frame_valid or not pause)
                    if frame_ready and frame_valid:
                        frame_valid.next = False
                        self.active = False
                    if not self.active and self.queue:
                        frame = self.queue.pop(0)
                        eth_dest_mac.next = frame.eth_dest_mac
                        eth_src_mac.next = frame.eth_src_mac
                        eth_type.next = frame.eth_type
                        arp_htype.next = frame.arp_htype
                        arp_ptype.next = frame.arp_ptype
                        arp_hlen.next = frame.arp_hlen
                        arp_plen.next = frame.arp_plen
                        arp_oper.next = frame.arp_oper
                        arp_sha.next = frame.arp_sha
                        arp_spa.next = frame.arp_spa
                        arp_tha.next = frame.arp_tha
                        arp_tpa.next = frame.arp_tpa

                        if name is not None:
                            print("[%s] Sending frame %s" % (name, repr(frame)))

                        frame_valid.next = not pause
                        self.active = True

        return instances()


class ARPFrameSink():
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
                frame_valid=None,
                frame_ready=None,
                eth_dest_mac=Signal(intbv(0)[48:]),
                eth_src_mac=Signal(intbv(0)[48:]),
                eth_type=Signal(intbv(0)[16:]),
                arp_htype=Signal(intbv(0)[16:]),
                arp_ptype=Signal(intbv(0)[16:]),
                arp_hlen=Signal(intbv(6)[8:]),
                arp_plen=Signal(intbv(4)[8:]),
                arp_oper=Signal(intbv(0)[16:]),
                arp_sha=Signal(intbv(0)[48:]),
                arp_spa=Signal(intbv(0)[32:]),
                arp_tha=Signal(intbv(0)[48:]),
                arp_tpa=Signal(intbv(0)[32:]),
                pause=0,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        frame_ready_int = Signal(bool(False))
        frame_valid_int = Signal(bool(False))

        @always_comb
        def pause_logic():
            frame_ready.next = frame_ready_int and not pause
            frame_valid_int.next = frame_valid and not pause

        @instance
        def logic():
            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    frame_ready_int.next = False
                else:
                    frame_ready_int.next = True

                    if frame_ready_int and frame_valid_int:
                        frame = ARPFrame()
                        frame.eth_dest_mac = int(eth_dest_mac)
                        frame.eth_src_mac = int(eth_src_mac)
                        frame.eth_type = int(eth_type)
                        frame.arp_htype = int(arp_htype)
                        frame.arp_ptype = int(arp_ptype)
                        frame.arp_hlen = int(arp_hlen)
                        frame.arp_plen = int(arp_plen)
                        frame.arp_oper = int(arp_oper)
                        frame.arp_sha = int(arp_sha)
                        frame.arp_spa = int(arp_spa)
                        frame.arp_tha = int(arp_tha)
                        frame.arp_tpa = int(arp_tpa)
                        self.queue.append(frame)
                        self.sync.next = not self.sync

                        if name is not None:
                            print("[%s] Got frame %s" % (name, repr(frame)))

        return instances()


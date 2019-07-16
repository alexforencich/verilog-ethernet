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
import struct
import zlib

class EthFrame(object):
    def __init__(self, payload=b'', eth_dest_mac=0, eth_src_mac=0, eth_type=0, eth_fcs=None):
        self._payload = axis_ep.AXIStreamFrame()
        self.eth_dest_mac = eth_dest_mac
        self.eth_src_mac = eth_src_mac
        self.eth_type = eth_type
        self.eth_fcs = eth_fcs

        if type(payload) is dict:
            self.payload = axis_ep.AXIStreamFrame(payload['eth_payload'])
            self.eth_dest_mac = payload['eth_dest_mac']
            self.eth_src_mac = payload['eth_src_mac']
            self.eth_type = payload['eth_type']
            self.eth_fcs = payload['eth_fcs']
        if type(payload) is bytes:
            payload = bytearray(payload)
        if type(payload) is bytearray or type(payload) is axis_ep.AXIStreamFrame:
            self.payload = axis_ep.AXIStreamFrame(payload)
        if type(payload) is EthFrame:
            self.payload = axis_ep.AXIStreamFrame(payload.payload)
            self.eth_dest_mac = payload.eth_dest_mac
            self.eth_src_mac = payload.eth_src_mac
            self.eth_type = payload.eth_type
            self.eth_fcs = payload.eth_fcs

    @property
    def payload(self):
        return self._payload

    @payload.setter
    def payload(self, value):
        self._payload = axis_ep.AXIStreamFrame(value)

    def calc_fcs(self):
        frame = self.build_axis().data

        return zlib.crc32(bytes(frame)) & 0xffffffff

    def update_fcs(self):
        self.eth_fcs = self.calc_fcs()

    def build_axis(self):
        data = b''

        data += struct.pack('>Q', self.eth_dest_mac)[2:]
        data += struct.pack('>Q', self.eth_src_mac)[2:]
        data += struct.pack('>H', self.eth_type)

        data += self.payload.data

        return axis_ep.AXIStreamFrame(data)

    def build_axis_fcs(self):
        if self.eth_fcs is None:
            self.update_fcs()

        data = self.build_axis().data

        data += struct.pack('<L', self.eth_fcs)

        return axis_ep.AXIStreamFrame(data)

    def parse_axis(self, data):
        data = axis_ep.AXIStreamFrame(data).data
        self.eth_dest_mac = struct.unpack('>Q', b'\x00\x00'+data[0:6])[0]
        self.eth_src_mac = struct.unpack('>Q', b'\x00\x00'+data[6:12])[0]
        self.eth_type = struct.unpack('>H', data[12:14])[0]
        data = data[14:]
        self.payload = axis_ep.AXIStreamFrame(data)

    def parse_axis_fcs(self, data):
        self.parse_axis(data)
        data = self.payload.data
        self.payload = axis_ep.AXIStreamFrame(data[:-4])
        self.eth_fcs = struct.unpack('<L', data[-4:])[0]

    def __eq__(self, other):
        if type(other) is EthFrame:
            return (
                    self.eth_src_mac == other.eth_src_mac and
                    self.eth_dest_mac == other.eth_dest_mac and
                    self.eth_type == other.eth_type and
                    self.payload == other.payload
                )
        return False

    def __repr__(self):
        fcs = 'None'
        if self.eth_fcs is not None:
            fcs = '0x%08x' % self.eth_fcs
        return 'EthFrame(payload=%s, eth_dest_mac=0x%012x, eth_src_mac=0x%012x, eth_type=0x%04x, eth_fcs=%s)' % (repr(self.payload), self.eth_dest_mac, self.eth_src_mac, self.eth_type, fcs)


class EthFrameSource():
    def __init__(self):
        self.active = False
        self.has_logic = False
        self.queue = []
        self.payload_source = axis_ep.AXIStreamSource()
        self.header_queue = []
        self.clk = Signal(bool(0))

    def send(self, frame):
        frame = EthFrame(frame)
        if not self.header_queue:
            self.header_queue.append(frame)
            self.payload_source.send(frame.payload)
        else:
            self.queue.append(frame)

    def count(self):
        return len(self.queue)

    def empty(self):
        return not self.queue

    def idle(self):
        return not self.queue and not self.active and self.payload_source.idle()

    def wait(self):
        while not self.idle():
            yield self.clk.posedge

    def create_logic(self,
                clk,
                rst,
                eth_hdr_valid=None,
                eth_hdr_ready=None,
                eth_dest_mac=Signal(intbv(0)[48:]),
                eth_src_mac=Signal(intbv(0)[48:]),
                eth_type=Signal(intbv(0)[16:]),
                eth_payload_tdata=None,
                eth_payload_tkeep=Signal(bool(True)),
                eth_payload_tvalid=Signal(bool(False)),
                eth_payload_tready=Signal(bool(True)),
                eth_payload_tlast=Signal(bool(False)),
                eth_payload_tuser=Signal(bool(False)),
                pause=0,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        self.clk = clk

        eth_payload_source = self.payload_source.create_logic(
            clk=clk,
            rst=rst,
            tdata=eth_payload_tdata,
            tkeep=eth_payload_tkeep,
            tvalid=eth_payload_tvalid,
            tready=eth_payload_tready,
            tlast=eth_payload_tlast,
            tuser=eth_payload_tuser,
            pause=pause,
        )

        @instance
        def logic():
            frame = EthFrame()

            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    eth_hdr_valid.next = False
                    self.active = False
                else:
                    eth_hdr_valid.next = self.active and (eth_hdr_valid or not pause)
                    if eth_hdr_ready and eth_hdr_valid:
                        eth_hdr_valid.next = False
                        self.active = False
                    if not self.active and self.header_queue:
                        frame = self.header_queue.pop(0)
                        eth_dest_mac.next = frame.eth_dest_mac
                        eth_src_mac.next = frame.eth_src_mac
                        eth_type.next = frame.eth_type

                        if name is not None:
                            print("[%s] Sending frame %s" % (name, repr(frame)))

                        eth_hdr_valid.next = not pause
                        self.active = True

                    if self.queue and not self.header_queue:
                        frame = self.queue.pop(0)
                        self.header_queue.append(frame)
                        self.payload_source.send(frame.payload)

        return instances()


class EthFrameSink():
    def __init__(self):
        self.has_logic = False
        self.queue = []
        self.payload_sink = axis_ep.AXIStreamSink()
        self.header_queue = []
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
                eth_hdr_valid=None,
                eth_hdr_ready=None,
                eth_dest_mac=Signal(intbv(0)[48:]),
                eth_src_mac=Signal(intbv(0)[48:]),
                eth_type=Signal(intbv(0)[16:]),
                eth_payload_tdata=None,
                eth_payload_tkeep=Signal(bool(True)),
                eth_payload_tvalid=Signal(bool(True)),
                eth_payload_tready=Signal(bool(True)),
                eth_payload_tlast=Signal(bool(True)),
                eth_payload_tuser=Signal(bool(False)),
                pause=0,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        eth_hdr_ready_int = Signal(bool(False))
        eth_hdr_valid_int = Signal(bool(False))
        eth_payload_pause = Signal(bool(False))

        eth_payload_sink = self.payload_sink.create_logic(
            clk=clk,
            rst=rst,
            tdata=eth_payload_tdata,
            tkeep=eth_payload_tkeep,
            tvalid=eth_payload_tvalid,
            tready=eth_payload_tready,
            tlast=eth_payload_tlast,
            tuser=eth_payload_tuser,
            pause=eth_payload_pause
        )

        @always_comb
        def pause_logic():
            eth_hdr_ready.next = eth_hdr_ready_int and not pause
            eth_hdr_valid_int.next = eth_hdr_valid and not pause
            eth_payload_pause.next = pause # or eth_hdr_valid_int

        @instance
        def logic():
            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    eth_hdr_ready_int.next = False
                else:
                    eth_hdr_ready_int.next = True

                    if eth_hdr_ready_int and eth_hdr_valid_int:
                        frame = EthFrame()
                        frame.eth_dest_mac = int(eth_dest_mac)
                        frame.eth_src_mac = int(eth_src_mac)
                        frame.eth_type = int(eth_type)
                        self.header_queue.append(frame)

                    if not self.payload_sink.empty() and self.header_queue:
                        frame = self.header_queue.pop(0)
                        frame.payload = self.payload_sink.recv()
                        self.queue.append(frame)
                        self.sync.next = not self.sync

                        if name is not None:
                            print("[%s] Got frame %s" % (name, repr(frame)))

        return instances()


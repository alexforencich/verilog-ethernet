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
import axis_ep
from Queue import Queue
import struct

class EthFrame(object):
    def __init__(self, payload=b'', eth_dest_mac=0, eth_src_mac=0, eth_type=0):
        self._payload = axis_ep.AXIStreamFrame()
        self.eth_dest_mac = eth_dest_mac
        self.eth_src_mac = eth_src_mac
        self.eth_type = eth_type

        if type(payload) is dict:
            self.payload = axis_ep.AXIStreamFrame(payload['eth_payload'])
            self.eth_dest_mac = payload['eth_dest_mac']
            self.eth_src_mac = payload['eth_src_mac']
            self.eth_type = payload['eth_type']
        if type(payload) is bytes:
            payload = bytearray(payload)
        if type(payload) is bytearray or type(payload) is axis_ep.AXIStreamFrame:
            self.payload = axis_ep.AXIStreamFrame(payload)
        if type(payload) is EthFrame:
            self.payload = axis_ep.AXIStreamFrame(payload.payload)
            self.eth_dest_mac = payload.eth_dest_mac
            self.eth_src_mac = payload.eth_src_mac
            self.eth_type = payload.eth_type

    @property
    def payload(self):
        return self._payload

    @payload.setter
    def payload(self, value):
        self._payload = axis_ep.AXIStreamFrame(value)

    def build_axis(self):
        data = b''

        data += struct.pack('>Q', self.eth_dest_mac)[2:]
        data += struct.pack('>Q', self.eth_src_mac)[2:]
        data += struct.pack('>H', self.eth_type)

        data += self.payload.data

        return axis_ep.AXIStreamFrame(data)

    def parse_axis(self, data):
        data = axis_ep.AXIStreamFrame(data).data
        self.eth_dest_mac = struct.unpack('>Q', '\x00\x00'+data[0:6])[0]
        self.eth_src_mac = struct.unpack('>Q', '\x00\x00'+data[6:12])[0]
        self.eth_type = struct.unpack('>H', data[12:14])[0]
        data = data[14:]
        self.payload = axis_ep.AXIStreamFrame(data)

    def __eq__(self, other):
        if type(other) is EthFrame:
            return (self.eth_src_mac == other.eth_src_mac and
                self.eth_dest_mac == other.eth_dest_mac and
                self.eth_type == other.eth_type and
                self.payload == other.payload)

    def __repr__(self):
        return 'EthFrame(payload=%s, eth_dest_mac=0x%012x, eth_src_mac=0x%012x, eth_type=0x%04x)' % (repr(self.payload), self.eth_dest_mac, self.eth_src_mac, self.eth_type)

def EthFrameSource(clk, rst,
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
                   fifo=None,
                   pause=0,
                   name=None):

    eth_hdr_ready_int = Signal(bool(False))
    eth_hdr_valid_int = Signal(bool(False))
    eth_payload_pause = Signal(bool(False))

    eth_payload_fifo = Queue()

    eth_payload_source = axis_ep.AXIStreamSource(clk,
                                                rst,
                                                tdata=eth_payload_tdata,
                                                tkeep=eth_payload_tkeep,
                                                tvalid=eth_payload_tvalid,
                                                tready=eth_payload_tready,
                                                tlast=eth_payload_tlast,
                                                tuser=eth_payload_tuser,
                                                fifo=eth_payload_fifo,
                                                pause=eth_payload_pause)

    @always_comb
    def pause_logic():
        eth_hdr_ready_int.next = eth_hdr_ready and not pause
        eth_hdr_valid.next = eth_hdr_valid_int and not pause
        eth_payload_pause.next = pause # or eth_hdr_valid_int

    @instance
    def logic():
        frame = dict()

        while True:
            yield clk.posedge, rst.posedge

            if rst:
                eth_hdr_valid_int.next = False
            else:
                if eth_hdr_ready_int:
                    eth_hdr_valid_int.next = False
                if (eth_payload_tlast and eth_hdr_ready_int and eth_hdr_valid) or not eth_hdr_valid_int:
                    if not fifo.empty():
                        frame = fifo.get()
                        frame = EthFrame(frame)
                        eth_dest_mac.next = frame.eth_dest_mac
                        eth_src_mac.next = frame.eth_src_mac
                        eth_type.next = frame.eth_type
                        eth_payload_fifo.put(frame.payload)

                        if name is not None:
                            print("[%s] Sending frame %s" % (name, repr(frame)))

                        eth_hdr_valid_int.next = True

    return logic, pause_logic, eth_payload_source


def EthFrameSink(clk, rst,
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
                 fifo=None,
                 pause=0,
                 name=None):

    eth_hdr_ready_int = Signal(bool(False))
    eth_hdr_valid_int = Signal(bool(False))
    eth_payload_pause = Signal(bool(False))

    eth_payload_fifo = Queue()
    eth_header_fifo = Queue()

    eth_payload_sink = axis_ep.AXIStreamSink(clk,
                                            rst,
                                            tdata=eth_payload_tdata,
                                            tkeep=eth_payload_tkeep,
                                            tvalid=eth_payload_tvalid,
                                            tready=eth_payload_tready,
                                            tlast=eth_payload_tlast,
                                            tuser=eth_payload_tuser,
                                            fifo=eth_payload_fifo,
                                            pause=eth_payload_pause)

    @always_comb
    def pause_logic():
        eth_hdr_ready.next = eth_hdr_ready_int and not pause
        eth_hdr_valid_int.next = eth_hdr_valid and not pause
        eth_payload_pause.next = pause # or eth_hdr_valid_int

    @instance
    def logic():
        frame = EthFrame()

        while True:
            yield clk.posedge, rst.posedge

            if rst:
                eth_hdr_ready_int.next = False
                frame = EthFrame()
            else:
                eth_hdr_ready_int.next = True

                if eth_hdr_ready_int and eth_hdr_valid_int:
                    frame = EthFrame()
                    frame.eth_dest_mac = int(eth_dest_mac)
                    frame.eth_src_mac = int(eth_src_mac)
                    frame.eth_type = int(eth_type)
                    eth_header_fifo.put(frame)

                if not eth_payload_fifo.empty() and not eth_header_fifo.empty():
                    frame = eth_header_fifo.get()
                    frame.payload = eth_payload_fifo.get()
                    fifo.put(frame)

                    if name is not None:
                        print("[%s] Got frame %s" % (name, repr(frame)))

                    frame = dict()

    return logic, pause_logic, eth_payload_sink


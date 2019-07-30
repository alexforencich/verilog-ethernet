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
import ip_ep
import struct

class UDPFrame(object):
    def __init__(self,
                payload=b'',
                eth_dest_mac=0,
                eth_src_mac=0,
                eth_type=0,
                ip_version=4,
                ip_ihl=5,
                ip_dscp=0,
                ip_ecn=0,
                ip_length=None,
                ip_identification=0,
                ip_flags=2,
                ip_fragment_offset=0,
                ip_ttl=64,
                ip_protocol=0x11,
                ip_header_checksum=None,
                ip_source_ip=0xc0a80164,
                ip_dest_ip=0xc0a80165,
                udp_source_port=1,
                udp_dest_port=2,
                udp_length=None,
                udp_checksum=None
            ):

        self._payload = axis_ep.AXIStreamFrame()
        self.eth_dest_mac = eth_dest_mac
        self.eth_src_mac = eth_src_mac
        self.eth_type = eth_type
        self.ip_version = ip_version
        self.ip_ihl = ip_ihl
        self.ip_dscp = ip_dscp
        self.ip_ecn = ip_ecn
        self.ip_length = ip_length
        self.ip_identification = ip_identification
        self.ip_flags = ip_flags
        self.ip_fragment_offset = ip_fragment_offset
        self.ip_ttl = ip_ttl
        self.ip_protocol = ip_protocol
        self.ip_header_checksum = ip_header_checksum
        self.ip_source_ip = ip_source_ip
        self.ip_dest_ip = ip_dest_ip
        self.udp_source_port = udp_source_port
        self.udp_dest_port = udp_dest_port
        self.udp_length = udp_length
        self.udp_checksum = udp_checksum

        if type(payload) is dict:
            self.payload = axis_ep.AXIStreamFrame(payload['udp_payload'])
            self.eth_dest_mac = payload['eth_dest_mac']
            self.eth_src_mac = payload['eth_src_mac']
            self.eth_type = payload['eth_type']
            self.ip_version = payload['ip_version']
            self.ip_ihl = payload['ip_ihl']
            self.ip_dscp = payload['ip_dscp']
            self.ip_ecn = payload['ip_ecn']
            self.ip_length = payload['ip_length']
            self.ip_identification = payload['ip_identification']
            self.ip_flags = payload['ip_flags']
            self.ip_fragment_offset = payload['ip_fragment_offset']
            self.ip_ttl = payload['ip_ttl']
            self.ip_protocol = payload['ip_protocol']
            self.ip_header_checksum = payload['ip_header_checksum']
            self.ip_source_ip = payload['ip_source_ip']
            self.ip_dest_ip = payload['ip_dest_ip']
            self.udp_source_port = payload['udp_source_port']
            self.udp_dest_port = payload['udp_dest_port']
            self.udp_length = payload['udp_length']
            self.udp_checksum = payload['udp_checksum']
        if type(payload) is bytes:
            payload = bytearray(payload)
        if type(payload) is bytearray or type(payload) is axis_ep.AXIStreamFrame:
            self.payload = axis_ep.AXIStreamFrame(payload)
        if type(payload) is UDPFrame:
            self.payload = axis_ep.AXIStreamFrame(payload.payload)
            self.eth_dest_mac = payload.eth_dest_mac
            self.eth_src_mac = payload.eth_src_mac
            self.eth_type = payload.eth_type
            self.ip_version = payload.ip_version
            self.ip_ihl = payload.ip_ihl
            self.ip_dscp = payload.ip_dscp
            self.ip_ecn = payload.ip_ecn
            self.ip_length = payload.ip_length
            self.ip_identification = payload.ip_identification
            self.ip_flags = payload.ip_flags
            self.ip_fragment_offset = payload.ip_fragment_offset
            self.ip_ttl = payload.ip_ttl
            self.ip_protocol = payload.ip_protocol
            self.ip_header_checksum = payload.ip_header_checksum
            self.ip_source_ip = payload.ip_source_ip
            self.ip_dest_ip = payload.ip_dest_ip
            self.udp_source_port = payload.udp_source_port
            self.udp_dest_port = payload.udp_dest_port
            self.udp_length = payload.udp_length
            self.udp_checksum = payload.udp_checksum

    @property
    def payload(self):
        return self._payload

    @payload.setter
    def payload(self, value):
        self._payload = axis_ep.AXIStreamFrame(value)

    def update_ip_length(self):
        self.ip_length = self.udp_length + 20

    def update_udp_length(self):
        self.udp_length = len(self.payload.data) + 8

    def update_length(self):
        self.update_udp_length()
        self.update_ip_length()

    def calc_ip_checksum(self):
        cksum = self.ip_version << 12 | self.ip_ihl << 8 | self.ip_dscp << 2 | self.ip_ecn
        cksum += self.ip_length
        cksum += self.ip_identification
        cksum += self.ip_flags << 13 | self.ip_fragment_offset
        cksum += self.ip_ttl << 8 | self.ip_protocol
        cksum += self.ip_source_ip & 0xffff
        cksum += (self.ip_source_ip >> 16) & 0xffff
        cksum += self.ip_dest_ip & 0xffff
        cksum += (self.ip_dest_ip >> 16) & 0xffff
        cksum = (cksum & 0xffff) + (cksum >> 16)
        cksum = (cksum & 0xffff) + (cksum >> 16)
        return ~cksum & 0xffff

    def update_ip_checksum(self):
        self.ip_header_checksum = self.calc_ip_checksum()

    def verify_ip_checksum(self):
        return self.ip_header_checksum == self.calc_ip_checksum()

    def calc_udp_pseudo_header_checksum(self):
        cksum = self.ip_source_ip & 0xffff
        cksum += (self.ip_source_ip >> 16) & 0xffff
        cksum += self.ip_dest_ip & 0xffff
        cksum += (self.ip_dest_ip >> 16) & 0xffff
        cksum += self.ip_protocol
        cksum += self.udp_length
        cksum = (cksum & 0xffff) + (cksum >> 16)
        cksum = (cksum & 0xffff) + (cksum >> 16)
        return cksum

    def set_udp_pseudo_header_checksum(self):
        if self.udp_length is None:
            self.update_udp_length()
        self.udp_checksum = self.calc_udp_pseudo_header_checksum()

    def calc_udp_checksum(self):
        cksum = self.calc_udp_pseudo_header_checksum()
        cksum += self.udp_source_port
        cksum += self.udp_dest_port
        cksum += self.udp_length
        odd = False
        for d in self.payload.data:
            if odd:
                cksum += d
            else:
                cksum += d << 8
            odd = not odd
        cksum = (cksum & 0xffff) + (cksum >> 16)
        cksum = (cksum & 0xffff) + (cksum >> 16)
        return ~cksum & 0xffff

    def update_udp_checksum(self):
        if self.udp_length is None:
            self.update_udp_length()
        self.udp_checksum = self.calc_udp_checksum()

    def verify_udp_checksum(self):
        return self.udp_checksum == self.calc_udp_checksum()

    def update_checksum(self):
        self.update_udp_checksum()
        self.update_ip_checksum()

    def verify_checksums(self):
        return self.verify_ip_checksum() and self.verify_udp_checksum()

    def build(self):
        if self.udp_length is None:
            self.update_udp_length()
        if self.udp_checksum is None:
            self.update_udp_checksum()
        if self.ip_length is None:
            self.update_ip_length()
        if self.ip_header_checksum is None:
            self.update_ip_checksum()

    def build_axis(self):
        return self.build_eth().build_axis()

    def build_eth(self):
        return self.build_ip().build_eth()

    def build_ip(self):
        self.build()
        data = b''

        data += struct.pack('>H', self.udp_source_port)
        data += struct.pack('>H', self.udp_dest_port)
        data += struct.pack('>H', self.udp_length)
        data += struct.pack('>H', self.udp_checksum)

        data += self.payload.data

        return ip_ep.IPFrame(
                data,
                self.eth_dest_mac,
                self.eth_src_mac,
                self.eth_type,
                self.ip_version,
                self.ip_ihl,
                self.ip_dscp,
                self.ip_ecn,
                self.ip_length,
                self.ip_identification,
                self.ip_flags,
                self.ip_fragment_offset,
                self.ip_ttl,
                self.ip_protocol,
                self.ip_header_checksum,
                self.ip_source_ip,
                self.ip_dest_ip
            )

    def parse_axis(self, data):
        frame = eth_ep.EthFrame()
        frame.parse_axis(data)
        self.parse_eth(frame)

    def parse_eth(self, data):
        frame = ip_ep.IPFrame()
        frame.parse_eth(data)
        self.parse_ip(frame)

    def parse_ip(self, data):
        self.eth_src_mac = data.eth_src_mac
        self.eth_dest_mac = data.eth_dest_mac
        self.eth_type = data.eth_type
        self.ip_version = data.ip_version
        self.ip_ihl = data.ip_ihl
        self.ip_dscp = data.ip_dscp
        self.ip_ecn = data.ip_ecn
        self.ip_length = data.ip_length
        self.ip_identification = data.ip_identification
        self.ip_flags = data.ip_flags
        self.ip_fragment_offset = data.ip_fragment_offset
        self.ip_ttl = data.ip_ttl
        self.ip_protocol = data.ip_protocol
        self.ip_header_checksum = data.ip_header_checksum
        self.ip_source_ip = data.ip_source_ip
        self.ip_dest_ip = data.ip_dest_ip

        self.udp_source_port = struct.unpack('>H', data.payload.data[0:2])[0]
        self.udp_dest_port = struct.unpack('>H', data.payload.data[2:4])[0]
        self.udp_length = struct.unpack('>H', data.payload.data[4:6])[0]
        self.udp_checksum = struct.unpack('>H', data.payload.data[6:8])[0]

        self.payload = axis_ep.AXIStreamFrame(data.payload.data[8:self.udp_length])

    def __eq__(self, other):
        if type(other) is UDPFrame:
            return (
                    self.eth_src_mac == other.eth_src_mac and
                    self.eth_dest_mac == other.eth_dest_mac and
                    self.eth_type == other.eth_type and
                    self.ip_version == other.ip_version and
                    self.ip_ihl == other.ip_ihl and
                    self.ip_dscp == other.ip_dscp and
                    self.ip_ecn == other.ip_ecn and
                    self.ip_length == other.ip_length and
                    self.ip_identification == other.ip_identification and
                    self.ip_flags == other.ip_flags and
                    self.ip_fragment_offset == other.ip_fragment_offset and
                    self.ip_ttl == other.ip_ttl and
                    self.ip_protocol == other.ip_protocol and
                    self.ip_header_checksum == other.ip_header_checksum and
                    self.ip_source_ip == other.ip_source_ip and
                    self.ip_dest_ip == other.ip_dest_ip and
                    self.udp_source_port == other.udp_source_port and
                    self.udp_dest_port == other.udp_dest_port and
                    self.udp_length == other.udp_length and
                    self.udp_checksum == other.udp_checksum and
                    self.payload == other.payload
                )
        return False

    def __repr__(self):
        return (
                ('UDPFrame(payload=%s, ' % repr(self.payload)) +
                ('eth_dest_mac=0x%012x, ' % self.eth_dest_mac) +
                ('eth_src_mac=0x%012x, ' % self.eth_src_mac) +
                ('eth_type=0x%04x, ' % self.eth_type) +
                ('ip_version=%d, ' % self.ip_version) +
                ('ip_ihl=%d, ' % self.ip_ihl) +
                ('ip_dscp=%d, ' % self.ip_dscp) +
                ('ip_ecn=%d, ' % self.ip_ecn) +
                ('ip_length=%d, ' % self.ip_length) +
                ('ip_identification=%d, ' % self.ip_identification) +
                ('ip_flags=%d, ' % self.ip_flags) +
                ('ip_fragment_offset=%d, ' % self.ip_fragment_offset) +
                ('ip_ttl=%d, ' % self.ip_ttl) +
                ('ip_protocol=0x%02x, ' % self.ip_protocol) +
                ('ip_header_checksum=0x%x, ' % self.ip_header_checksum) +
                ('ip_source_ip=0x%08x, ' % self.ip_source_ip) +
                ('ip_dest_ip=0x%08x, ' % self.ip_dest_ip) +
                ('udp_source_port=%d, ' % self.udp_source_port) +
                ('udp_dest_port=%d, ' % self.udp_dest_port) +
                ('udp_length=%d, ' % self.udp_length) +
                ('udp_checksum=0x%04x)' % self.udp_checksum)
            )


class UDPFrameSource():
    def __init__(self):
        self.active = False
        self.has_logic = False
        self.queue = []
        self.payload_source = axis_ep.AXIStreamSource()
        self.header_queue = []
        self.clk = Signal(bool(0))

    def send(self, frame):
        frame = UDPFrame(frame)
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
                udp_hdr_valid=None,
                udp_hdr_ready=None,
                eth_dest_mac=Signal(intbv(0)[48:]),
                eth_src_mac=Signal(intbv(0)[48:]),
                eth_type=Signal(intbv(0)[16:]),
                ip_version=Signal(intbv(4)[4:]),
                ip_ihl=Signal(intbv(5)[4:]),
                ip_dscp=Signal(intbv(0)[6:]),
                ip_ecn=Signal(intbv(0)[2:]),
                ip_length=Signal(intbv(0)[16:]),
                ip_identification=Signal(intbv(0)[16:]),
                ip_flags=Signal(intbv(0)[3:]),
                ip_fragment_offset=Signal(intbv(0)[13:]),
                ip_ttl=Signal(intbv(0)[8:]),
                ip_protocol=Signal(intbv(0)[8:]),
                ip_header_checksum=Signal(intbv(0)[16:]),
                ip_source_ip=Signal(intbv(0)[32:]),
                ip_dest_ip=Signal(intbv(0)[32:]),
                udp_source_port=(intbv(0)[16:]),
                udp_dest_port=(intbv(0)[16:]),
                udp_length=(intbv(0)[16:]),
                udp_checksum=(intbv(0)[16:]),
                udp_payload_tdata=None,
                udp_payload_tkeep=Signal(bool(True)),
                udp_payload_tvalid=Signal(bool(False)),
                udp_payload_tready=Signal(bool(True)),
                udp_payload_tlast=Signal(bool(False)),
                udp_payload_tuser=Signal(bool(False)),
                pause=0,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        self.clk = clk

        udp_payload_source = self.payload_source.create_logic(
            clk=clk,
            rst=rst,
            tdata=udp_payload_tdata,
            tkeep=udp_payload_tkeep,
            tvalid=udp_payload_tvalid,
            tready=udp_payload_tready,
            tlast=udp_payload_tlast,
            tuser=udp_payload_tuser,
            pause=pause,
        )

        @instance
        def logic():
            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    udp_hdr_valid.next = False
                    self.active = False
                else:
                    udp_hdr_valid.next = self.active and (udp_hdr_valid or not pause)
                    if udp_hdr_ready and udp_hdr_valid:
                        udp_hdr_valid.next = False
                        self.active = False
                    if not self.active and self.header_queue:
                        frame = self.header_queue.pop(0)
                        frame.build()
                        eth_dest_mac.next = frame.eth_dest_mac
                        eth_src_mac.next = frame.eth_src_mac
                        eth_type.next = frame.eth_type
                        ip_version.next = frame.ip_version
                        ip_ihl.next = frame.ip_ihl
                        ip_dscp.next = frame.ip_dscp
                        ip_ecn.next = frame.ip_ecn
                        ip_length.next = frame.ip_length
                        ip_identification.next = frame.ip_identification
                        ip_flags.next = frame.ip_flags
                        ip_fragment_offset.next = frame.ip_fragment_offset
                        ip_ttl.next = frame.ip_ttl
                        ip_protocol.next = frame.ip_protocol
                        ip_header_checksum.next = frame.ip_header_checksum
                        ip_source_ip.next = frame.ip_source_ip
                        ip_dest_ip.next = frame.ip_dest_ip
                        udp_source_port.next = frame.udp_source_port
                        udp_dest_port.next = frame.udp_dest_port
                        udp_length.next = frame.udp_length
                        udp_checksum.next = frame.udp_checksum

                        if name is not None:
                            print("[%s] Sending frame %s" % (name, repr(frame)))

                        udp_hdr_valid.next = not pause
                        self.active = True

                    if self.queue and not self.header_queue:
                        frame = self.queue.pop(0)
                        self.header_queue.append(frame)
                        self.payload_source.send(frame.payload)

        return instances()


class UDPFrameSink():
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
                udp_hdr_valid=None,
                udp_hdr_ready=None,
                eth_dest_mac=Signal(intbv(0)[48:]),
                eth_src_mac=Signal(intbv(0)[48:]),
                eth_type=Signal(intbv(0)[16:]),
                ip_version=Signal(intbv(4)[4:]),
                ip_ihl=Signal(intbv(5)[4:]),
                ip_dscp=Signal(intbv(0)[6:]),
                ip_ecn=Signal(intbv(0)[2:]),
                ip_length=Signal(intbv(0)[16:]),
                ip_identification=Signal(intbv(0)[16:]),
                ip_flags=Signal(intbv(0)[3:]),
                ip_fragment_offset=Signal(intbv(0)[13:]),
                ip_ttl=Signal(intbv(0)[8:]),
                ip_protocol=Signal(intbv(0)[8:]),
                ip_header_checksum=Signal(intbv(0)[16:]),
                ip_source_ip=Signal(intbv(0)[32:]),
                ip_dest_ip=Signal(intbv(0)[32:]),
                udp_source_port=(intbv(0)[16:]),
                udp_dest_port=(intbv(0)[16:]),
                udp_length=(intbv(0)[16:]),
                udp_checksum=(intbv(0)[16:]),
                udp_payload_tdata=None,
                udp_payload_tkeep=Signal(bool(True)),
                udp_payload_tvalid=Signal(bool(True)),
                udp_payload_tready=Signal(bool(True)),
                udp_payload_tlast=Signal(bool(True)),
                udp_payload_tuser=Signal(bool(False)),
                pause=0,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        udp_hdr_ready_int = Signal(bool(False))
        udp_hdr_valid_int = Signal(bool(False))
        udp_payload_pause = Signal(bool(False))

        udp_payload_sink = self.payload_sink.create_logic(
            clk=clk,
            rst=rst,
            tdata=udp_payload_tdata,
            tkeep=udp_payload_tkeep,
            tvalid=udp_payload_tvalid,
            tready=udp_payload_tready,
            tlast=udp_payload_tlast,
            tuser=udp_payload_tuser,
            pause=udp_payload_pause
        )

        @always_comb
        def pause_logic():
            udp_hdr_ready.next = udp_hdr_ready_int and not pause
            udp_hdr_valid_int.next = udp_hdr_valid and not pause
            udp_payload_pause.next = pause # or udp_hdr_valid_int

        @instance
        def logic():
            while True:
                yield clk.posedge, rst.posedge

                if rst:
                    udp_hdr_ready_int.next = False
                    frame = UDPFrame()
                else:
                    udp_hdr_ready_int.next = True

                    if udp_hdr_ready_int and udp_hdr_valid_int:
                        frame = UDPFrame()
                        frame.eth_dest_mac = int(eth_dest_mac)
                        frame.eth_src_mac = int(eth_src_mac)
                        frame.eth_type = int(eth_type)
                        frame.ip_version = int(ip_version)
                        frame.ip_ihl = int(ip_ihl)
                        frame.ip_dscp = int(ip_dscp)
                        frame.ip_ecn = int(ip_ecn)
                        frame.ip_length = int(ip_length)
                        frame.ip_identification = int(ip_identification)
                        frame.ip_flags = int(ip_flags)
                        frame.ip_fragment_offset = int(ip_fragment_offset)
                        frame.ip_ttl = int(ip_ttl)
                        frame.ip_protocol = int(ip_protocol)
                        frame.ip_header_checksum = int(ip_header_checksum)
                        frame.ip_source_ip = int(ip_source_ip)
                        frame.ip_dest_ip = int(ip_dest_ip)
                        frame.udp_source_port = int(udp_source_port)
                        frame.udp_dest_port = int(udp_dest_port)
                        frame.udp_length = int(udp_length)
                        frame.udp_checksum = int(udp_checksum)
                        self.header_queue.append(frame)

                    if not self.payload_sink.empty() and self.header_queue:
                        frame = self.header_queue.pop(0)
                        frame.payload = self.payload_sink.recv()
                        self.queue.append(frame)
                        self.sync.next = not self.sync

                        if name is not None:
                            print("[%s] Got frame %s" % (name, repr(frame)))

                        # ensure all payloads have been matched to headers
                        if len(self.header_queue) == 0:
                            assert self.payload_sink.empty()

        return instances()


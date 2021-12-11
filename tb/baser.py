"""

Copyright (c) 2021 Alex Forencich

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

import cocotb
from cocotb.queue import Queue, QueueFull
from cocotb.triggers import RisingEdge, Timer, First, Event
from cocotb.utils import get_sim_time

from cocotbext.eth.constants import (EthPre, XgmiiCtrl, BaseRCtrl, BaseRO,
    BaseRSync, BaseRBlockType, xgmii_ctrl_to_baser_mapping,
    baser_ctrl_to_xgmii_mapping, block_type_term_lane_mapping)
from cocotbext.eth import XgmiiFrame


class BaseRSerdesSource():

    def __init__(self, data, header, clock, enable=None, slip=None, scramble=True, reverse=False, *args, **kwargs):
        self.log = logging.getLogger(f"cocotb.{data._path}")
        self.data = data
        self.header = header
        self.clock = clock
        self.enable = enable
        self.slip = slip
        self.scramble = scramble
        self.reverse = reverse

        self.log.info("BASE-R serdes source")
        self.log.info("Copyright (c) 2021 Alex Forencich")
        self.log.info("https://github.com/alexforencich/verilog-ethernet")

        super().__init__(*args, **kwargs)

        self.active = False
        self.queue = Queue()
        self.dequeue_event = Event()
        self.current_frame = None
        self.idle_event = Event()
        self.idle_event.set()

        self.enable_dic = True
        self.ifg = 12
        self.force_offset_start = False

        self.bit_offset = 0

        self.queue_occupancy_bytes = 0
        self.queue_occupancy_frames = 0

        self.queue_occupancy_limit_bytes = -1
        self.queue_occupancy_limit_frames = -1

        self.width = len(self.data)
        self.byte_size = 8
        self.byte_lanes = 8

        assert self.width == self.byte_lanes * self.byte_size

        self.log.info("BASE-R serdes source model configuration")
        self.log.info("  Byte size: %d bits", self.byte_size)
        self.log.info("  Data width: %d bits (%d bytes)", self.width, self.byte_lanes)
        self.log.info("  Enable scrambler: %s", self.scramble)
        self.log.info("  Bit reverse: %s", self.reverse)

        self.data.setimmediatevalue(0)
        self.header.setimmediatevalue(0)

        self._run_cr = cocotb.start_soon(self._run())

    async def send(self, frame):
        while self.full():
            self.dequeue_event.clear()
            await self.dequeue_event.wait()
        frame = XgmiiFrame(frame)
        await self.queue.put(frame)
        self.idle_event.clear()
        self.queue_occupancy_bytes += len(frame)
        self.queue_occupancy_frames += 1

    def send_nowait(self, frame):
        if self.full():
            raise QueueFull()
        frame = XgmiiFrame(frame)
        self.queue.put_nowait(frame)
        self.idle_event.clear()
        self.queue_occupancy_bytes += len(frame)
        self.queue_occupancy_frames += 1

    def count(self):
        return self.queue.qsize()

    def empty(self):
        return self.queue.empty()

    def full(self):
        if self.queue_occupancy_limit_bytes > 0 and self.queue_occupancy_bytes > self.queue_occupancy_limit_bytes:
            return True
        elif self.queue_occupancy_limit_frames > 0 and self.queue_occupancy_frames > self.queue_occupancy_limit_frames:
            return True
        else:
            return False

    def idle(self):
        return self.empty() and not self.active

    def clear(self):
        while not self.queue.empty():
            frame = self.queue.get_nowait()
            frame.sim_time_end = None
            frame.handle_tx_complete()
        self.dequeue_event.set()
        self.idle_event.set()
        self.queue_occupancy_bytes = 0
        self.queue_occupancy_frames = 0

    async def wait(self):
        await self.idle_event.wait()

    async def _run(self):
        frame = None
        frame_offset = 0
        ifg_cnt = 0
        deficit_idle_cnt = 0
        scrambler_state = 0
        last_d = 0
        self.active = False

        while True:
            await RisingEdge(self.clock)

            if self.enable is None or self.enable.value:
                if ifg_cnt + deficit_idle_cnt > self.byte_lanes-1 or (not self.enable_dic and ifg_cnt > 4):
                    # in IFG
                    ifg_cnt = ifg_cnt - self.byte_lanes
                    if ifg_cnt < 0:
                        if self.enable_dic:
                            deficit_idle_cnt = max(deficit_idle_cnt+ifg_cnt, 0)
                        ifg_cnt = 0

                elif frame is None:
                    # idle
                    if not self.queue.empty():
                        # send frame
                        frame = self.queue.get_nowait()
                        self.dequeue_event.set()
                        self.queue_occupancy_bytes -= len(frame)
                        self.queue_occupancy_frames -= 1
                        self.current_frame = frame
                        frame.sim_time_start = get_sim_time()
                        frame.sim_time_sfd = None
                        frame.sim_time_end = None
                        self.log.info("TX frame: %s", frame)
                        frame.normalize()
                        frame.start_lane = 0
                        assert frame.data[0] == EthPre.PRE
                        assert frame.ctrl[0] == 0
                        frame.data[0] = XgmiiCtrl.START
                        frame.ctrl[0] = 1
                        frame.data.append(XgmiiCtrl.TERM)
                        frame.ctrl.append(1)

                        # offset start
                        if self.enable_dic:
                            min_ifg = 3 - deficit_idle_cnt
                        else:
                            min_ifg = 0

                        if self.byte_lanes > 4 and (ifg_cnt > min_ifg or self.force_offset_start):
                            ifg_cnt = ifg_cnt-4
                            frame.start_lane = 4
                            frame.data = bytearray([XgmiiCtrl.IDLE]*4)+frame.data
                            frame.ctrl = [1]*4+frame.ctrl

                        if self.enable_dic:
                            deficit_idle_cnt = max(deficit_idle_cnt+ifg_cnt, 0)
                        ifg_cnt = 0
                        self.active = True
                        frame_offset = 0
                    else:
                        # clear counters
                        deficit_idle_cnt = 0
                        ifg_cnt = 0

                if frame is not None:
                    dl = bytearray()
                    cl = []

                    for k in range(self.byte_lanes):
                        if frame is not None:
                            d = frame.data[frame_offset]
                            if frame.sim_time_sfd is None and d == EthPre.SFD:
                                frame.sim_time_sfd = get_sim_time()
                            dl.append(d)
                            cl.append(frame.ctrl[frame_offset])
                            frame_offset += 1

                            if frame_offset >= len(frame.data):
                                ifg_cnt = max(self.ifg - (self.byte_lanes-k), 0)
                                frame.sim_time_end = get_sim_time()
                                frame.handle_tx_complete()
                                frame = None
                                self.current_frame = None
                        else:
                            dl.append(XgmiiCtrl.IDLE)
                            cl.append(1)

                    # remap control characters
                    ctrl = sum(xgmii_ctrl_to_baser_mapping.get(d, BaseRCtrl.ERROR) << i*7 for i, d in enumerate(dl))

                    if not any(cl):
                        # data
                        header = BaseRSync.DATA
                        data = int.from_bytes(dl, 'little')
                    else:
                        # control
                        header = BaseRSync.CTRL
                        if cl[0] and dl[0] == XgmiiCtrl.START and not any(cl[1:]):
                            # start in lane 0
                            data = BaseRBlockType.START_0
                            for i in range(1, 8):
                                data |= dl[i] << i*8
                        elif cl[4] and dl[4] == XgmiiCtrl.START and not any(cl[5:]):
                            # start in lane 4
                            if cl[0] and (dl[0] == XgmiiCtrl.SEQ_OS or dl[0] == XgmiiCtrl.SIG_OS) and not any(cl[1:4]):
                                # ordered set in lane 0
                                data = BaseRBlockType.OS_START
                                for i in range(1, 4):
                                    data |= dl[i] << i*8
                                if dl[0] == XgmiiCtrl.SIG_OS:
                                    # signal ordered set
                                    data |= BaseRO.SIG_OS << 32
                            else:
                                # other control
                                data = BaseRBlockType.START_4 | (ctrl & 0xfffffff) << 8

                            for i in range(5, 8):
                                data |= dl[i] << i*8
                        elif cl[0] and (dl[0] == XgmiiCtrl.SEQ_OS or dl[0] == XgmiiCtrl.SIG_OS) and not any(cl[1:4]):
                            # ordered set in lane 0
                            if cl[4] and (dl[4] == XgmiiCtrl.SEQ_OS or dl[4] == XgmiiCtrl.SIG_OS) and not any(cl[5:8]):
                                # ordered set in lane 4
                                data = BaseRBlockType.OS_04
                                for i in range(5, 8):
                                    data |= dl[i] << i*8
                                if dl[4] == XgmiiCtrl.SIG_OS:
                                    # signal ordered set
                                    data |= BaseRO.SIG_OS << 36
                            else:
                                data = BaseRBlockType.OS_0 | (ctrl & 0xfffffff) << 40
                            for i in range(1, 4):
                                data |= dl[i] << i*8
                            if dl[0] == XgmiiCtrl.SIG_OS:
                                # signal ordered set
                                data |= BaseRO.SIG_OS << 32
                        elif cl[4] and (dl[4] == XgmiiCtrl.SEQ_OS or dl[4] == XgmiiCtrl.SIG_OS) and not any(cl[5:8]):
                            # ordered set in lane 4
                            data = BaseRBlockType.OS_4 | (ctrl & 0xfffffff) << 8
                            for i in range(5, 8):
                                data |= dl[i] << i*8
                            if dl[4] == XgmiiCtrl.SIG_OS:
                                # signal ordered set
                                data |= BaseRO.SIG_OS << 36
                        elif cl[0] and dl[0] == XgmiiCtrl.TERM:
                            # terminate in lane 0
                            data = BaseRBlockType.TERM_0 | (ctrl & 0xffffffffffff80) << 8
                        elif cl[1] and dl[1] == XgmiiCtrl.TERM and not cl[0]:
                            # terminate in lane 1
                            data = BaseRBlockType.TERM_1 | (ctrl & 0xffffffffffc000) << 8 | dl[0] << 8
                        elif cl[2] and dl[2] == XgmiiCtrl.TERM and not any(cl[0:2]):
                            # terminate in lane 2
                            data = BaseRBlockType.TERM_2 | (ctrl & 0xffffffffe00000) << 8
                            for i in range(2):
                                data |= dl[i] << ((i+1)*8)
                        elif cl[3] and dl[3] == XgmiiCtrl.TERM and not any(cl[0:3]):
                            # terminate in lane 3
                            data = BaseRBlockType.TERM_3 | (ctrl & 0xfffffff0000000) << 8
                            for i in range(3):
                                data |= dl[i] << ((i+1)*8)
                        elif cl[4] and dl[4] == XgmiiCtrl.TERM and not any(cl[0:4]):
                            # terminate in lane 4
                            data = BaseRBlockType.TERM_4 | (ctrl & 0xfffff800000000) << 8
                            for i in range(4):
                                data |= dl[i] << ((i+1)*8)
                        elif cl[5] and dl[5] == XgmiiCtrl.TERM and not any(cl[0:5]):
                            # terminate in lane 5
                            data = BaseRBlockType.TERM_5 | (ctrl & 0xfffc0000000000) << 8
                            for i in range(5):
                                data |= dl[i] << ((i+1)*8)
                        elif cl[6] and dl[6] == XgmiiCtrl.TERM and not any(cl[0:6]):
                            # terminate in lane 6
                            data = BaseRBlockType.TERM_6 | (ctrl & 0xfe000000000000) << 8
                            for i in range(6):
                                data |= dl[i] << ((i+1)*8)
                        elif cl[7] and dl[7] == XgmiiCtrl.TERM and not any(cl[0:7]):
                            # terminate in lane 7
                            data = BaseRBlockType.TERM_7
                            for i in range(7):
                                data |= dl[i] << ((i+1)*8)
                        else:
                            # all control
                            data = BaseRBlockType.CTRL | ctrl << 8
                else:
                    data = BaseRBlockType.CTRL
                    header = BaseRSync.CTRL
                    self.active = False
                    self.idle_event.set()

                if self.scramble:
                    # 64b/66b scrambler
                    b = 0
                    for i in range(len(self.data)):
                        if bool(scrambler_state & (1 << 38)) ^ bool(scrambler_state & (1 << 57)) ^ bool(data & (1 << i)):
                            scrambler_state = ((scrambler_state & 0x1ffffffffffffff) << 1) | 1
                            b = b | (1 << i)
                        else:
                            scrambler_state = (scrambler_state & 0x1ffffffffffffff) << 1
                    data = b

                if self.slip is not None and self.slip.value:
                    self.bit_offset += 1

                self.bit_offset = max(0, self.bit_offset) % 66

                if self.bit_offset != 0:
                    d = data << 2 | header

                    out_d = ((last_d | d << 66) >> 66-self.bit_offset) & 0x3ffffffffffffffff

                    last_d = d

                    data = out_d >> 2
                    header = out_d & 3

                if self.reverse:
                    # bit reverse
                    data = sum(1 << (63-i) for i in range(64) if (data >> i) & 1)
                    header = sum(1 << (1-i) for i in range(2) if (header >> i) & 1)

                self.data <= data
                self.header <= header


class BaseRSerdesSink:

    def __init__(self, data, header, clock, enable=None, scramble=True, reverse=False, *args, **kwargs):
        self.log = logging.getLogger(f"cocotb.{data._path}")
        self.data = data
        self.header = header
        self.clock = clock
        self.enable = enable
        self.scramble = scramble
        self.reverse = reverse

        self.log.info("BASE-R serdes sink")
        self.log.info("Copyright (c) 2021 Alex Forencich")
        self.log.info("https://github.com/alexforencich/verilog-ethernet")

        super().__init__(*args, **kwargs)

        self.active = False
        self.queue = Queue()
        self.active_event = Event()

        self.queue_occupancy_bytes = 0
        self.queue_occupancy_frames = 0

        self.width = len(self.data)
        self.byte_size = 8
        self.byte_lanes = 8

        assert self.width == self.byte_lanes * self.byte_size

        self.log.info("BASE-R serdes sink model configuration")
        self.log.info("  Byte size: %d bits", self.byte_size)
        self.log.info("  Data width: %d bits (%d bytes)", self.width, self.byte_lanes)
        self.log.info("  Enable scrambler: %s", self.scramble)
        self.log.info("  Bit reverse: %s", self.reverse)

        self._run_cr = cocotb.start_soon(self._run())

    def _recv(self, frame, compact=True):
        if self.queue.empty():
            self.active_event.clear()
        self.queue_occupancy_bytes -= len(frame)
        self.queue_occupancy_frames -= 1
        if compact:
            frame.compact()
        return frame

    async def recv(self, compact=True):
        frame = await self.queue.get()
        return self._recv(frame, compact)

    def recv_nowait(self, compact=True):
        frame = self.queue.get_nowait()
        return self._recv(frame, compact)

    def count(self):
        return self.queue.qsize()

    def empty(self):
        return self.queue.empty()

    def idle(self):
        return not self.active

    def clear(self):
        while not self.queue.empty():
            self.queue.get_nowait()
        self.active_event.clear()
        self.queue_occupancy_bytes = 0
        self.queue_occupancy_frames = 0

    async def wait(self, timeout=0, timeout_unit=None):
        if not self.empty():
            return
        if timeout:
            await First(self.active_event.wait(), Timer(timeout, timeout_unit))
        else:
            await self.active_event.wait()

    async def _run(self):
        frame = None
        scrambler_state = 0
        self.active = False

        while True:
            await RisingEdge(self.clock)

            if self.enable is None or self.enable.value:
                data = self.data.value.integer
                header = self.header.value.integer

                if self.reverse:
                    # bit reverse
                    data = sum(1 << (63-i) for i in range(64) if (data >> i) & 1)
                    header = sum(1 << (1-i) for i in range(2) if (header >> i) & 1)

                if self.scramble:
                    # 64b/66b descrambler
                    b = 0
                    for i in range(len(self.data)):
                        if bool(scrambler_state & (1 << 38)) ^ bool(scrambler_state & (1 << 57)) ^ bool(data & (1 << i)):
                            b = b | (1 << i)
                        scrambler_state = (scrambler_state & 0x1ffffffffffffff) << 1 | bool(data & (1 << i))
                    data = b

                # 10GBASE-R decoding

                # remap control characters
                ctrl = bytearray(baser_ctrl_to_xgmii_mapping.get((data >> i*7+8) & 0x7f, XgmiiCtrl.ERROR) for i in range(8))

                data = data.to_bytes(8, 'little')

                dl = bytearray()
                cl = []
                if header == BaseRSync.DATA:
                    # data
                    dl = data
                    cl = [0]*8
                elif header == BaseRSync.CTRL:
                    if data[0] == BaseRBlockType.CTRL:
                        # C7 C6 C5 C4 C3 C2 C1 C0 BT
                        dl = ctrl
                        cl = [1]*8
                    elif data[0] == BaseRBlockType.OS_4:
                        # D7 D6 D5 O4 C3 C2 C1 C0 BT
                        dl = ctrl[0:4]
                        cl = [1]*4
                        if (data[4] >> 4) & 0xf == BaseRO.SEQ_OS:
                            dl.append(XgmiiCtrl.SEQ_OS)
                        elif (data[4] >> 4) & 0xf == BaseRO.SIG_OS:
                            dl.append(XgmiiCtrl.SIG_OS)
                        else:
                            dl.append(XgmiiCtrl.ERROR)
                        cl.append(1)
                        dl += data[5:]
                        cl += [0]*3
                    elif data[0] == BaseRBlockType.START_4:
                        # D7 D6 D5    C3 C2 C1 C0 BT
                        dl = ctrl[0:4]
                        cl = [1]*4
                        dl.append(XgmiiCtrl.START)
                        cl.append(1)
                        dl += data[5:]
                        cl += [0]*3
                    elif data[0] == BaseRBlockType.OS_START:
                        # D7 D6 D5    O0 D3 D2 D1 BT
                        if data[4] & 0xf == BaseRO.SEQ_OS:
                            dl.append(XgmiiCtrl.SEQ_OS)
                        elif data[4] & 0xf == BaseRO.SIG_OS:
                            dl.append(XgmiiCtrl.SIG_OS)
                        else:
                            dl.append(XgmiiCtrl.ERROR)
                        cl.append(1)
                        dl += data[1:4]
                        cl += [0]*3
                        dl.append(XgmiiCtrl.START)
                        cl.append(1)
                        dl += data[5:]
                        cl += [0]*3
                    elif data[0] == BaseRBlockType.OS_04:
                        # D7 D6 D5 O4 O0 D3 D2 D1 BT
                        if data[4] & 0xf == BaseRO.SEQ_OS:
                            dl.append(XgmiiCtrl.SEQ_OS)
                        elif data[4] & 0xf == BaseRO.SIG_OS:
                            dl.append(XgmiiCtrl.SIG_OS)
                        else:
                            dl.append(XgmiiCtrl.ERROR)
                        cl.append(1)
                        dl += data[1:4]
                        cl += [0]*3
                        if (data[4] >> 4) & 0xf == BaseRO.SEQ_OS:
                            dl.append(XgmiiCtrl.SEQ_OS)
                        elif (data[4] >> 4) & 0xf == BaseRO.SIG_OS:
                            dl.append(XgmiiCtrl.SIG_OS)
                        else:
                            dl.append(XgmiiCtrl.ERROR)
                        cl.append(1)
                        dl += data[5:]
                        cl += [0]*3
                    elif data[0] == BaseRBlockType.START_0:
                        # D7 D6 D5 D4 D3 D2 D1    BT
                        dl.append(XgmiiCtrl.START)
                        cl.append(1)
                        dl += data[1:]
                        cl += [0]*7
                    elif data[0] == BaseRBlockType.OS_0:
                        # C7 C6 C5 C4 O0 D3 D2 D1 BT
                        if data[4] & 0xf == BaseRO.SEQ_OS:
                            dl.append(XgmiiCtrl.SEQ_OS)
                        elif data[4] & 0xf == BaseRO.SIG_OS:
                            dl.append(XgmiiCtrl.SEQ_OS)
                        else:
                            dl.append(XgmiiCtrl.ERROR)
                        cl.append(1)
                        dl += data[1:4]
                        cl += [0]*3
                        dl += ctrl[4:]
                        cl += [1]*4
                    elif data[0] in {BaseRBlockType.TERM_0, BaseRBlockType.TERM_1,
                            BaseRBlockType.TERM_2, BaseRBlockType.TERM_3, BaseRBlockType.TERM_4,
                            BaseRBlockType.TERM_5, BaseRBlockType.TERM_6, BaseRBlockType.TERM_7}:
                        # C7 C6 C5 C4 C3 C2 C1    BT
                        # C7 C6 C5 C4 C3 C2    D0 BT
                        # C7 C6 C5 C4 C3    D1 D0 BT
                        # C7 C6 C5 C4    D2 D1 D0 BT
                        # C7 C6 C5    D3 D2 D1 D0 BT
                        # C7 C6    D4 D3 D2 D1 D0 BT
                        # C7    D5 D4 D3 D2 D1 D0 BT
                        #    D6 D5 D4 D3 D2 D1 D0 BT
                        term_lane = block_type_term_lane_mapping[data[0]]
                        dl += data[1:term_lane+1]
                        cl += [0]*term_lane
                        dl.append(XgmiiCtrl.TERM)
                        cl.append(1)
                        dl += ctrl[term_lane+1:]
                        cl += [1]*(7-term_lane)
                    else:
                        # invalid block type
                        self.log.warning("Invalid block type")
                        dl = [XgmiiCtrl.ERROR]*8
                        cl = [1]*8
                else:
                    # invalid sync header
                    self.log.warning("Invalid sync header")
                    dl = [XgmiiCtrl.ERROR]*8
                    cl = [1]*8

                for offset in range(self.byte_lanes):
                    d_val = dl[offset]
                    c_val = cl[offset]

                    if frame is None:
                        if c_val and d_val == XgmiiCtrl.START:
                            # start
                            frame = XgmiiFrame(bytearray([EthPre.PRE]), [0])
                            frame.sim_time_start = get_sim_time()
                            frame.start_lane = offset
                    else:
                        if c_val:
                            # got a control character; terminate frame reception
                            if d_val != XgmiiCtrl.TERM:
                                # store control character if it's not a termination
                                frame.data.append(d_val)
                                frame.ctrl.append(c_val)

                            frame.compact()
                            frame.sim_time_end = get_sim_time()
                            self.log.info("RX frame: %s", frame)

                            self.queue_occupancy_bytes += len(frame)
                            self.queue_occupancy_frames += 1

                            self.queue.put_nowait(frame)
                            self.active_event.set()

                            frame = None
                        else:
                            if frame.sim_time_sfd is None and d_val == EthPre.SFD:
                                frame.sim_time_sfd = get_sim_time()

                            frame.data.append(d_val)
                            frame.ctrl.append(c_val)

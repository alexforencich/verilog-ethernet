"""

Copyright (c) 2018 Alex Forencich

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

import xgmii_ep

ETH_PRE = 0x55
ETH_SFD = 0xD5

XGMII_IDLE   = 0x07
XGMII_LPI    = 0x06
XGMII_START  = 0xfb
XGMII_TERM   = 0xfd
XGMII_ERROR  = 0xfe
XGMII_SEQ_OS = 0x9c
XGMII_RES_0  = 0x1c
XGMII_RES_1  = 0x3c
XGMII_RES_2  = 0x7c
XGMII_RES_3  = 0xbc
XGMII_RES_4  = 0xdc
XGMII_RES_5  = 0xf7
XGMII_SIG_OS = 0x5c

CTRL_IDLE  = 0x00
CTRL_LPI   = 0x06
CTRL_ERROR = 0x1e
CTRL_RES_0 = 0x2d
CTRL_RES_1 = 0x33
CTRL_RES_2 = 0x4b
CTRL_RES_3 = 0x55
CTRL_RES_4 = 0x66
CTRL_RES_5 = 0x78

O_SEQ_OS = 0x0
O_SIG_OS = 0xf

SYNC_DATA = 0b10
SYNC_CTRL = 0b01

BLOCK_TYPE_CTRL     = 0x1e # C7 C6 C5 C4 C3 C2 C1 C0 BT
BLOCK_TYPE_OS_4     = 0x2d # D7 D6 D5 O4 C3 C2 C1 C0 BT
BLOCK_TYPE_START_4  = 0x33 # D7 D6 D5    C3 C2 C1 C0 BT
BLOCK_TYPE_OS_START = 0x66 # D7 D6 D5    O0 D3 D2 D1 BT
BLOCK_TYPE_OS_04    = 0x55 # D7 D6 D5 O4 O0 D3 D2 D1 BT
BLOCK_TYPE_START_0  = 0x78 # D7 D6 D5 D4 D3 D2 D1    BT
BLOCK_TYPE_OS_0     = 0x4b # C7 C6 C5 C4 O0 D3 D2 D1 BT
BLOCK_TYPE_TERM_0   = 0x87 # C7 C6 C5 C4 C3 C2 C1    BT
BLOCK_TYPE_TERM_1   = 0x99 # C7 C6 C5 C4 C3 C2    D0 BT
BLOCK_TYPE_TERM_2   = 0xaa # C7 C6 C5 C4 C3    D1 D0 BT
BLOCK_TYPE_TERM_3   = 0xb4 # C7 C6 C5 C4    D2 D1 D0 BT
BLOCK_TYPE_TERM_4   = 0xcc # C7 C6 C5    D3 D2 D1 D0 BT
BLOCK_TYPE_TERM_5   = 0xd2 # C7 C6    D4 D3 D2 D1 D0 BT
BLOCK_TYPE_TERM_6   = 0xe1 # C7    D5 D4 D3 D2 D1 D0 BT
BLOCK_TYPE_TERM_7   = 0xff #    D6 D5 D4 D3 D2 D1 D0 BT

def block_type_term_lane(bt):
    if bt == BLOCK_TYPE_TERM_0:
        return 0
    elif bt == BLOCK_TYPE_TERM_1:
        return 1
    elif bt == BLOCK_TYPE_TERM_2:
        return 2
    elif bt == BLOCK_TYPE_TERM_3:
        return 3
    elif bt == BLOCK_TYPE_TERM_4:
        return 4
    elif bt == BLOCK_TYPE_TERM_5:
        return 5
    elif bt == BLOCK_TYPE_TERM_6:
        return 6
    elif bt == BLOCK_TYPE_TERM_7:
        return 7
    else:
        return None

class BaseRSerdesSource(object):
    def __init__(self, ifg=12, enable_dic=True):
        self.has_logic = False
        self.queue = []
        self.ifg = ifg
        self.enable_dic = enable_dic
        self.force_offset_start = False

    def send(self, frame):
        self.queue.append(xgmii_ep.XGMIIFrame(frame))

    def count(self):
        return len(self.queue)

    def empty(self):
        return not self.queue

    def create_logic(self,
                clk,
                tx_data,
                tx_header,
                enable=True,
                scramble=True,
                reverse=False,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        assert len(tx_data) in [64]
        assert len(tx_data) == len(tx_header)*32

        bw = int(len(tx_data)/8)

        @instance
        def logic():
            frame = None
            ccl = []
            ifg_cnt = 0
            deficit_idle_cnt = 0
            scrambler_state = 0

            while True:
                yield clk.posedge

                if enable:
                    data = 0x000000000000001e
                    header = 0b01

                    if ifg_cnt > bw-1 or (not self.enable_dic and ifg_cnt > 0):
                        ifg_cnt = max(ifg_cnt - bw, 0)
                    elif ccl:
                        header, data = ccl.pop(0)
                        if not ccl:
                            l = block_type_term_lane(data & 0xff)
                            if l is not None:
                                ifg_cnt = self.ifg - (bw-l) + deficit_idle_cnt
                            else:
                                ifg_cnt = self.ifg + deficit_idle_cnt
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

                        # pad length to multiple of 8 by adding idles
                        if len(dl)%8:
                            for k in range(8-(len(dl)%8)):
                                dl.append(XGMII_IDLE)
                                cl.append(1)

                        # 10GBASE-R encoding
                        for k in range(0, len(dl), 8):
                            di = dl[k:k+8]
                            ci = cl[k:k+8]

                            # remap control characters
                            ctrl = 0
                            ctrl_decode_error = [0]*8
                            for i in range(8):
                                if not ci[i]:
                                    # data
                                    ctrl |= CTRL_ERROR << i*7
                                elif di[i] == XGMII_IDLE:
                                    # idle
                                    ctrl |= CTRL_IDLE << i*7
                                elif di[i] == XGMII_LPI:
                                    # LPI
                                    ctrl |= CTRL_LPI << i*7
                                elif di[i] == XGMII_ERROR:
                                    # error
                                    ctrl |= CTRL_ERROR << i*7
                                elif di[i] == XGMII_RES_0:
                                    # reserved0
                                    ctrl |= CTRL_RES_0 << i*7
                                elif di[i] == XGMII_RES_1:
                                    # reserved1
                                    ctrl |= CTRL_RES_1 << i*7
                                elif di[i] == XGMII_RES_2:
                                    # reserved2
                                    ctrl |= CTRL_RES_2 << i*7
                                elif di[i] == XGMII_RES_3:
                                    # reserved3
                                    ctrl |= CTRL_RES_3 << i*7
                                elif di[i] == XGMII_RES_4:
                                    # reserved4
                                    ctrl |= CTRL_RES_4 << i*7
                                elif di[i] == XGMII_RES_5:
                                    # reserved5
                                    ctrl |= CTRL_RES_5 << i*7
                                else:
                                    # invalid
                                    ctrl |= CTRL_ERROR << i*7
                                    ctrl_decode_error[i] = ci[i]

                            if not any(ci):
                                # data
                                h = SYNC_DATA
                                d = 0
                                for i in range(8):
                                    d |= di[i] << i*8
                            else:
                                # control
                                h = SYNC_CTRL
                                if ci[0] and di[0] == XGMII_START and not any(ci[1:]):
                                    # start in lane 0
                                    d = BLOCK_TYPE_START_0
                                    for i in range(1,8):
                                        d |= di[i] << i*8
                                elif ci[4] and di[4] == XGMII_START and not any(ci[5:]):
                                    # start in lane 4
                                    if ci[0] and (di[0] == XGMII_SEQ_OS or di[0] == XGMII_SIG_OS) and not any(ci[1:4]):
                                        # ordered set in lane 0
                                        d = BLOCK_TYPE_OS_START
                                        for i in range(1,4):
                                            d |= di[i] << i*8
                                        if di[0] == XGMII_SIG_OS:
                                            # signal ordered set
                                            d |= O_SIG_OS << 32
                                    else:
                                        # other control
                                        d = BLOCK_TYPE_START_4 | (ctrl & 0xfffffff) << 8

                                    for i in range(5,8):
                                        d |= di[i] << i*8
                                elif ci[0] and (di[0] == XGMII_SEQ_OS or di[0] == XGMII_SIG_OS) and not any(ci[1:4]):
                                    # ordered set in lane 0
                                    if ci[4] and (di[4] == XGMII_SEQ_OS or di[4] == XGMII_SIG_OS) and not any(ci[5:8]):
                                        # ordered set in lane 4
                                        d = BLOCK_TYPE_OS_04
                                        for i in range(5,8):
                                            d |= di[i] << i*8
                                        if di[4] == XGMII_SIG_OS:
                                            # signal ordered set
                                            d |= O_SIG_OS << 36
                                    else:
                                        d = BLOCK_TYPE_OS_0 | (ctrl & 0xfffffff) << 40
                                    for i in range(1,4):
                                        d |= di[i] << i*8
                                    if di[0] == XGMII_SIG_OS:
                                        # signal ordered set
                                        d |= O_SIG_OS << 32
                                elif ci[4] and (di[4] == XGMII_SEQ_OS or di[4] == XGMII_SIG_OS) and not any(ci[5:8]):
                                    # ordered set in lane 4
                                    d = BLOCK_TYPE_OS_4 | (ctrl & 0xfffffff) << 8
                                    for i in range(5,8):
                                        d |= di[i] << i*8
                                    if di[4] == XGMII_SIG_OS:
                                        # signal ordered set
                                        d |= O_SIG_OS << 36
                                elif ci[0] and di[0] == XGMII_TERM:
                                    # terminate in lane 0
                                    d = BLOCK_TYPE_TERM_0 | (ctrl & 0xffffffffffff80) << 8
                                elif ci[1] and di[1] == XGMII_TERM and not ci[0]:
                                    # terminate in lane 1
                                    d = BLOCK_TYPE_TERM_1 | (ctrl & 0xffffffffffc000) << 8 | di[0] << 8
                                elif ci[2] and di[2] == XGMII_TERM and not any(ci[0:2]):
                                    # terminate in lane 2
                                    d = BLOCK_TYPE_TERM_2 | (ctrl & 0xffffffffe00000) << 8
                                    for i in range(2):
                                        d |= di[i] << ((i+1)*8)
                                elif ci[3] and di[3] == XGMII_TERM and not any(ci[0:3]):
                                    # terminate in lane 3
                                    d = BLOCK_TYPE_TERM_3 | (ctrl & 0xfffffff0000000) << 8
                                    for i in range(3):
                                        d |= di[i] << ((i+1)*8)
                                elif ci[4] and di[4] == XGMII_TERM and not any(ci[0:4]):
                                    # terminate in lane 4
                                    d = BLOCK_TYPE_TERM_4 | (ctrl & 0xfffff800000000) << 8
                                    for i in range(4):
                                        d |= di[i] << ((i+1)*8)
                                elif ci[5] and di[5] == XGMII_TERM and not any(ci[0:5]):
                                    # terminate in lane 5
                                    d = BLOCK_TYPE_TERM_5 | (ctrl & 0xfffc0000000000) << 8
                                    for i in range(5):
                                        d |= di[i] << ((i+1)*8)
                                elif ci[6] and di[6] == XGMII_TERM and not any(ci[0:6]):
                                    # terminate in lane 6
                                    d = BLOCK_TYPE_TERM_6 | (ctrl & 0xfe000000000000) << 8
                                    for i in range(6):
                                        d |= di[i] << ((i+1)*8)
                                elif ci[7] and di[7] == XGMII_TERM and not any(ci[0:7]):
                                    # terminate in lane 7
                                    d = BLOCK_TYPE_TERM_7
                                    for i in range(7):
                                        d |= di[i] << ((i+1)*8)
                                else:
                                    # all control
                                    d = BLOCK_TYPE_CTRL | ctrl << 8

                            ccl.append((h, d))

                        header, data = ccl.pop(0)
                        if not ccl:
                            l = block_type_term_lane(data & 0xff)
                            if l is not None:
                                ifg_cnt = self.ifg - (bw-l) + deficit_idle_cnt
                            else:
                                ifg_cnt = self.ifg + deficit_idle_cnt
                    else:
                        ifg_cnt = 0
                        deficit_idle_cnt = 0

                    if scramble:
                        # 64b66b scrambler
                        b = 0
                        for i in range(len(tx_data)):
                            if bool(scrambler_state & (1<<38)) ^ bool(scrambler_state & (1<<57)) ^ bool(data & (1 << i)):
                                scrambler_state = ((scrambler_state & 0x1ffffffffffffff) << 1) | 1
                                b = b | (1 << i)
                            else:
                                scrambler_state = (scrambler_state & 0x1ffffffffffffff) << 1
                        data = b

                    if reverse:
                        # bit reverse
                        data = sum(1 << (63-i) for i in range(64) if (data >> i) & 1)
                        header = sum(1 << (1-i) for i in range(2) if (header >> i) & 1)

                    tx_data.next = data
                    tx_header.next = header

        return instances()


class BaseRSerdesSink(object):
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
                rx_data,
                rx_header,
                enable=True,
                scramble=True,
                reverse=False,
                name=None
            ):

        assert not self.has_logic

        self.has_logic = True

        assert len(rx_data) in [64]
        assert len(rx_data) == len(rx_header)*32

        bw = int(len(rx_data)/8)

        @instance
        def logic():
            frame = None
            d = []
            c = []
            scrambler_state = 0

            while True:
                yield clk.posedge

                if enable:
                    data = int(rx_data)
                    header = int(rx_header)

                    if reverse:
                        # bit reverse
                        data = sum(1 << (63-i) for i in range(64) if (data >> i) & 1)
                        header = sum(1 << (1-i) for i in range(2) if (header >> i) & 1)

                    if scramble:
                        # 64b66b descrambler
                        b = 0
                        for i in range(len(rx_data)):
                            if bool(scrambler_state & (1<<38)) ^ bool(scrambler_state & (1<<57)) ^ bool(data & (1 << i)):
                                b = b | (1 << i)
                            scrambler_state = (scrambler_state & 0x1ffffffffffffff) << 1 | bool(data & (1 << i))
                        data = b

                    # 10GBASE-R decoding

                    # remap control characters
                    ctrl = [0]*8
                    for i in range(8):
                        if (data >> i*7+8) & 0x7f == CTRL_IDLE:
                            # idle
                            ctrl[i] = XGMII_IDLE;
                        elif (data >> i*7+8) & 0x7f == CTRL_LPI:
                            # LPI
                            ctrl[i] = XGMII_LPI
                        elif (data >> i*7+8) & 0x7f == CTRL_ERROR:
                            # error
                            ctrl[i] = XGMII_ERROR
                        elif (data >> i*7+8) & 0x7f == CTRL_RES_0:
                            # reserved0
                            ctrl[i] = XGMII_RES_0
                        elif (data >> i*7+8) & 0x7f == CTRL_RES_1:
                            # reserved1
                            ctrl[i] = XGMII_RES_1
                        elif (data >> i*7+8) & 0x7f == CTRL_RES_2:
                            # reserved2
                            ctrl[i] = XGMII_RES_2
                        elif (data >> i*7+8) & 0x7f == CTRL_RES_3:
                            # reserved3
                            ctrl[i] = XGMII_RES_3
                        elif (data >> i*7+8) & 0x7f == CTRL_RES_4:
                            # reserved4
                            ctrl[i] = XGMII_RES_4
                        elif (data >> i*7+8) & 0x7f == CTRL_RES_5:
                            # reserved5
                            ctrl[i] = XGMII_RES_5
                        else:
                            # invalid
                            ctrl[i] = XGMII_ERROR

                    dl = []
                    cl = []
                    if header == SYNC_DATA:
                        # data
                        for k in range(8):
                            dl.append((data >> k*8) & 0xff)
                            cl.append(0)
                    elif header == SYNC_CTRL:
                        if data & 0xff == BLOCK_TYPE_CTRL:
                            # C7 C6 C5 C4 C3 C2 C1 C0 BT
                            dl = ctrl
                            cl = [1]*8
                        elif data & 0xff == BLOCK_TYPE_OS_4:
                            # D7 D6 D5 O4 C3 C2 C1 C0 BT
                            dl = ctrl[0:4]
                            cl = [1]*4
                            if (data >> 36) & 0xf == O_SEQ_OS:
                                dl.append(XGMII_SEQ_OS)
                            elif (data >> 36) & 0xf == O_SIG_OS:
                                dl.append(XGMII_SIG_OS)
                            else:
                                dl.append(XGMII_ERROR)
                            cl.append(1)
                            for k in range(4,7):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                        elif data & 0xff == BLOCK_TYPE_START_4:
                            # D7 D6 D5    C3 C2 C1 C0 BT
                            dl = ctrl[0:4]
                            cl = [1]*4
                            dl.append(XGMII_START)
                            cl.append(1)
                            for k in range(4,7):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                        elif data & 0xff == BLOCK_TYPE_OS_START:
                            # D7 D6 D5    O0 D3 D2 D1 BT
                            if (data >> 32) & 0xf == O_SEQ_OS:
                                dl.append(XGMII_SEQ_OS)
                            elif (data >> 32) & 0xf == O_SIG_OS:
                                dl.append(XGMII_SIG_OS)
                            else:
                                dl.append(XGMII_ERROR)
                            cl.append(1)
                            for k in range(0,3):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                            dl.append(XGMII_START)
                            cl.append(1)
                            for k in range(4,7):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                        elif data & 0xff == BLOCK_TYPE_OS_04:
                            # D7 D6 D5 O4 O0 D3 D2 D1 BT
                            if (data >> 32) & 0xf == O_SEQ_OS:
                                dl.append(XGMII_SEQ_OS)
                            elif (data >> 32) & 0xf == O_SIG_OS:
                                dl.append(XGMII_SIG_OS)
                            else:
                                dl.append(XGMII_ERROR)
                            cl.append(1)
                            for k in range(0,3):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                            if (data >> 36) & 0xf == O_SEQ_OS:
                                dl.append(XGMII_SEQ_OS)
                            elif (data >> 36) & 0xf == O_SIG_OS:
                                dl.append(XGMII_SIG_OS)
                            else:
                                dl.append(XGMII_ERROR)
                            cl.append(1)
                            for k in range(4,7):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                        elif data & 0xff == BLOCK_TYPE_START_0:
                            # D7 D6 D5 D4 D3 D2 D1    BT
                            dl.append(XGMII_START)
                            cl.append(1)
                            for k in range(7):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                        elif data & 0xff == BLOCK_TYPE_OS_0:
                            # C7 C6 C5 C4 O0 D3 D2 D1 BT
                            if (data >> 32) & 0xf == O_SEQ_OS:
                                dl.append(XGMII_SEQ_OS)
                            elif (data >> 32) & 0xf == O_SIG_OS:
                                dl.append(XGMII_SEQ_OS)
                            else:
                                dl.append(XGMII_ERROR)
                            cl.append(1)
                            for k in range(0,3):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                            dl.extend(ctrl[4:8])
                            cl.extend([1]*4)
                        elif data & 0xff == BLOCK_TYPE_TERM_0:
                            # C7 C6 C5 C4 C3 C2 C1    BT
                            dl.append(XGMII_TERM)
                            cl.append(1)
                            dl.extend(ctrl[1:])
                            cl.extend([1]*7)
                        elif data & 0xff == BLOCK_TYPE_TERM_1:
                            # C7 C6 C5 C4 C3 C2    D0 BT
                            dl.append((data >> 8) & 0xff)
                            cl.append(0)
                            dl.append(XGMII_TERM)
                            cl.append(1)
                            dl.extend(ctrl[2:])
                            cl.extend([1]*6)
                        elif data & 0xff == BLOCK_TYPE_TERM_2:
                            # C7 C6 C5 C4 C3    D1 D0 BT
                            for k in range(2):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                            dl.append(XGMII_TERM)
                            cl.append(1)
                            dl.extend(ctrl[3:])
                            cl.extend([1]*5)
                        elif data & 0xff == BLOCK_TYPE_TERM_3:
                            # C7 C6 C5 C4    D2 D1 D0 BT
                            for k in range(3):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                            dl.append(XGMII_TERM)
                            cl.append(1)
                            dl.extend(ctrl[4:])
                            cl.extend([1]*4)
                        elif data & 0xff == BLOCK_TYPE_TERM_4:
                            # C7 C6 C5    D3 D2 D1 D0 BT
                            for k in range(4):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                            dl.append(XGMII_TERM)
                            cl.append(1)
                            dl.extend(ctrl[5:])
                            cl.extend([1]*3)
                        elif data & 0xff == BLOCK_TYPE_TERM_5:
                            # C7 C6    D4 D3 D2 D1 D0 BT
                            for k in range(5):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                            dl.append(XGMII_TERM)
                            cl.append(1)
                            dl.extend(ctrl[6:])
                            cl.extend([1]*2)
                        elif data & 0xff == BLOCK_TYPE_TERM_6:
                            # C7    D5 D4 D3 D2 D1 D0 BT
                            for k in range(6):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                            dl.append(XGMII_TERM)
                            cl.append(1)
                            dl.extend(ctrl[7:])
                            cl.extend([1]*1)
                        elif data & 0xff == BLOCK_TYPE_TERM_7:
                            #    D6 D5 D4 D3 D2 D1 D0 BT
                            for k in range(7):
                                dl.append((data >> (k+1)*8) & 0xff)
                                cl.append(0)
                            dl.append(XGMII_TERM)
                            cl.append(1)
                        else:
                            # invalid block type
                            dl = [XGMII_ERROR]*8
                            cl = [1]*8
                    else:
                        # invalid sync header
                        dl = [XGMII_ERROR]*8
                        cl = [1]*8

                    if frame is None:
                        if cl[0] and dl[0] == XGMII_START:
                            # start in lane 0
                            frame = xgmii_ep.XGMIIFrame()
                            d = [ETH_PRE]
                            c = [0]
                            for i in range(1,bw):
                                d.append(dl[i])
                                c.append(cl[i])
                        elif bw == 8 and cl[4] and dl[4] == XGMII_START:
                            # start in lane 4
                            frame = xgmii_ep.XGMIIFrame()
                            d = [ETH_PRE]
                            c = [0]
                            for i in range(5,bw):
                                d.append(dl[i])
                                c.append(cl[i])
                    else:
                        for i in range(bw):
                            if cl[i]:
                                # got a control character; terminate frame reception
                                if dl[i] != XGMII_TERM:
                                    # store control character if it's not a termination
                                    d.append(dl[i])
                                    c.append(cl[i])
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
                                d.append(dl[i])
                                c.append(cl[i])

        return instances()


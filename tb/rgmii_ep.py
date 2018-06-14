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

import gmii_ep

class RGMIISource(gmii_ep.GMIISource):
    def create_logic(self,
                clk,
                rst,
                txd,
                tx_ctl,
                clk_enable=True,
                mii_select=False,
                name=None
            ):

        assert not self.has_logic

        gmii_txd = Signal(intbv(0)[8:])
        gmii_tx_en = Signal(bool(0))
        gmii_tx_er = Signal(bool(0))

        gmii_txd_reg = Signal(intbv(0)[8:])
        gmii_tx_en_reg = Signal(bool(0))
        gmii_tx_er_reg = Signal(bool(0))

        gmii_source = super(RGMIISource, self).create_logic(clk, rst, gmii_txd, gmii_tx_en, gmii_tx_er, clk_enable, mii_select, name)

        @instance
        def logic():
            while True:
                yield clk.negedge
                txd.next = gmii_txd_reg[4:0]
                tx_ctl.next = gmii_tx_en_reg
                yield clk.posedge
                if not mii_select:
                    txd.next = gmii_txd_reg[8:4]
                tx_ctl.next = gmii_tx_en_reg ^ gmii_tx_er_reg
                gmii_txd_reg.next = gmii_txd
                gmii_tx_en_reg.next = gmii_tx_en
                gmii_tx_er_reg.next = gmii_tx_er

        return instances()


class RGMIISink(gmii_ep.GMIISink):
    def create_logic(self,
                clk,
                rst,
                rxd,
                rx_ctl,
                clk_enable=True,
                mii_select=False,
                name=None
            ):

        assert not self.has_logic

        gmii_rxd = Signal(intbv(0)[8:])
        gmii_rx_dv = Signal(bool(0))
        gmii_rx_er = Signal(bool(0))

        gmii_sink = super(RGMIISink, self).create_logic(clk, rst, gmii_rxd, gmii_rx_dv, gmii_rx_er, clk_enable, mii_select, name)

        @instance
        def logic():
            dat = 0
            ctl1 = 0
            ctl2 = 0

            while True:
                yield clk.posedge
                gmii_rxd.next = dat
                gmii_rx_dv.next = ctl1
                gmii_rx_er.next = ctl1 ^ ctl2
                dat = int(rxd.val)
                ctl1 = int(rx_ctl.val)
                yield clk.negedge
                dat |= int(rxd.val) << 4
                ctl2 = int(rx_ctl.val)

        return instances()


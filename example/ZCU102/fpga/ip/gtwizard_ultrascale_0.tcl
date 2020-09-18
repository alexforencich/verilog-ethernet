
create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_0

set_property -dict [list CONFIG.preset {GTH-10GBASE-R}] [get_ips gtwizard_ultrascale_0]

set_property -dict [list \
    CONFIG.CHANNEL_ENABLE {X1Y15 X1Y14 X1Y13 X1Y12} \
    CONFIG.TX_MASTER_CHANNEL {X1Y12} \
    CONFIG.RX_MASTER_CHANNEL {X1Y12} \
    CONFIG.TX_LINE_RATE {10.3125} \
    CONFIG.TX_REFCLK_FREQUENCY {156.25} \
    CONFIG.TX_USER_DATA_WIDTH {64} \
    CONFIG.TX_INT_DATA_WIDTH {32} \
    CONFIG.RX_LINE_RATE {10.3125} \
    CONFIG.RX_REFCLK_FREQUENCY {156.25} \
    CONFIG.RX_USER_DATA_WIDTH {64} \
    CONFIG.RX_INT_DATA_WIDTH {32} \
    CONFIG.RX_REFCLK_SOURCE {X1Y15 clk0 X1Y14 clk0 X1Y13 clk0 X1Y12 clk0} \
    CONFIG.TX_REFCLK_SOURCE {X1Y15 clk0 X1Y14 clk0 X1Y13 clk0 X1Y12 clk0} \
    CONFIG.FREERUN_FREQUENCY {125} \
] [get_ips gtwizard_ultrascale_0]

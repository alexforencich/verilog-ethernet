
create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -module_name gtwiz_qsfp_9

set_property -dict [list CONFIG.preset {GTY-10GBASE-R}] [get_ips gtwiz_qsfp_9]

set_property -dict [list \
    CONFIG.CHANNEL_ENABLE {X0Y4 X0Y5 X0Y6 X0Y7} \
    CONFIG.TX_MASTER_CHANNEL {X0Y6} \
    CONFIG.RX_MASTER_CHANNEL {X0Y6} \
    CONFIG.TX_LINE_RATE {10.3125} \
    CONFIG.TX_REFCLK_FREQUENCY {161.1328125} \
    CONFIG.TX_USER_DATA_WIDTH {64} \
    CONFIG.TX_INT_DATA_WIDTH {64} \
    CONFIG.RX_LINE_RATE {10.3125} \
    CONFIG.RX_REFCLK_FREQUENCY {161.1328125} \
    CONFIG.RX_USER_DATA_WIDTH {64} \
    CONFIG.RX_INT_DATA_WIDTH {64} \
    CONFIG.RX_REFCLK_SOURCE {X0Y4 clk1 X0Y5 clk1 X0Y6 clk1 X0Y7 clk1} \
    CONFIG.TX_REFCLK_SOURCE {X0Y4 clk1 X0Y5 clk1 X0Y6 clk1 X0Y7 clk1} \
    CONFIG.FREERUN_FREQUENCY {125} \
] [get_ips gtwiz_qsfp_9]

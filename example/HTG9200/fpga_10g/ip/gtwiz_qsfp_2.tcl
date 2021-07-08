
create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -module_name gtwiz_qsfp_2

set_property -dict [list CONFIG.preset {GTY-10GBASE-R}] [get_ips gtwiz_qsfp_2]

set_property -dict [list \
    CONFIG.CHANNEL_ENABLE {X0Y32 X0Y33 X0Y34 X0Y35} \
    CONFIG.TX_MASTER_CHANNEL {X0Y34} \
    CONFIG.RX_MASTER_CHANNEL {X0Y34} \
    CONFIG.TX_LINE_RATE {10.3125} \
    CONFIG.TX_REFCLK_FREQUENCY {161.1328125} \
    CONFIG.TX_USER_DATA_WIDTH {64} \
    CONFIG.TX_INT_DATA_WIDTH {64} \
    CONFIG.RX_LINE_RATE {10.3125} \
    CONFIG.RX_REFCLK_FREQUENCY {161.1328125} \
    CONFIG.RX_USER_DATA_WIDTH {64} \
    CONFIG.RX_INT_DATA_WIDTH {64} \
    CONFIG.RX_REFCLK_SOURCE {X0Y32 clk0 X0Y33 clk0 X0Y34 clk0 X0Y35 clk0} \
    CONFIG.TX_REFCLK_SOURCE {X0Y32 clk0 X0Y33 clk0 X0Y34 clk0 X0Y35 clk0} \
    CONFIG.FREERUN_FREQUENCY {125} \
] [get_ips gtwiz_qsfp_2]

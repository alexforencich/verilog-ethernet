
create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_0

set_property -dict [list CONFIG.preset {GTY-10GBASE-R}] [get_ips gtwizard_ultrascale_0]

set_property -dict [list \
    CONFIG.CHANNEL_ENABLE {X0Y47 X0Y46 X0Y45 X0Y44 X0Y43 X0Y42 X0Y41 X0Y40} \
    CONFIG.TX_MASTER_CHANNEL {X0Y40} \
    CONFIG.RX_MASTER_CHANNEL {X0Y40} \
    CONFIG.TX_LINE_RATE {10.3125} \
    CONFIG.TX_REFCLK_FREQUENCY {161.1328125} \
    CONFIG.TX_USER_DATA_WIDTH {64} \
    CONFIG.TX_INT_DATA_WIDTH {64} \
    CONFIG.RX_LINE_RATE {10.3125} \
    CONFIG.RX_REFCLK_FREQUENCY {161.1328125} \
    CONFIG.RX_USER_DATA_WIDTH {64} \
    CONFIG.RX_INT_DATA_WIDTH {64} \
    CONFIG.RX_REFCLK_SOURCE {X0Y47 clk1-1 X0Y46 clk1-1 X0Y45 clk1-1 X0Y44 clk1-1 X0Y43 clk1 X0Y42 clk1 X0Y41 clk1 X0Y40 clk1} \
    CONFIG.TX_REFCLK_SOURCE {X0Y47 clk1-1 X0Y46 clk1-1 X0Y45 clk1-1 X0Y44 clk1-1 X0Y43 clk1 X0Y42 clk1 X0Y41 clk1 X0Y40 clk1} \
    CONFIG.FREERUN_FREQUENCY {125} \
] [get_ips gtwizard_ultrascale_0]

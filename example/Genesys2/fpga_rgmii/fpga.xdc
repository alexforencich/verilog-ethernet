# XDC constraints for the Digilent Genesys 2 Rev. H board
# part: xc7k325tffg900c
# Adapted for Digilent Genesys2 board by Torsten Reuschel 2021

# General configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

# System clocks
# 200 MHz
set_property -dict {PACKAGE_PIN AD11  IOSTANDARD LVDS} [get_ports { clk_200mhz_n }]; #IO_L12N_T1_MRCC_33 Sch=sysclk_n
set_property -dict {PACKAGE_PIN AD12  IOSTANDARD LVDS} [get_ports { clk_200mhz_p }]; #IO_L12P_T1_MRCC_33 Sch=sysclk_p
create_clock -period 5.000 -name clk_200mhz [get_ports clk_200mhz_p]

# LEDs
set_property -dict {PACKAGE_PIN T28   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { led[0] }]; #IO_L11N_T1_SRCC_14 Sch=led[0]
set_property -dict {PACKAGE_PIN V19   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { led[1] }]; #IO_L19P_T3_A10_D26_14 Sch=led[1]
set_property -dict {PACKAGE_PIN U30   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { led[2] }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=led[2]
set_property -dict {PACKAGE_PIN U29   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { led[3] }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=led[3]
set_property -dict {PACKAGE_PIN V20   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { led[4] }]; #IO_L19N_T3_A09_D25_VREF_14 Sch=led[4]
set_property -dict {PACKAGE_PIN V26   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { led[5] }]; #IO_L16P_T2_CSI_B_14 Sch=led[5]
set_property -dict {PACKAGE_PIN W24   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { led[6] }]; #IO_L20N_T3_A07_D23_14 Sch=led[6]
set_property -dict {PACKAGE_PIN W23   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { led[7] }]; #IO_L20P_T3_A08_D24_14 Sch=led[7]

set_false_path -to [get_ports { led[*] }]
set_output_delay 0 [get_ports { led[*] }]

# Reset button
set_property -dict {PACKAGE_PIN R19   IOSTANDARD LVCMOS33} [get_ports { reset_n }]; #IO_0_14 Sch=cpu_resetn

set_false_path -from [get_ports { reset_n }]
set_input_delay 0 [get_ports { reset_n }]

# Push buttons
set_property -dict {PACKAGE_PIN E18   IOSTANDARD LVCMOS12} [get_ports { btnc }]; #IO_25_17 Sch=btnc
set_property -dict {PACKAGE_PIN M19   IOSTANDARD LVCMOS12} [get_ports { btnd }]; #IO_0_15 Sch=btnd
set_property -dict {PACKAGE_PIN M20   IOSTANDARD LVCMOS12} [get_ports { btnl }]; #IO_L6P_T0_15 Sch=btnl
set_property -dict {PACKAGE_PIN C19   IOSTANDARD LVCMOS12} [get_ports { btnr }]; #IO_L24P_T3_17 Sch=btnr
set_property -dict {PACKAGE_PIN B19   IOSTANDARD LVCMOS12} [get_ports { btnu }]; #IO_L24N_T3_17 Sch=btnu

set_false_path -from [get_ports { btnu btnl btnd btnr btnc }]
set_input_delay 0 [get_ports { btnu btnl btnd btnr btnc }]

# Toggle switches
set_property -dict {PACKAGE_PIN G19   IOSTANDARD LVCMOS12} [get_ports { sw[0] }]; #IO_0_17 Sch=sw[0]
set_property -dict {PACKAGE_PIN G25   IOSTANDARD LVCMOS12} [get_ports { sw[1] }]; #IO_25_16 Sch=sw[1]
set_property -dict {PACKAGE_PIN H24   IOSTANDARD LVCMOS12} [get_ports { sw[2] }]; #IO_L19P_T3_16 Sch=sw[2]
set_property -dict {PACKAGE_PIN K19   IOSTANDARD LVCMOS12} [get_ports { sw[3] }]; #IO_L6P_T0_17 Sch=sw[3]

set_false_path -from [get_ports { sw[*] }]
set_input_delay 0 [get_ports { sw[*] }]

# UART
set_property -dict {PACKAGE_PIN Y20   IOSTANDARD LVCMOS33                   } [get_ports { uart_rxd }]; #IO_0_12 Sch=uart_tx_in
set_property -dict {PACKAGE_PIN Y23   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { uart_txd }]; #IO_L1P_T0_12 Sch=uart_rx_out
#set_property -dict { PACKAGE_PIN Y20   IOSTANDARD LVCMOS33 } [get_ports { uart_txd }]; #IO_0_12 Sch=uart_tx_in
#set_property -dict { PACKAGE_PIN Y23   IOSTANDARD LVCMOS33 } [get_ports { uart_rxd }]; #IO_L1P_T0_12 Sch=uart_rx_out

set_false_path -to [get_ports {uart_txd}]
set_output_delay 0 [get_ports {uart_txd}]
set_false_path -from [get_ports {uart_rxd}]
set_input_delay 0 [get_ports {uart_rxd}]

# Gigabit Ethernet GMII PHY
set_property -dict {PACKAGE_PIN AG10  IOSTANDARD LVCMOS15                   } [get_ports { phy_rx_clk }]; #IO_L13P_T2_MRCC_33 Sch=eth_rx_clk
set_property -dict {PACKAGE_PIN AJ14  IOSTANDARD LVCMOS15                   } [get_ports { phy_rxd[0] }]; #IO_L21N_T3_DQS_33 Sch=eth_rx_d[0]
set_property -dict {PACKAGE_PIN AH14  IOSTANDARD LVCMOS15                   } [get_ports { phy_rxd[1] }]; #IO_L21P_T3_DQS_33 Sch=eth_rx_d[1]
set_property -dict {PACKAGE_PIN AK13  IOSTANDARD LVCMOS15                   } [get_ports { phy_rxd[2] }]; #IO_L20N_T3_33 Sch=eth_rx_d[2]
set_property -dict {PACKAGE_PIN AJ13  IOSTANDARD LVCMOS15                   } [get_ports { phy_rxd[3] }]; #IO_L22P_T3_33 Sch=eth_rx_d[3]
set_property -dict {PACKAGE_PIN AH11  IOSTANDARD LVCMOS15                   } [get_ports { phy_rx_ctl }]; #IO_L18P_T2_33 Sch=eth_rx_ctl
set_property -dict {PACKAGE_PIN AE10  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_tx_clk }]; #IO_L14P_T2_SRCC_33 Sch=eth_tx_clk
set_property -dict {PACKAGE_PIN AJ12  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_txd[0] }]; #IO_L22N_T3_33 Sch=eth_tx_d[0]
set_property -dict {PACKAGE_PIN AK11  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_txd[1] }]; #IO_L17P_T2_33 Sch=eth_tx_d[1]
set_property -dict {PACKAGE_PIN AJ11  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_txd[2] }]; #IO_L18N_T2_33 Sch=eth_tx_d[2]
set_property -dict {PACKAGE_PIN AK10  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_txd[3] }]; #IO_L17N_T2_33 Sch=eth_tx_d[3]
set_property -dict {PACKAGE_PIN AK14  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_tx_ctl }]; #IO_L20P_T3_33 Sch=eth_tx_en
set_property -dict {PACKAGE_PIN AH24  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { phy_reset_n }]; #IO_L14N_T2_SRCC_12 Sch=eth_phyrst_n
set_property -dict {PACKAGE_PIN AK16  IOSTANDARD LVCMOS18                   } [get_ports { phy_int_n }]; #IO_L1P_T0_32 Sch=eth_intb
#set_property -dict {PACKAGE_PIN AK15 IOSTANDARD LVCMOS18} [get_ports phy_pme_n]
#set_property -dict {PACKAGE_PIN AG12  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports phy_mdio]
#set_property -dict {PACKAGE_PIN AF12  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports phy_mdc]

create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]

set_false_path -to [get_ports { phy_reset_n }]
set_output_delay 0 [get_ports { phy_reset_n }]
set_false_path -from [get_ports { phy_int_n }]
set_input_delay 0 [get_ports { phy_int_n }]


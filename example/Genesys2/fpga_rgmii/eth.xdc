# Ethernet constraints

# IDELAY on RGMII from PHY chip
set_property IDELAY_VALUE 0 [get_cells {phy_rx_ctl_idelay phy_rxd_idelay_*}]


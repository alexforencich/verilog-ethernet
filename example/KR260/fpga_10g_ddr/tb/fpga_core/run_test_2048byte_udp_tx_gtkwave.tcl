# add_waves.tcl 
set sig_list {                                 \
    clk                                        \
    rst                                        \
    axi_dma_wr_inst.enable                     \
    axi_dma_wr_inst.abort                      \
    axi_dma_wr_inst.s_axis_write_desc_addr     \
    axi_dma_wr_inst.s_axis_write_desc_len      \
    axi_dma_wr_inst.s_axis_write_desc_tag      \
    axi_dma_wr_inst.s_axis_write_desc_valid    \
    axi_dma_wr_inst.s_axis_write_desc_ready    \
    axi_dma_wr_inst.s_axis_write_data_tdata    \
    axi_dma_wr_inst.s_axis_write_data_tkeep    \
    axi_dma_wr_inst.s_axis_write_data_tvalid   \
    axi_dma_wr_inst.s_axis_write_data_tready   \
    axi_dma_wr_inst.s_axis_write_data_tlast    \
    axi_dma_wr_inst.s_axis_write_data_tid      \
    axi_dma_wr_inst.s_axis_write_data_tdest    \
    axi_dma_wr_inst.s_axis_write_data_tuser    \
    m_axi_arid                                 \
    m_axi_araddr                               \
    m_axi_arlen                                \
    m_axi_arsize                               \
    m_axi_arburst                              \
    m_axi_arlock                               \
    m_axi_arcache                              \
    m_axi_arprot                               \
    m_axi_arvalid                              \
    m_axi_arready                              \
    m_axi_rid                                  \
    m_axi_rdata                                \
    m_axi_rresp                                \
    m_axi_rlast                                \
    m_axi_rvalid                               \
    m_axi_rready                               \
    axis_udp_tx_payload_tdata                  \
    axis_udp_tx_payload_tkeep                  \
    axis_udp_tx_payload_tvalid                 \
    axis_udp_tx_payload_tready                 \
    axis_udp_tx_payload_tlast                  \
    axis_udp_tx_payload_tuser                  \
    sfp0_tx_clk                                \
    sfp0_tx_rst                                \
    sfp0_txd                                   \
    sfp0_txc                                   \
}

gtkwave::addSignalsFromList $sig_list

# Zoom full (Shift + Alt + F)
gtkwave::/Time/Zoom/Zoom_Full

# Change signal formats
gtkwave::/Edit/Highlight_Regexp "axi_dma_wr_inst.clk"
gtkwave::/Edit/Data_Format/Hexadecimal
gtkwave::/Edit/UnHighlight_All


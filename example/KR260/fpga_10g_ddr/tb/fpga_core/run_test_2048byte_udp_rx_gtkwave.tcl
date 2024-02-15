# add_waves.tcl 
set sig_list {                                 \
    clk                                        \
    rst                                        \
    sfp0_rx_clk                                \
    sfp0_rx_rst                                \
    sfp0_rxd                                   \
    sfp0_rxc                                   \
    axis_udp_rx_payload_tdata                  \
    axis_udp_rx_payload_tkeep                  \
    axis_udp_rx_payload_tvalid                 \
    axis_udp_rx_payload_tready                 \
    axis_udp_rx_payload_tlast                  \
    axis_udp_rx_payload_tuser                  \    
    axi_dma_wr_inst.clk                        \ 
    axi_dma_wr_inst.rst                        \ 
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
    m_axi_awid                                 \ 
    m_axi_awaddr                               \ 
    m_axi_awlen                                \ 
    m_axi_awsize                               \ 
    m_axi_awburst                              \ 
    m_axi_awlock                               \ 
    m_axi_awcache                              \ 
    m_axi_awprot                               \ 
    m_axi_awvalid                              \ 
    m_axi_awready                              \ 
    m_axi_wdata                                \ 
    m_axi_wstrb                                \ 
    m_axi_wlast                                \ 
    m_axi_wvalid                               \ 
    m_axi_wready                               \ 
    m_axi_bid                                  \ 
    m_axi_bresp                                \ 
    m_axi_bvalid                               \ 
    m_axi_bready                               \
}

gtkwave::addSignalsFromList $sig_list

# Zoom full (Shift + Alt + F)
gtkwave::/Time/Zoom/Zoom_Full

# Change signal formats
gtkwave::/Edit/Highlight_Regexp "axi_dma_wr_inst.clk"
gtkwave::/Edit/Data_Format/Hexadecimal
gtkwave::/Edit/UnHighlight_All


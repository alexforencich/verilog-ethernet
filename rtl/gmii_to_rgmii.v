// cspell:ignore gmii, rgmii, posedge, IODDR, IODDR2, Virtex, BUFG, BUFR, Ultrascale, ALTERA
/*

 Converts gmii to rgmii and vice versa.

*/

`timescale 1ns / 1ps

module gmii_to_rgmii #
(
   // target ("SIM", "GENERIC", "XILINX", "ALTERA")
    parameter TARGET = "GENERIC",
    // IODDR style ("IODDR", "IODDR2")
    // Use IODDR for Virtex-4, Virtex-5, Virtex-6, 7 Series, Ultrascale
    // Use IODDR2 for Spartan-6
    parameter IODDR_STYLE = "IODDR",
    // Clock input style ("BUFG", "BUFR", "BUFIO", "BUFIO2")
    // Use BUFR for Virtex-6, 7-series
    // Use BUFG for Virtex-5, Spartan-6, Ultrascale
    parameter CLOCK_INPUT_STYLE = "BUFG",
    // Use 90 degree clock for RGMII transmit ("TRUE", "FALSE")
    parameter USE_CLK90 = "TRUE"
)
(
    input  wire        clk,
    input  wire        clk90,
    input  wire        rst,

    /*
     * GMII interface to MAC
     */
    // Tx
    output wire        mac_gmii_tx_clk,
    output wire        mac_gmii_tx_rst,
    output wire        mac_gmii_tx_clk_en,
    input  wire [7:0]  mac_gmii_txd,
    input  wire        mac_gmii_tx_en,
    input  wire        mac_gmii_tx_er,
    // Rx
    output wire        mac_gmii_rx_clk,
    output wire        mac_gmii_rx_rst,
    output wire [7:0]  mac_gmii_rxd,
    output wire        mac_gmii_rx_dv,
    output wire        mac_gmii_rx_er,
    /*
     * RGMII interface to PHY
     */
    // Tx
    output wire        phy_rgmii_tx_clk,
    output wire [3:0]  phy_rgmii_txd,
    output wire        phy_rgmii_tx_ctl,
    // Rx
    input  wire        phy_rgmii_rx_clk,
    input  wire [3:0]  phy_rgmii_rxd,
    input  wire        phy_rgmii_rx_ctl,

);


reg [1:0] speed_reg = 2'b10;
reg mii_select_reg = 1'b0;

(* srl_style = "register" *)
reg [1:0] tx_mii_select_sync = 2'd0;

always @(posedge mac_gmii_tx_clk) begin
    tx_mii_select_sync <= {tx_mii_select_sync[0], mii_select_reg};
end

(* srl_style = "register" *)
reg [1:0] rx_mii_select_sync = 2'd0;

always @(posedge mac_gmii_tx_clk) begin
    rx_mii_select_sync <= {rx_mii_select_sync[0], mii_select_reg};
end

// PHY speed detection
reg [2:0] rx_prescale = 3'd0;

always @(posedge mac_gmii_tx_clk) begin
    rx_prescale <= rx_prescale + 3'd1;
end

(* srl_style = "register" *)
reg [2:0] rx_prescale_sync = 3'd0;

always @(posedge phy_rgmii_tx_clk) begin
    rx_prescale_sync <= {rx_prescale_sync[1:0], rx_prescale[2]};
end

reg [6:0] rx_speed_count_1 = 0;
reg [1:0] rx_speed_count_2 = 0;

always @(posedge phy_rgmii_tx_clk) begin
    if (mac_gmii_tx_rst) begin
        rx_speed_count_1 <= 0;
        rx_speed_count_2 <= 0;
        speed_reg <= 2'b10;
        mii_select_reg <= 1'b0;
    end else begin
        rx_speed_count_1 <= rx_speed_count_1 + 1;
        
        if (rx_prescale_sync[1] ^ rx_prescale_sync[2]) begin
            rx_speed_count_2 <= rx_speed_count_2 + 1;
        end

        if (&rx_speed_count_1) begin
            // reference count overflow - 10M
            rx_speed_count_1 <= 0;
            rx_speed_count_2 <= 0;
            speed_reg <= 2'b00;
            mii_select_reg <= 1'b1;
        end

        if (&rx_speed_count_2) begin
            // prescaled count overflow - 100M or 1000M
            rx_speed_count_1 <= 0;
            rx_speed_count_2 <= 0;
            if (rx_speed_count_1[6:5]) begin
                // large reference count - 100M
                speed_reg <= 2'b01;
                mii_select_reg <= 1'b1;
            end else begin
                // small reference count - 1000M
                speed_reg <= 2'b10;
                mii_select_reg <= 1'b0;
            end
        end
    end
end

assign speed = speed_reg;

rgmii_phy_if #(
    .TARGET(TARGET),
    .IODDR_STYLE(IODDR_STYLE),
    .CLOCK_INPUT_STYLE(CLOCK_INPUT_STYLE),
    .USE_CLK90(USE_CLK90)
)
rgmii_phy_if_inst (
    .clk(clk),
    .clk90(clk90),
    .rst(rst),

    .mac_gmii_rx_clk(mac_gmii_rx_clk),
    .mac_gmii_rx_rst(mac_gmii_rx_rst),
    .mac_gmii_rxd(mac_gmii_rxd),
    .mac_gmii_rx_dv(mac_gmii_rx_dv),
    .mac_gmii_rx_er(mac_gmii_rx_er),
    .mac_gmii_tx_clk(mac_gmii_tx_clk),
    .mac_gmii_tx_rst(mac_gmii_tx_rst),
    .mac_gmii_tx_clk_en(mac_gmii_tx_clk_en),
    .mac_gmii_txd(mac_gmii_txd),
    .mac_gmii_tx_en(mac_gmii_tx_en),
    .mac_gmii_tx_er(mac_gmii_tx_er),

    .phy_rgmii_rx_clk(phy_rgmii_rx_clk),
    .phy_rgmii_rxd(phy_rgmii_rxd),
    .phy_rgmii_rx_ctl(phy_rgmii_rx_ctl),
    .phy_rgmii_tx_clk(phy_rgmii_tx_clk),
    .phy_rgmii_txd(phy_rgmii_txd),
    .phy_rgmii_tx_ctl(phy_rgmii_tx_ctl),

    .speed(speed)
);


endmodule


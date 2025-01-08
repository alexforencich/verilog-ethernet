`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Kavyash15
// 
// Create Date: 12/17/2024 10:56:44 AM
// Design Name: 
// Module Name: ethernet_mdio
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`resetall
`timescale 1ns / 1ps
`default_nettype none

module ethernet_mdio( 
    input wire clk,                // clock signal posedge 
    input wire resetn,             // active low reset
    input wire en,
    output reg mdio_o ,
    output reg mdio_t,
    output reg phy_mdc_port
);
    parameter [2:0] GAP1 = 3'd0 ,
    COMMAND1 = 3'd1,
    GAP2=  3'd2,
    COMMAND2 = 3'd3, 
    GAP3 = 3'd4, 
    COMMAND3 = 3'd5,
    DONE = 3'd6 ;
    
    reg [2:0] state_reg = GAP1;
    reg [6:0] gap_counter = 7'b0;
    reg [6:0] bit_counter = 7'd0;
    reg [31:0] command1 = 32'b00000010100010000100000100001010;  // Command 1  01-01-00001-00000-10-00110001-00000000
                                                                           //  01-01-00001-00000-10-00110001-00000000
    reg [31:0] command2 = 32'b00000000000000000110010100001010;  // Command 2  01-01-00001-01001-10-00000000-00000000
                                                                         //    01-01-00001-01001-10-00000000-00000000
    reg [31:0] command3 = 32'b00000010110010000100000100001010;  // Command 3  01-01-00001-00000-10-00110011-00000000
                                                                         //    01-01-00001-00000-10-00110011-00000000
    reg [7:0] mdc_counter = 8'd0; 
    always @(posedge clk) begin 
        if(!resetn) begin 
            phy_mdc_port <= 0;
            mdc_counter <= 0;
        end 
        else begin 
            if(en) begin 
                mdc_counter <= 0;
                phy_mdc_port <= 0;
            end 
            else begin
                if(mdc_counter < 8'd24) begin 
                    mdc_counter <= mdc_counter + 1;
                    phy_mdc_port <= 0;
                end  
                else begin 
                    mdc_counter <= 0;
                    phy_mdc_port <= 1;
                end 
            end 
        end 
    end 
    // Initial conditions or reset conditions
    always @(posedge clk) begin
        if (!resetn) begin
            state_reg  <= GAP1;
            gap_counter <= 7'd0;
            bit_counter <= 7'd0;
            mdio_o <= 1'b0;  // Initialize mdio_o
            mdio_t <= 1'b1;  // Initialize mdio_t
        end else begin        
        if(en)begin 
            case(state_reg) 
                GAP1: begin
                    mdio_o <= 1'b0;
                    mdio_t <= 1'b1;
                    if (gap_counter < 7'd64) begin
                        gap_counter <= gap_counter + 1'b1;
                    end else begin
                        gap_counter <= 7'd0;
                        state_reg <= COMMAND1;
                        bit_counter <= 7'd0;
                    end
                end
//no autonego, 
                COMMAND1: begin
                    if (bit_counter < 7'd32) begin  //this is preamble
                        mdio_t <= 1'b0;
                        mdio_o <= 1'b1;
                        bit_counter <= bit_counter + 1'b1;
                    end else if (bit_counter < 7'd64) begin   // this here consist of  01 start -01 opcode (01 write 10 read) -00001 PHY addr -00000 REG addr 
                                                              // -10 Turn around field (write 10 ,read -release) -00110001 data -00000000  data  [00100000]
                        mdio_t <= 1'b0;
                        mdio_o <= command1[bit_counter - 7'd32];
                        bit_counter <= bit_counter + 1'b1;
                    end else begin
                        mdio_t <= 1'b1;
                        mdio_o <= 1'b0;
                        bit_counter <= 7'b0;
                        state_reg <= GAP2; 
                    end
                end

                GAP2: begin
                    mdio_o <= 1'b0;
                    mdio_t <= 1'b1;
                    if (gap_counter < 7'd64) begin
                        gap_counter <= gap_counter + 1'b1;
                    end else begin
                        gap_counter <= 7'b0;
                        state_reg <= COMMAND2;
                        bit_counter <= 7'b0;
                    end
                end

                COMMAND2: begin
                    if (bit_counter < 7'd32) begin
                        mdio_t <= 1'b0;
                        mdio_o <= 1'b1;
                        bit_counter <= bit_counter + 1'b1;
                    end else if (bit_counter < 7'd64) begin
                        mdio_t <= 1'b0;
                        mdio_o <= command2[bit_counter - 7'd32];
                        bit_counter <= bit_counter + 1'b1;
                    end else begin
                        mdio_t <= 1'b1;
                        mdio_o <= 1'b0;
                        bit_counter <= 7'b0;
                        state_reg <= GAP3; 
                    end
                end

                GAP3: begin
                    mdio_o <= 1'b0;
                    mdio_t <= 1'b1;
                    if (gap_counter < 7'd64) begin
                        gap_counter <= gap_counter + 1'b1;
                    end else begin
                        gap_counter <= 7'b0;
                        state_reg <= COMMAND3;
                        bit_counter <= 7'b0;
                    end
                end

                COMMAND3: begin
                    if (bit_counter < 7'd32) begin
                        mdio_t <= 1'b0;
                        mdio_o <= 1'b1;
                        bit_counter <= bit_counter + 1'b1;
                    end else if (bit_counter < 7'd64) begin
                        mdio_t <= 1'b0;
                        mdio_o <= command3[bit_counter - 7'd32];
                        bit_counter <= bit_counter + 1'b1;
                    end else begin
                        mdio_t <= 1'b1;
                        mdio_o <= 1'b0;
                        bit_counter <= 7'b0;
                        state_reg <= DONE; 
                    end
                end

                DONE: begin
                    mdio_t <= 1'b1;
                    mdio_o <= 1'b0;
                    bit_counter <= 7'b0;
                    gap_counter <= 7'b0;
                end

            endcase
            end 
        end
        end 

endmodule

`resetall

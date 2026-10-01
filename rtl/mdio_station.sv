/*

Copyright (c) 2026 George Fedorov
Language: SystemVerilog

*/


`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * MDIO master (station)
 */
module mdio_station #(
    parameter   ICLK_TO_MDC_FREQ_RATIO=40,
                PREAMBLE_LENGTH=32,
                PHY_ADDR_WIDTH=5,
                REG_ADDR_WIDTH=5,
                DATA_WIDTH=16
) (
    input   wire                        clk,
    input   wire                        rst,
    input   wire                        en,
    output  wire                        busy,
    output  reg                         err,

    input   wire [PHY_ADDR_WIDTH-1:0]   phy_addr,
    input   wire [REG_ADDR_WIDTH-1:0]   reg_addr,
    input   wire                        write,
    
    input   wire [DATA_WIDTH-1:0]       up_data,
    input   wire                        up_valid,
    output  reg                         up_ready,
    
    output  reg [DATA_WIDTH-1:0]        down_data,
    output  reg                         down_valid,
    input   wire                        down_ready,

    // MDIO interface
    output  wire                        mdc,
    input   wire                        mdio_i,
    output  wire                        mdio_o,
    output  wire                        mdio_t
);
    reg                      ce;

    reg                      mdio_i_r;
    reg                      mdio_o_r;
    reg                      mdio_t_r;
    reg                      mdio_o_next;
    reg                      mdio_t_next;
    
    reg [PHY_ADDR_WIDTH-1:0] phy_addr_r;
    reg [REG_ADDR_WIDTH-1:0] reg_addr_r;
    reg [DATA_WIDTH-1:0]     up_data_r;
    reg                      write_r;

    // Clock generation
    reg [$clog2(ICLK_TO_MDC_FREQ_RATIO):0] mdc_cnt;

    always @(posedge clk) begin
        if ( ( ~en ) |
             ( ~ce ) | 
             (  rst ) ) begin
            mdc_cnt <= 'b0;
        end else if ( ce && (mdc_cnt < (ICLK_TO_MDC_FREQ_RATIO - 1)) ) begin
            mdc_cnt <= mdc_cnt + 'd1;
        end else if ( ce ) begin
            mdc_cnt <= 'd0;
        end
    end

    assign mdc = ( mdc_cnt > ICLK_TO_MDC_FREQ_RATIO / 2 ) ? 1'b1 : 1'b0;

    // Bit counter
    reg [6:0] bit_cnt;
    reg       mdc_prev;

    // States of state machine
    enum logic [3:0] {
        IDLE     = 4'd0,
        PREAMBLE = 4'd1,
        START    = 4'd2,
        OPCODE   = 4'd3,
        PHY_ADDR = 4'd4,
        REG_ADDR = 4'd5,
        TA       = 4'd6,
        READ     = 4'd7,
        WRITE    = 4'd8
    } state, next_state;

    always_comb begin
        err = 'b0;
        ce  = 'b1;
        mdio_t_next = 'b1;
        mdio_o_next = 'b1;
        next_state  = state;

        case (state)
            IDLE: begin
                ce = 'b0;

                if (up_valid && up_ready) begin
                    mdio_t_next = 1'b1;

                    next_state = PREAMBLE;
                end else begin
                    next_state = IDLE;
                end
            end
            PREAMBLE: begin
                if (bit_cnt < (PREAMBLE_LENGTH - 1)) begin
                    mdio_t_next = 'b0;
                    mdio_o_next = 'b1;

                    next_state = PREAMBLE;
                end else begin
                    next_state = START;
                end
            end
            START: begin
                if (bit_cnt == 'd0) begin
                    mdio_t_next = 'b0;
                    mdio_o_next = 'b0;

                    next_state = START;
                end else if (bit_cnt == 'd1) begin
                    mdio_t_next = 'b0;
                    mdio_o_next = 'b1;

                    next_state = START;
                end else begin
                    mdio_t_next = 'b0;
                    mdio_o_next = 'b1;

                    next_state = OPCODE;
                end
            end
            OPCODE: begin
                if (write_r) begin
                    if (bit_cnt == 'd0) begin
                        mdio_t_next = 'b0;
                        mdio_o_next = 'b0;

                        next_state = OPCODE;
                    end else if (bit_cnt == 'd1) begin
                        mdio_t_next = 'b0;
                        mdio_o_next = 'b1;

                        next_state = OPCODE;
                    end else begin
                        mdio_t_next = 'b0;
                        mdio_o_next = 'b1;

                        next_state = PHY_ADDR;
                    end
                end else begin
                    if (bit_cnt == 'd0) begin
                        mdio_t_next = 'b0;
                        mdio_o_next = 'b1;

                        next_state = OPCODE;
                    end else if (bit_cnt == 'd1) begin
                        mdio_t_next = 'b0;
                        mdio_o_next = 'b0;

                        next_state = OPCODE;
                    end else begin
                        mdio_t_next = 'b0;
                        mdio_o_next = 'b0;

                        next_state = PHY_ADDR;
                    end
                end
            end
            PHY_ADDR: begin
                if (bit_cnt < PHY_ADDR_WIDTH) begin
                    mdio_t_next = 'b0;
                    mdio_o_next = phy_addr_r[PHY_ADDR_WIDTH-1-bit_cnt];

                    next_state = PHY_ADDR;
                end else begin
                    mdio_t_next = 'b0;
                    mdio_o_next = 'b0;

                    next_state = REG_ADDR;
                end
            end
            REG_ADDR: begin
                if (bit_cnt < REG_ADDR_WIDTH) begin
                    mdio_t_next = 'b0;
                    mdio_o_next = reg_addr_r[REG_ADDR_WIDTH-1-bit_cnt];

                    next_state = REG_ADDR;
                end else begin
                    mdio_t_next = 'b0;
                    mdio_o_next = 'b0;

                    next_state = TA;
                end
            end
            TA: begin
                if (write_r) begin
                    if (bit_cnt == 'd0) begin
                        mdio_t_next = 'b0;
                        mdio_o_next = 'b1;

                        next_state = TA;
                    end else if (bit_cnt == 'd1) begin
                        mdio_t_next = 'b0;
                        mdio_o_next = 'b0;

                        next_state = TA;
                    end else begin
                        mdio_t_next = 'b0;
                        mdio_o_next = 'b0;

                        next_state = WRITE;
                    end
                end else begin
                    if (bit_cnt == 'd0) begin
                        mdio_t_next = 'b1;
                        mdio_o_next = 'b1;

                        next_state = TA;
                    end else if (bit_cnt == 'd1) begin
                        mdio_t_next = 'b1;
                        mdio_o_next = 'b0;

                        if (~mdio_i_r) begin
                            next_state = READ;
                        end else begin
                            next_state = IDLE;
                            err        = 'b1;
                        end
                    end else begin
                        next_state = TA;
                    end
                end
            end
            WRITE: begin
                if (bit_cnt < DATA_WIDTH) begin
                    mdio_t_next = 'b0;
                    mdio_o_next = up_data_r[DATA_WIDTH-1-bit_cnt];

                    next_state = WRITE;
                end else begin
                    next_state = IDLE;
                end
            end
            READ: begin
                if (bit_cnt < DATA_WIDTH) begin
                    next_state = READ;
                end else if (down_ready) begin
                    next_state = IDLE;
                end else begin
                    ce         = 'b0;
                    next_state = READ;
                end
            end
            default: ;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) state <= IDLE;
        else     state <= next_state;
    end

    always_ff @(posedge clk) begin
        if (state == IDLE && next_state == IDLE)    up_ready <= 'b1;
        else                                        up_ready <= 'b0; 
    end

    // Bit counter
    always_ff @(posedge clk) begin
        mdc_prev <= mdc;
    end

    always_ff @(posedge clk) begin
        if (rst | (| (state ^ next_state))) bit_cnt <= 'd0;
        else if (mdc & (~mdc_prev))         bit_cnt <= bit_cnt + 'd1;
    end

    // Latching incoming values
    always_ff @(posedge clk) begin
        if (state == IDLE && (up_ready & up_valid)) begin
            phy_addr_r  <= phy_addr;
            reg_addr_r  <= reg_addr;
            up_data_r   <= up_data;
            write_r     <= write;
        end
    end

    // Posedge MDC logic
    always @(posedge clk) begin
        if (rst) begin
            down_data   <= 'd0;
            down_valid  <= 'd0;
        end else if ((~mdc) & mdc_prev && (state == READ)) begin
            down_data   <= { mdio_i, down_data[DATA_WIDTH-1:1] };
            down_valid  <= (bit_cnt == DATA_WIDTH) ? 'b1 : 'b0;
        end else if (down_valid & down_ready) begin
            down_valid  <= 'b0;
        end
    end

    // Negedge MDC logic
    always @(posedge clk) begin
        if (rst) begin
            mdio_o_r <= 'b1;
            mdio_t_r <= 'b1;
        end else if (mdc & (~mdc_prev)) begin
            mdio_o_r <= mdio_o_next;
            mdio_t_r <= mdio_t_next;
        end
    end

    assign mdio_o = mdio_o_r;
    assign mdio_t = mdio_t_r;
    assign busy   = (state != IDLE);

endmodule

/*

Copyright (c) 2016-2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * AXI4-Stream switch
 */
module axis_switch #
(
    // Number of AXI stream inputs
    parameter S_COUNT = 4,
    // Number of AXI stream outputs
    parameter M_COUNT = 4,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // input tid signal width
    parameter S_ID_WIDTH = 8,
    // output tid signal width
    parameter M_ID_WIDTH = S_ID_WIDTH+$clog2(S_COUNT),
    // output tdest signal width
    parameter M_DEST_WIDTH = 1,
    // input tdest signal width
    // must be wide enough to uniquely address outputs
    parameter S_DEST_WIDTH = M_DEST_WIDTH+$clog2(M_COUNT),
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // Output interface routing base tdest selection
    // Concatenate M_COUNT S_DEST_WIDTH sized constants
    // Port selected if M_BASE <= tdest <= M_TOP
    // set to zero for default routing with tdest MSBs as port index
    parameter M_BASE = 0,
    // Output interface routing top tdest selection
    // Concatenate M_COUNT S_DEST_WIDTH sized constants
    // Port selected if M_BASE <= tdest <= M_TOP
    // set to zero to inherit from M_BASE
    parameter M_TOP = 0,
    // Interface connection control
    // M_COUNT concatenated fields of S_COUNT bits
    parameter M_CONNECT = {M_COUNT{{S_COUNT{1'b1}}}},
    // Update tid with routing information
    parameter UPDATE_TID = 0,
    // Input interface register type
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S_REG_TYPE = 0,
    // Output interface register type
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M_REG_TYPE = 2,
    // select round robin arbitration
    parameter ARB_TYPE_ROUND_ROBIN = 1,
    // LSB priority selection
    parameter ARB_LSB_HIGH_PRIORITY = 1
)
(
    input  wire                             clk,
    input  wire                             rst,

    /*
     * AXI Stream inputs
     */
    input  wire [S_COUNT*DATA_WIDTH-1:0]    s_axis_tdata,
    input  wire [S_COUNT*KEEP_WIDTH-1:0]    s_axis_tkeep,
    input  wire [S_COUNT-1:0]               s_axis_tvalid,
    output wire [S_COUNT-1:0]               s_axis_tready,
    input  wire [S_COUNT-1:0]               s_axis_tlast,
    input  wire [S_COUNT*S_ID_WIDTH-1:0]    s_axis_tid,
    input  wire [S_COUNT*S_DEST_WIDTH-1:0]  s_axis_tdest,
    input  wire [S_COUNT*USER_WIDTH-1:0]    s_axis_tuser,

    /*
     * AXI Stream outputs
     */
    output wire [M_COUNT*DATA_WIDTH-1:0]    m_axis_tdata,
    output wire [M_COUNT*KEEP_WIDTH-1:0]    m_axis_tkeep,
    output wire [M_COUNT-1:0]               m_axis_tvalid,
    input  wire [M_COUNT-1:0]               m_axis_tready,
    output wire [M_COUNT-1:0]               m_axis_tlast,
    output wire [M_COUNT*M_ID_WIDTH-1:0]    m_axis_tid,
    output wire [M_COUNT*M_DEST_WIDTH-1:0]  m_axis_tdest,
    output wire [M_COUNT*USER_WIDTH-1:0]    m_axis_tuser
);

parameter CL_S_COUNT = $clog2(S_COUNT);
parameter CL_M_COUNT = $clog2(M_COUNT);

parameter S_ID_WIDTH_INT = S_ID_WIDTH > 0 ? S_ID_WIDTH : 1;
parameter M_DEST_WIDTH_INT = M_DEST_WIDTH > 0 ? M_DEST_WIDTH : 1;

integer i, j;

// check configuration
initial begin
    if (S_DEST_WIDTH < CL_M_COUNT) begin
        $error("Error: S_DEST_WIDTH too small for port count (instance %m)");
        $finish;
    end

    if (UPDATE_TID) begin
        if (!ID_ENABLE) begin
            $error("Error: UPDATE_TID set requires ID_ENABLE set (instance %m)");
            $finish;
        end

        if (M_ID_WIDTH < CL_S_COUNT) begin
            $error("Error: M_ID_WIDTH too small for port count (instance %m)");
            $finish;
        end
    end

    if (M_BASE == 0) begin
        // M_BASE is zero, route with tdest as port index
        $display("Addressing configuration for axis_switch instance %m");
        for (i = 0; i < M_COUNT; i = i + 1) begin
            $display("%d: %08x-%08x (connect mask %b)", i, i << (S_DEST_WIDTH-CL_M_COUNT), ((i+1) << (S_DEST_WIDTH-CL_M_COUNT))-1, M_CONNECT[i*S_COUNT +: S_COUNT]);
        end

    end else if (M_TOP == 0) begin
        // M_TOP is zero, assume equal to M_BASE
        $display("Addressing configuration for axis_switch instance %m");
        for (i = 0; i < M_COUNT; i = i + 1) begin
            $display("%d: %08x (connect mask %b)", i, M_BASE[i*S_DEST_WIDTH +: S_DEST_WIDTH], M_CONNECT[i*S_COUNT +: S_COUNT]);
        end

        for (i = 0; i < M_COUNT; i = i + 1) begin
            for (j = i+1; j < M_COUNT; j = j + 1) begin
                if (M_BASE[i*S_DEST_WIDTH +: S_DEST_WIDTH] == M_BASE[j*S_DEST_WIDTH +: S_DEST_WIDTH]) begin
                    $display("%d: %08x", i, M_BASE[i*S_DEST_WIDTH +: S_DEST_WIDTH]);
                    $display("%d: %08x", j, M_BASE[j*S_DEST_WIDTH +: S_DEST_WIDTH]);
                    $error("Error: ranges overlap (instance %m)");
                    $finish;
                end
            end
        end
    end else begin
        $display("Addressing configuration for axis_switch instance %m");
        for (i = 0; i < M_COUNT; i = i + 1) begin
            $display("%d: %08x-%08x (connect mask %b)", i, M_BASE[i*S_DEST_WIDTH +: S_DEST_WIDTH], M_TOP[i*S_DEST_WIDTH +: S_DEST_WIDTH], M_CONNECT[i*S_COUNT +: S_COUNT]);
        end

        for (i = 0; i < M_COUNT; i = i + 1) begin
            if (M_BASE[i*S_DEST_WIDTH +: S_DEST_WIDTH] > M_TOP[i*S_DEST_WIDTH +: S_DEST_WIDTH]) begin
                $error("Error: invalid range (instance %m)");
                $finish;
            end
        end

        for (i = 0; i < M_COUNT; i = i + 1) begin
            for (j = i+1; j < M_COUNT; j = j + 1) begin
                if (M_BASE[i*S_DEST_WIDTH +: S_DEST_WIDTH] <= M_TOP[j*S_DEST_WIDTH +: S_DEST_WIDTH] && M_BASE[j*S_DEST_WIDTH +: S_DEST_WIDTH] <= M_TOP[i*S_DEST_WIDTH +: S_DEST_WIDTH]) begin
                    $display("%d: %08x-%08x", i, M_BASE[i*S_DEST_WIDTH +: S_DEST_WIDTH], M_TOP[i*S_DEST_WIDTH +: S_DEST_WIDTH]);
                    $display("%d: %08x-%08x", j, M_BASE[j*S_DEST_WIDTH +: S_DEST_WIDTH], M_TOP[j*S_DEST_WIDTH +: S_DEST_WIDTH]);
                    $error("Error: ranges overlap (instance %m)");
                    $finish;
                end
            end
        end
    end
end

wire [S_COUNT*DATA_WIDTH-1:0]    int_s_axis_tdata;
wire [S_COUNT*KEEP_WIDTH-1:0]    int_s_axis_tkeep;
wire [S_COUNT-1:0]               int_s_axis_tvalid;
wire [S_COUNT-1:0]               int_s_axis_tready;
wire [S_COUNT-1:0]               int_s_axis_tlast;
wire [S_COUNT*S_ID_WIDTH-1:0]    int_s_axis_tid;
wire [S_COUNT*S_DEST_WIDTH-1:0]  int_s_axis_tdest;
wire [S_COUNT*USER_WIDTH-1:0]    int_s_axis_tuser;

wire [S_COUNT*M_COUNT-1:0]       int_axis_tvalid;
wire [M_COUNT*S_COUNT-1:0]       int_axis_tready;

generate

    genvar m, n;

    for (m = 0; m < S_COUNT; m = m + 1) begin : s_ifaces

        // decoding
        reg [CL_M_COUNT-1:0] select_reg = 0, select_next;
        reg drop_reg = 1'b0, drop_next;
        reg select_valid_reg = 1'b0, select_valid_next;

        integer k;

        always @* begin
            select_next = select_reg;
            drop_next = drop_reg && !(int_s_axis_tvalid[m] && int_s_axis_tready[m] && int_s_axis_tlast[m]);
            select_valid_next = select_valid_reg && !(int_s_axis_tvalid[m] && int_s_axis_tready[m] && int_s_axis_tlast[m]);

            if (int_s_axis_tvalid[m] && !select_valid_reg && !drop_reg) begin
                select_next = 0;
                select_valid_next = 1'b0;
                drop_next = 1'b1;
                for (k = 0; k < M_COUNT; k = k + 1) begin
                    if (M_BASE == 0) begin
                        if (M_COUNT == 1) begin
                            // M_BASE is zero with only one output port, ignore tdest
                            select_next = 0;
                            select_valid_next = 1'b1;
                            drop_next = 1'b0;
                        end else begin
                            // M_BASE is zero, route with $clog2(M_COUNT) MSBs of tdest as port index
                            if (int_s_axis_tdest[m*S_DEST_WIDTH+(S_DEST_WIDTH-CL_M_COUNT) +: CL_M_COUNT] == k && (M_CONNECT & (1 << (m+k*S_COUNT)))) begin
                                select_next = k;
                                select_valid_next = 1'b1;
                                drop_next = 1'b0;
                            end
                        end
                    end else if (M_TOP == 0) begin
                        // M_TOP is zero, assume equal to M_BASE
                        if (int_s_axis_tdest[m*S_DEST_WIDTH +: S_DEST_WIDTH] == M_BASE[k*S_DEST_WIDTH +: S_DEST_WIDTH] && (M_CONNECT & (1 << (m+k*S_COUNT)))) begin
                            select_next = k;
                            select_valid_next = 1'b1;
                            drop_next = 1'b0;
                        end
                    end else begin
                        if (int_s_axis_tdest[m*S_DEST_WIDTH +: S_DEST_WIDTH] >= M_BASE[k*S_DEST_WIDTH +: S_DEST_WIDTH] && int_s_axis_tdest[m*S_DEST_WIDTH +: S_DEST_WIDTH] <= M_TOP[k*S_DEST_WIDTH +: S_DEST_WIDTH] && (M_CONNECT & (1 << (m+k*S_COUNT)))) begin
                            select_next = k;
                            select_valid_next = 1'b1;
                            drop_next = 1'b0;
                        end
                    end
                end
            end
        end

        always @(posedge clk) begin
            if (rst) begin
                select_valid_reg <= 1'b0;
            end else begin
                select_valid_reg <= select_valid_next;
            end

            select_reg <= select_next;
            drop_reg <= drop_next;
        end

        // forwarding
        assign int_axis_tvalid[m*M_COUNT +: M_COUNT] = (int_s_axis_tvalid[m] && select_valid_reg && !drop_reg) << select_reg;
        assign int_s_axis_tready[m] = int_axis_tready[select_reg*S_COUNT+m] || drop_reg;

        // S side register
        axis_register #(
            .DATA_WIDTH(DATA_WIDTH),
            .KEEP_ENABLE(KEEP_ENABLE),
            .KEEP_WIDTH(KEEP_WIDTH),
            .LAST_ENABLE(1),
            .ID_ENABLE(ID_ENABLE && S_ID_WIDTH > 0),
            .ID_WIDTH(S_ID_WIDTH_INT),
            .DEST_ENABLE(1),
            .DEST_WIDTH(S_DEST_WIDTH),
            .USER_ENABLE(USER_ENABLE),
            .USER_WIDTH(USER_WIDTH),
            .REG_TYPE(S_REG_TYPE)
        )
        reg_inst (
            .clk(clk),
            .rst(rst),
            // AXI input
            .s_axis_tdata(s_axis_tdata[m*DATA_WIDTH +: DATA_WIDTH]),
            .s_axis_tkeep(s_axis_tkeep[m*KEEP_WIDTH +: KEEP_WIDTH]),
            .s_axis_tvalid(s_axis_tvalid[m]),
            .s_axis_tready(s_axis_tready[m]),
            .s_axis_tlast(s_axis_tlast[m]),
            .s_axis_tid(s_axis_tid[m*S_ID_WIDTH +: S_ID_WIDTH_INT]),
            .s_axis_tdest(s_axis_tdest[m*S_DEST_WIDTH +: S_DEST_WIDTH]),
            .s_axis_tuser(s_axis_tuser[m*USER_WIDTH +: USER_WIDTH]),
            // AXI output
            .m_axis_tdata(int_s_axis_tdata[m*DATA_WIDTH +: DATA_WIDTH]),
            .m_axis_tkeep(int_s_axis_tkeep[m*KEEP_WIDTH +: KEEP_WIDTH]),
            .m_axis_tvalid(int_s_axis_tvalid[m]),
            .m_axis_tready(int_s_axis_tready[m]),
            .m_axis_tlast(int_s_axis_tlast[m]),
            .m_axis_tid(int_s_axis_tid[m*S_ID_WIDTH +: S_ID_WIDTH_INT]),
            .m_axis_tdest(int_s_axis_tdest[m*S_DEST_WIDTH +: S_DEST_WIDTH]),
            .m_axis_tuser(int_s_axis_tuser[m*USER_WIDTH +: USER_WIDTH])
        );
    end // s_ifaces

    for (n = 0; n < M_COUNT; n = n + 1) begin : m_ifaces

        // arbitration
        wire [S_COUNT-1:0] request;
        wire [S_COUNT-1:0] acknowledge;
        wire [S_COUNT-1:0] grant;
        wire grant_valid;
        wire [CL_S_COUNT-1:0] grant_encoded;

        arbiter #(
            .PORTS(S_COUNT),
            .ARB_TYPE_ROUND_ROBIN(ARB_TYPE_ROUND_ROBIN),
            .ARB_BLOCK(1),
            .ARB_BLOCK_ACK(1),
            .ARB_LSB_HIGH_PRIORITY(ARB_LSB_HIGH_PRIORITY)
        )
        arb_inst (
            .clk(clk),
            .rst(rst),
            .request(request),
            .acknowledge(acknowledge),
            .grant(grant),
            .grant_valid(grant_valid),
            .grant_encoded(grant_encoded)
        );

        // mux
        reg  [DATA_WIDTH-1:0]    m_axis_tdata_mux;
        reg  [KEEP_WIDTH-1:0]    m_axis_tkeep_mux;
        reg                      m_axis_tvalid_mux;
        wire                     m_axis_tready_mux;
        reg                      m_axis_tlast_mux;
        reg  [M_ID_WIDTH-1:0]    m_axis_tid_mux;
        reg  [M_DEST_WIDTH-1:0]  m_axis_tdest_mux;
        reg  [USER_WIDTH-1:0]    m_axis_tuser_mux;

        always @* begin
            m_axis_tdata_mux   = int_s_axis_tdata[grant_encoded*DATA_WIDTH +: DATA_WIDTH];
            m_axis_tkeep_mux   = int_s_axis_tkeep[grant_encoded*KEEP_WIDTH +: KEEP_WIDTH];
            m_axis_tvalid_mux  = int_axis_tvalid[grant_encoded*M_COUNT+n] && grant_valid;
            m_axis_tlast_mux   = int_s_axis_tlast[grant_encoded];
            m_axis_tid_mux     = int_s_axis_tid[grant_encoded*S_ID_WIDTH +: S_ID_WIDTH_INT];
            if (UPDATE_TID && S_COUNT > 1) begin
                m_axis_tid_mux[M_ID_WIDTH-1:M_ID_WIDTH-CL_S_COUNT] = grant_encoded;
            end
            m_axis_tdest_mux   = int_s_axis_tdest[grant_encoded*S_DEST_WIDTH +: S_DEST_WIDTH];
            m_axis_tuser_mux   = int_s_axis_tuser[grant_encoded*USER_WIDTH +: USER_WIDTH];
        end

        assign int_axis_tready[n*S_COUNT +: S_COUNT] = (grant_valid && m_axis_tready_mux) << grant_encoded;

        for (m = 0; m < S_COUNT; m = m + 1) begin
            assign request[m] = int_axis_tvalid[m*M_COUNT+n] && !grant[m];
            assign acknowledge[m] = grant[m] && int_axis_tvalid[m*M_COUNT+n] && m_axis_tlast_mux && m_axis_tready_mux;
        end

        // M side register
        axis_register #(
            .DATA_WIDTH(DATA_WIDTH),
            .KEEP_ENABLE(KEEP_ENABLE),
            .KEEP_WIDTH(KEEP_WIDTH),
            .LAST_ENABLE(1),
            .ID_ENABLE(ID_ENABLE),
            .ID_WIDTH(M_ID_WIDTH),
            .DEST_ENABLE(M_DEST_WIDTH > 0),
            .DEST_WIDTH(M_DEST_WIDTH_INT),
            .USER_ENABLE(USER_ENABLE),
            .USER_WIDTH(USER_WIDTH),
            .REG_TYPE(M_REG_TYPE)
        )
        reg_inst (
            .clk(clk),
            .rst(rst),
            // AXI input
            .s_axis_tdata(m_axis_tdata_mux),
            .s_axis_tkeep(m_axis_tkeep_mux),
            .s_axis_tvalid(m_axis_tvalid_mux),
            .s_axis_tready(m_axis_tready_mux),
            .s_axis_tlast(m_axis_tlast_mux),
            .s_axis_tid(m_axis_tid_mux),
            .s_axis_tdest(m_axis_tdest_mux),
            .s_axis_tuser(m_axis_tuser_mux),
            // AXI output
            .m_axis_tdata(m_axis_tdata[n*DATA_WIDTH +: DATA_WIDTH]),
            .m_axis_tkeep(m_axis_tkeep[n*KEEP_WIDTH +: KEEP_WIDTH]),
            .m_axis_tvalid(m_axis_tvalid[n]),
            .m_axis_tready(m_axis_tready[n]),
            .m_axis_tlast(m_axis_tlast[n]),
            .m_axis_tid(m_axis_tid[n*M_ID_WIDTH +: M_ID_WIDTH]),
            .m_axis_tdest(m_axis_tdest[n*M_DEST_WIDTH +: M_DEST_WIDTH_INT]),
            .m_axis_tuser(m_axis_tuser[n*USER_WIDTH +: USER_WIDTH])
        );
    end // m_ifaces

endgenerate

endmodule

`resetall

/*

Copyright (c) 2020 Alex Forencich

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
 * AXI4-Stream RAM switch
 */
module axis_ram_switch #
(
    // FIFO depth in words (each virtual FIFO)
    // KEEP_WIDTH words per cycle if KEEP_ENABLE set
    // Rounded up to nearest power of 2 cycles
    parameter FIFO_DEPTH = 4096,
    // Command FIFO depth (each virtual FIFO)
    // Rounded up to nearest power of 2
    parameter CMD_FIFO_DEPTH = 32,
    // Speedup factor (internal data width scaling factor)
    // Speedup of 0 scales internal width to provide maximum bandwidth
    parameter SPEEDUP = 0,
    // Number of AXI stream inputs
    parameter S_COUNT = 4,
    // Number of AXI stream outputs
    parameter M_COUNT = 4,
    // Width of input AXI stream interfaces in bits
    parameter S_DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter S_KEEP_ENABLE = (S_DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter S_KEEP_WIDTH = (S_DATA_WIDTH/8),
    // Width of output AXI stream interfaces in bits
    parameter M_DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter M_KEEP_ENABLE = (M_DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter M_KEEP_WIDTH = (M_DATA_WIDTH/8),
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
    // tuser value for bad frame marker
    parameter USER_BAD_FRAME_VALUE = 1'b1,
    // tuser mask for bad frame marker
    parameter USER_BAD_FRAME_MASK = 1'b1,
    // Drop frames marked bad
    parameter DROP_BAD_FRAME = 0,
    // Drop incoming frames when full
    // When set, s_axis_tready is always asserted
    parameter DROP_WHEN_FULL = 0,
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
    // select round robin arbitration
    parameter ARB_TYPE_ROUND_ROBIN = 1,
    // LSB priority selection
    parameter ARB_LSB_HIGH_PRIORITY = 1,
    // RAM read data output pipeline stages
    parameter RAM_PIPELINE = 2
)
(
    input  wire                             clk,
    input  wire                             rst,

    /*
     * AXI Stream inputs
     */
    input  wire [S_COUNT*S_DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire [S_COUNT*S_KEEP_WIDTH-1:0]  s_axis_tkeep,
    input  wire [S_COUNT-1:0]               s_axis_tvalid,
    output wire [S_COUNT-1:0]               s_axis_tready,
    input  wire [S_COUNT-1:0]               s_axis_tlast,
    input  wire [S_COUNT*S_ID_WIDTH-1:0]    s_axis_tid,
    input  wire [S_COUNT*S_DEST_WIDTH-1:0]  s_axis_tdest,
    input  wire [S_COUNT*USER_WIDTH-1:0]    s_axis_tuser,

    /*
     * AXI Stream outputs
     */
    output wire [M_COUNT*M_DATA_WIDTH-1:0]  m_axis_tdata,
    output wire [M_COUNT*M_KEEP_WIDTH-1:0]  m_axis_tkeep,
    output wire [M_COUNT-1:0]               m_axis_tvalid,
    input  wire [M_COUNT-1:0]               m_axis_tready,
    output wire [M_COUNT-1:0]               m_axis_tlast,
    output wire [M_COUNT*M_ID_WIDTH-1:0]    m_axis_tid,
    output wire [M_COUNT*M_DEST_WIDTH-1:0]  m_axis_tdest,
    output wire [M_COUNT*USER_WIDTH-1:0]    m_axis_tuser,

    /*
     * Status
     */
    output wire [S_COUNT-1:0]               status_overflow,
    output wire [S_COUNT-1:0]               status_bad_frame,
    output wire [S_COUNT-1:0]               status_good_frame
);

parameter CL_S_COUNT = $clog2(S_COUNT);
parameter CL_M_COUNT = $clog2(M_COUNT);

parameter S_ID_WIDTH_INT = S_ID_WIDTH > 0 ? S_ID_WIDTH : 1;
parameter M_DEST_WIDTH_INT = M_DEST_WIDTH > 0 ? M_DEST_WIDTH : 1;

// force keep width to 1 when disabled
parameter S_KEEP_WIDTH_INT = S_KEEP_ENABLE ? S_KEEP_WIDTH : 1;
parameter M_KEEP_WIDTH_INT = M_KEEP_ENABLE ? M_KEEP_WIDTH : 1;

// bus word sizes (must be identical)
parameter S_DATA_WORD_SIZE = S_DATA_WIDTH / S_KEEP_WIDTH_INT;
parameter M_DATA_WORD_SIZE = M_DATA_WIDTH / M_KEEP_WIDTH_INT;
// total data and keep widths
parameter MIN_DATA_WIDTH = (M_KEEP_WIDTH_INT > S_KEEP_WIDTH_INT ? M_DATA_WIDTH : S_DATA_WIDTH);
parameter MIN_KEEP_WIDTH = (M_KEEP_WIDTH_INT > S_KEEP_WIDTH_INT ? M_KEEP_WIDTH_INT : S_KEEP_WIDTH_INT);
// speedup factor
parameter M_TOTAL_DATA_WIDTH = M_DATA_WIDTH*M_COUNT;
parameter S_TOTAL_DATA_WIDTH = S_DATA_WIDTH*S_COUNT;
parameter SPEEDUP_INT = SPEEDUP > 0 ? SPEEDUP : (M_TOTAL_DATA_WIDTH > S_TOTAL_DATA_WIDTH ? (M_TOTAL_DATA_WIDTH / MIN_DATA_WIDTH) : (S_TOTAL_DATA_WIDTH / MIN_DATA_WIDTH));
parameter DATA_WIDTH = MIN_DATA_WIDTH*SPEEDUP_INT;
parameter KEEP_WIDTH = MIN_KEEP_WIDTH*SPEEDUP_INT;

parameter ADDR_WIDTH = $clog2(FIFO_DEPTH/KEEP_WIDTH);
parameter RAM_ADDR_WIDTH = $clog2(S_COUNT*FIFO_DEPTH/KEEP_WIDTH);

parameter CMD_ADDR_WIDTH = $clog2(CMD_FIFO_DEPTH);

integer i, j;

// check configuration
initial begin
    if (S_DATA_WORD_SIZE * S_KEEP_WIDTH_INT != S_DATA_WIDTH) begin
        $error("Error: input data width not evenly divisble (instance %m)");
        $finish;
    end

    if (M_DATA_WORD_SIZE * M_KEEP_WIDTH_INT != M_DATA_WIDTH) begin
        $error("Error: output data width not evenly divisble (instance %m)");
        $finish;
    end

    if (S_DATA_WORD_SIZE != M_DATA_WORD_SIZE) begin
        $error("Error: word size mismatch (instance %m)");
        $finish;
    end

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

// Shared RAM
reg [DATA_WIDTH-1:0] mem[(2**RAM_ADDR_WIDTH)-1:0];
reg [DATA_WIDTH-1:0] mem_read_data_reg[RAM_PIPELINE-1:0];
reg [M_COUNT-1:0] mem_read_data_valid_reg[RAM_PIPELINE-1:0];

wire [S_COUNT*DATA_WIDTH-1:0]     port_ram_wr_data;
wire [S_COUNT*RAM_ADDR_WIDTH-1:0] port_ram_wr_addr;
wire [S_COUNT-1:0]                port_ram_wr_en;
wire [S_COUNT-1:0]                port_ram_wr_ack;

wire [M_COUNT*RAM_ADDR_WIDTH-1:0] port_ram_rd_addr;
wire [M_COUNT-1:0]                port_ram_rd_en;
wire [M_COUNT-1:0]                port_ram_rd_ack;
wire [M_COUNT*DATA_WIDTH-1:0]     port_ram_rd_data;
wire [M_COUNT-1:0]                port_ram_rd_data_valid;

assign port_ram_rd_data = {M_COUNT{mem_read_data_reg[RAM_PIPELINE-1]}};
assign port_ram_rd_data_valid = mem_read_data_valid_reg[RAM_PIPELINE-1];

wire [CL_S_COUNT-1:0] ram_wr_sel;
wire ram_wr_en;

wire [CL_M_COUNT-1:0] ram_rd_sel;
wire ram_rd_en;

generate

if (S_COUNT > 1) begin

    arbiter #(
        .PORTS(S_COUNT),
        .ARB_TYPE_ROUND_ROBIN(1),
        .ARB_BLOCK(0),
        .ARB_LSB_HIGH_PRIORITY(1)
    )
    ram_write_arb_inst (
        .clk(clk),
        .rst(rst),
        .request(port_ram_wr_en & ~port_ram_wr_ack),
        .acknowledge({S_COUNT{1'b0}}),
        .grant(port_ram_wr_ack),
        .grant_valid(ram_wr_en),
        .grant_encoded(ram_wr_sel)
    );

end else begin

    assign ram_wr_en = port_ram_wr_en;
    assign port_ram_wr_ack = port_ram_wr_en;
    assign ram_wr_sel = 0;

end

endgenerate

always @(posedge clk) begin
    if (ram_wr_en) begin
        mem[port_ram_wr_addr[ram_wr_sel*RAM_ADDR_WIDTH +: RAM_ADDR_WIDTH]] <= port_ram_wr_data[ram_wr_sel*DATA_WIDTH +: DATA_WIDTH];
    end
end

generate

if (M_COUNT > 1) begin

    arbiter #(
        .PORTS(M_COUNT),
        .ARB_TYPE_ROUND_ROBIN(1),
        .ARB_BLOCK(0),
        .ARB_LSB_HIGH_PRIORITY(1)
    )
    ram_read_arb_inst (
        .clk(clk),
        .rst(rst),
        .request(port_ram_rd_en & ~port_ram_rd_ack),
        .acknowledge({M_COUNT{1'b0}}),
        .grant(port_ram_rd_ack),
        .grant_valid(ram_rd_en),
        .grant_encoded(ram_rd_sel)
    );

end else begin

    assign ram_rd_en = port_ram_rd_en;
    assign port_ram_rd_ack = port_ram_rd_en;
    assign ram_rd_sel = 0;

end

endgenerate

integer s;

always @(posedge clk) begin
    mem_read_data_valid_reg[0] <= 0;

    for (s = RAM_PIPELINE-1; s > 0; s = s - 1) begin
        mem_read_data_reg[s] <= mem_read_data_reg[s-1];
        mem_read_data_valid_reg[s] <= mem_read_data_valid_reg[s-1];
    end

    if (ram_rd_en) begin
        mem_read_data_reg[0] <= mem[port_ram_rd_addr[ram_rd_sel*RAM_ADDR_WIDTH +: RAM_ADDR_WIDTH]];
        mem_read_data_valid_reg[0] <= 1 << ram_rd_sel;
    end

    if (rst) begin
        mem_read_data_valid_reg[0] <= 0;
        for (s = 0; s < RAM_PIPELINE; s = s + 1) begin
            mem_read_data_valid_reg[s] <= 0;
        end
    end
end

// Interconnect
wire [S_COUNT*RAM_ADDR_WIDTH-1:0]  int_cmd_addr;
wire [S_COUNT*ADDR_WIDTH-1:0]      int_cmd_len;
wire [S_COUNT*CMD_ADDR_WIDTH-1:0]  int_cmd_id;
wire [S_COUNT*KEEP_WIDTH-1:0]      int_cmd_tkeep;
wire [S_COUNT*S_ID_WIDTH-1:0]      int_cmd_tid;
wire [S_COUNT*S_DEST_WIDTH-1:0]    int_cmd_tdest;
wire [S_COUNT*USER_WIDTH-1:0]      int_cmd_tuser;

wire [S_COUNT*M_COUNT-1:0]         int_cmd_valid;
wire [M_COUNT*S_COUNT-1:0]         int_cmd_ready;

wire [M_COUNT*CMD_ADDR_WIDTH-1:0]  int_cmd_status_id;

wire [M_COUNT*S_COUNT-1:0]         int_cmd_status_valid;
wire [S_COUNT*M_COUNT-1:0]         int_cmd_status_ready;

generate

    genvar m, n;

    for (m = 0; m < S_COUNT; m = m + 1) begin : s_ifaces

        wire [DATA_WIDTH-1:0]    port_axis_tdata;
        wire [KEEP_WIDTH-1:0]    port_axis_tkeep;
        wire                     port_axis_tvalid;
        wire                     port_axis_tready;
        wire                     port_axis_tlast;
        wire [S_ID_WIDTH-1:0]    port_axis_tid;
        wire [S_DEST_WIDTH-1:0]  port_axis_tdest;
        wire [USER_WIDTH-1:0]    port_axis_tuser;

        axis_adapter #(
            .S_DATA_WIDTH(S_DATA_WIDTH),
            .S_KEEP_ENABLE(S_KEEP_ENABLE),
            .S_KEEP_WIDTH(S_KEEP_WIDTH),
            .M_DATA_WIDTH(DATA_WIDTH),
            .M_KEEP_ENABLE(1),
            .M_KEEP_WIDTH(KEEP_WIDTH),
            .ID_ENABLE(ID_ENABLE && S_ID_WIDTH > 0),
            .ID_WIDTH(S_ID_WIDTH_INT),
            .DEST_ENABLE(1),
            .DEST_WIDTH(S_DEST_WIDTH),
            .USER_ENABLE(USER_ENABLE),
            .USER_WIDTH(USER_WIDTH)
        )
        adapter_inst (
            .clk(clk),
            .rst(rst),
            // AXI input
            .s_axis_tdata(s_axis_tdata[S_DATA_WIDTH*m +: S_DATA_WIDTH]),
            .s_axis_tkeep(s_axis_tkeep[S_KEEP_WIDTH*m +: S_KEEP_WIDTH]),
            .s_axis_tvalid(s_axis_tvalid[m]),
            .s_axis_tready(s_axis_tready[m]),
            .s_axis_tlast(s_axis_tlast[m]),
            .s_axis_tid(s_axis_tid[S_ID_WIDTH*m +: S_ID_WIDTH_INT]),
            .s_axis_tdest(s_axis_tdest[S_DEST_WIDTH*m +: S_DEST_WIDTH]),
            .s_axis_tuser(s_axis_tuser[USER_WIDTH*m +: USER_WIDTH]),
            // AXI output
            .m_axis_tdata(port_axis_tdata),
            .m_axis_tkeep(port_axis_tkeep),
            .m_axis_tvalid(port_axis_tvalid),
            .m_axis_tready(port_axis_tready),
            .m_axis_tlast(port_axis_tlast),
            .m_axis_tid(port_axis_tid),
            .m_axis_tdest(port_axis_tdest),
            .m_axis_tuser(port_axis_tuser)
        );

        // decoding
        reg [CL_M_COUNT-1:0] select_reg = 0, select_next;
        reg drop_reg = 1'b0, drop_next;
        reg select_valid_reg = 1'b0, select_valid_next;

        integer k;

        always @* begin
            select_next = select_reg;
            drop_next = drop_reg && !(port_axis_tvalid && port_axis_tready && port_axis_tlast);
            select_valid_next = select_valid_reg && !(port_axis_tvalid && port_axis_tready && port_axis_tlast);

            if (port_axis_tvalid && !select_valid_reg && !drop_reg) begin
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
                            if (port_axis_tdest[S_DEST_WIDTH-CL_M_COUNT +: CL_M_COUNT] == k && (M_CONNECT & (1 << (m+k*S_COUNT)))) begin
                                select_next = k;
                                select_valid_next = 1'b1;
                                drop_next = 1'b0;
                            end
                        end
                    end else if (M_TOP == 0) begin
                        // M_TOP is zero, assume equal to M_BASE
                        if (port_axis_tdest == M_BASE[k*S_DEST_WIDTH +: S_DEST_WIDTH] && (M_CONNECT & (1 << (m+k*S_COUNT)))) begin
                            select_next = k;
                            select_valid_next = 1'b1;
                            drop_next = 1'b0;
                        end
                    end else begin
                        if (port_axis_tdest >= M_BASE[k*S_DEST_WIDTH +: S_DEST_WIDTH] && port_axis_tdest <= M_TOP[k*S_DEST_WIDTH +: S_DEST_WIDTH] && (M_CONNECT & (1 << (m+k*S_COUNT)))) begin
                            select_next = k;
                            select_valid_next = 1'b1;
                            drop_next = 1'b0;
                        end
                    end
                end
            end
        end

        always @(posedge clk) begin
            select_reg <= select_next;
            drop_reg <= drop_next;
            select_valid_reg <= select_valid_next;

            if (rst) begin
                select_valid_reg <= 1'b0;
            end
        end

        // status arbitration
        wire [M_COUNT-1:0] request;
        wire [M_COUNT-1:0] acknowledge;
        wire [M_COUNT-1:0] grant;
        wire grant_valid;
        wire [CL_M_COUNT-1:0] grant_encoded;

        arbiter #(
            .PORTS(M_COUNT),
            .ARB_TYPE_ROUND_ROBIN(ARB_TYPE_ROUND_ROBIN),
            .ARB_BLOCK(1),
            .ARB_BLOCK_ACK(1),
            .ARB_LSB_HIGH_PRIORITY(ARB_LSB_HIGH_PRIORITY)
        )
        cmd_status_arb_inst (
            .clk(clk),
            .rst(rst),
            .request(request),
            .acknowledge(acknowledge),
            .grant(grant),
            .grant_valid(grant_valid),
            .grant_encoded(grant_encoded)
        );

        // mux
        wire [CMD_ADDR_WIDTH-1:0] cmd_status_id_mux    = int_cmd_status_id[grant_encoded*CMD_ADDR_WIDTH +: CMD_ADDR_WIDTH];
        wire                      cmd_status_valid_mux = int_cmd_status_valid[grant_encoded*S_COUNT+m] && grant_valid;
        wire                      cmd_status_ready_mux;

        assign int_cmd_status_ready[m*M_COUNT +: M_COUNT] = (grant_valid && cmd_status_ready_mux) << grant_encoded;

        for (n = 0; n < M_COUNT; n = n + 1) begin
            assign request[n] = int_cmd_status_valid[m+n*S_COUNT] && !grant[n];
            assign acknowledge[n] = grant[n] && int_cmd_status_valid[m+n*S_COUNT] && cmd_status_ready_mux;
        end

        reg [ADDR_WIDTH:0] wr_ptr_reg = {ADDR_WIDTH+1{1'b0}}, wr_ptr_next;
        reg [ADDR_WIDTH:0] wr_ptr_cur_reg = {ADDR_WIDTH+1{1'b0}}, wr_ptr_cur_next;
        reg [ADDR_WIDTH:0] rd_ptr_reg = {ADDR_WIDTH+1{1'b0}}, rd_ptr_next;

        reg [ADDR_WIDTH-1:0] len_reg = {ADDR_WIDTH{1'b0}}, len_next;

        // full when first MSB different but rest same
        wire full = wr_ptr_cur_reg == (rd_ptr_reg ^ {1'b1, {ADDR_WIDTH{1'b0}}});
        // empty when pointers match exactly
        wire empty = wr_ptr_reg == rd_ptr_reg;
        // overflow within packet
        wire full_wr = wr_ptr_cur_reg == (wr_ptr_reg ^ {1'b1, {ADDR_WIDTH{1'b0}}});

        reg drop_frame_reg = 1'b0, drop_frame_next;
        reg overflow_reg = 1'b0, overflow_next;
        reg bad_frame_reg = 1'b0, bad_frame_next;
        reg good_frame_reg = 1'b0, good_frame_next;

        reg [DATA_WIDTH-1:0] ram_wr_data_reg = {DATA_WIDTH{1'b0}}, ram_wr_data_next;
        reg [ADDR_WIDTH-1:0] ram_wr_addr_reg = {ADDR_WIDTH{1'b0}}, ram_wr_addr_next;
        reg                  ram_wr_en_reg = 1'b0, ram_wr_en_next;
        wire                 ram_wr_ack;

        reg [2**CMD_ADDR_WIDTH-1:0] cmd_table_active = 0;
        reg [2**CMD_ADDR_WIDTH-1:0] cmd_table_commit = 0;
        reg [RAM_ADDR_WIDTH+1-1:0] cmd_table_addr_start[2**CMD_ADDR_WIDTH-1:0];
        reg [RAM_ADDR_WIDTH+1-1:0] cmd_table_addr_end[2**CMD_ADDR_WIDTH-1:0];
        reg [ADDR_WIDTH-1:0] cmd_table_len[2**CMD_ADDR_WIDTH-1:0];
        reg [CL_M_COUNT-1:0] cmd_table_select[2**CMD_ADDR_WIDTH-1:0];
        reg [KEEP_WIDTH-1:0] cmd_table_tkeep[2**CMD_ADDR_WIDTH-1:0];
        reg [S_ID_WIDTH-1:0] cmd_table_tid[2**CMD_ADDR_WIDTH-1:0];
        reg [S_DEST_WIDTH-1:0] cmd_table_tdest[2**CMD_ADDR_WIDTH-1:0];
        reg [USER_WIDTH-1:0] cmd_table_tuser[2**CMD_ADDR_WIDTH-1:0];

        reg [CMD_ADDR_WIDTH+1-1:0] cmd_table_start_ptr_reg = 0;
        reg [RAM_ADDR_WIDTH+1-1:0] cmd_table_start_addr_start;
        reg [RAM_ADDR_WIDTH+1-1:0] cmd_table_start_addr_end;
        reg [ADDR_WIDTH-1:0] cmd_table_start_len;
        reg [CL_M_COUNT-1:0] cmd_table_start_select;
        reg [KEEP_WIDTH-1:0] cmd_table_start_tkeep;
        reg [S_ID_WIDTH-1:0] cmd_table_start_tid;
        reg [S_DEST_WIDTH-1:0] cmd_table_start_tdest;
        reg [USER_WIDTH-1:0] cmd_table_start_tuser;
        reg cmd_table_start_en;
        reg [CMD_ADDR_WIDTH+1-1:0] cmd_table_read_ptr_reg = 0;
        reg cmd_table_read_en;
        reg [CMD_ADDR_WIDTH-1:0] cmd_table_commit_ptr;
        reg cmd_table_commit_en;
        reg [CMD_ADDR_WIDTH+1-1:0] cmd_table_finish_ptr_reg = 0;
        reg cmd_table_finish_en;

        reg [RAM_ADDR_WIDTH-1:0]  cmd_addr_reg = {RAM_ADDR_WIDTH{1'b0}}, cmd_addr_next;
        reg [ADDR_WIDTH-1:0]      cmd_len_reg = {ADDR_WIDTH{1'b0}}, cmd_len_next;
        reg [CMD_ADDR_WIDTH-1:0]  cmd_id_reg = {CMD_ADDR_WIDTH{1'b0}}, cmd_id_next;
        reg [KEEP_WIDTH-1:0]      cmd_tkeep_reg = {KEEP_WIDTH{1'b0}}, cmd_tkeep_next;
        reg [S_ID_WIDTH-1:0]      cmd_tid_reg = {S_ID_WIDTH_INT{1'b0}}, cmd_tid_next;
        reg [S_DEST_WIDTH-1:0]    cmd_tdest_reg = {S_DEST_WIDTH{1'b0}}, cmd_tdest_next;
        reg [USER_WIDTH-1:0]      cmd_tuser_reg = {USER_WIDTH{1'b0}}, cmd_tuser_next;
        reg [M_COUNT-1:0]         cmd_valid_reg = 0, cmd_valid_next;

        reg cmd_status_ready_reg = 1'b0, cmd_status_ready_next;

        wire [M_COUNT-1:0] port_cmd_ready;
        for (n = 0; n < M_COUNT; n = n + 1) begin
            assign port_cmd_ready[n] = int_cmd_ready[m+n*S_COUNT];
        end

        assign port_axis_tready = (select_valid_reg && (!ram_wr_en_reg || ram_wr_ack) && (!full || full_wr || DROP_WHEN_FULL) && ($unsigned(cmd_table_start_ptr_reg - cmd_table_finish_ptr_reg) < 2**CMD_ADDR_WIDTH)) || drop_reg;

        assign port_ram_wr_data[m*DATA_WIDTH +: DATA_WIDTH] = ram_wr_data_reg;
        assign port_ram_wr_addr[m*RAM_ADDR_WIDTH +: RAM_ADDR_WIDTH] = ram_wr_addr_reg[ADDR_WIDTH-1:0] | (m << ADDR_WIDTH);
        assign port_ram_wr_en[m] = ram_wr_en_reg;
        assign ram_wr_ack = port_ram_wr_ack[m];

        assign int_cmd_addr[m*RAM_ADDR_WIDTH +: RAM_ADDR_WIDTH] = cmd_addr_reg[ADDR_WIDTH-1:0] | (m << ADDR_WIDTH);
        assign int_cmd_len[m*ADDR_WIDTH +: ADDR_WIDTH] = cmd_len_reg;
        assign int_cmd_id[m*CMD_ADDR_WIDTH +: CMD_ADDR_WIDTH] = cmd_id_reg;
        assign int_cmd_tkeep[m*KEEP_WIDTH +: KEEP_WIDTH] = cmd_tkeep_reg;
        assign int_cmd_tid[m*S_ID_WIDTH +: S_ID_WIDTH_INT] = cmd_tid_reg;
        assign int_cmd_tdest[m*S_DEST_WIDTH +: S_DEST_WIDTH] = cmd_tdest_reg;
        assign int_cmd_tuser[m*USER_WIDTH +: USER_WIDTH] = cmd_tuser_reg;
        assign int_cmd_valid[m*M_COUNT +: M_COUNT] = cmd_valid_reg;

        assign cmd_status_ready_mux = cmd_status_ready_reg;

        assign status_overflow[m] = overflow_reg;
        assign status_bad_frame[m] = bad_frame_reg;
        assign status_good_frame[m] = good_frame_reg;

        always @* begin
            wr_ptr_next = wr_ptr_reg;
            wr_ptr_cur_next = wr_ptr_cur_reg;
            rd_ptr_next = rd_ptr_reg;

            len_next = len_reg;

            drop_frame_next = drop_frame_reg;
            overflow_next = 1'b0;
            bad_frame_next = 1'b0;
            good_frame_next = 1'b0;

            ram_wr_data_next = ram_wr_data_reg;
            ram_wr_addr_next = ram_wr_addr_reg;
            ram_wr_en_next = ram_wr_en_reg && !ram_wr_ack;

            cmd_table_start_addr_start = wr_ptr_reg;
            cmd_table_start_addr_end = wr_ptr_cur_reg + 1;
            cmd_table_start_len = len_reg;
            cmd_table_start_select = select_reg;
            cmd_table_start_tkeep = S_KEEP_ENABLE ? port_axis_tkeep : 1'b1;
            cmd_table_start_tid = port_axis_tid;
            cmd_table_start_tdest = port_axis_tdest;
            cmd_table_start_tuser = port_axis_tuser;
            cmd_table_start_en = 1'b0;

            cmd_table_read_en = 1'b0;

            cmd_table_commit_ptr = 0;
            cmd_table_commit_en = 1'b0;

            cmd_table_finish_en = 1'b0;

            cmd_addr_next = cmd_addr_reg;
            cmd_len_next = cmd_len_reg;
            cmd_id_next = cmd_id_reg;
            cmd_tkeep_next = cmd_tkeep_reg;
            cmd_tid_next = cmd_tid_reg;
            cmd_tdest_next = cmd_tdest_reg;
            cmd_tuser_next = cmd_tuser_reg;
            cmd_valid_next = cmd_valid_reg;

            cmd_status_ready_next = 1'b0;

            // issue memory writes and commands
            if (port_axis_tready && port_axis_tvalid && select_valid_reg && !drop_reg) begin
                if (full || full_wr || drop_frame_reg) begin
                    // full, packet overflow, or currently dropping frame
                    // drop frame
                    drop_frame_next = 1'b1;
                    if (port_axis_tlast) begin
                        // end of frame, reset write pointer
                        wr_ptr_cur_next = wr_ptr_reg;
                        drop_frame_next = 1'b0;
                        overflow_next = 1'b1;
                    end
                end else begin
                    wr_ptr_cur_next = wr_ptr_cur_reg + 1;
                    len_next = len_reg + 1;

                    // issue write operation
                    ram_wr_data_next = port_axis_tdata;
                    ram_wr_addr_next = wr_ptr_cur_reg;
                    ram_wr_en_next = 1'b1;

                    if (port_axis_tlast) begin
                        // end of frame
                        len_next = 0;
                        if (DROP_BAD_FRAME && USER_BAD_FRAME_MASK & ~(port_axis_tuser ^ USER_BAD_FRAME_VALUE)) begin
                            // bad packet, reset write pointer
                            wr_ptr_cur_next = wr_ptr_reg;
                            bad_frame_next = 1'b1;
                        end else begin
                            // good packet, update write pointer
                            wr_ptr_next = wr_ptr_cur_reg + 1;
                            good_frame_next = 1'b1;

                            cmd_table_start_addr_start = wr_ptr_reg;
                            cmd_table_start_addr_end = wr_ptr_cur_reg + 1;
                            cmd_table_start_len = len_reg;
                            cmd_table_start_select = select_reg;
                            cmd_table_start_tkeep = port_axis_tkeep;
                            cmd_table_start_tid = port_axis_tid;
                            cmd_table_start_tdest = port_axis_tdest;
                            cmd_table_start_tuser = port_axis_tuser;
                            cmd_table_start_en = 1'b1;
                        end
                    end
                end
            end

            // read
            cmd_valid_next = cmd_valid_reg & ~port_cmd_ready;
            if (!cmd_valid_reg && cmd_table_active[cmd_table_read_ptr_reg[CMD_ADDR_WIDTH-1:0]] && cmd_table_read_ptr_reg != cmd_table_start_ptr_reg && (!ram_wr_en_reg || ram_wr_ack)) begin
                cmd_table_read_en = 1'b1;
                cmd_addr_next = cmd_table_addr_start[cmd_table_read_ptr_reg[CMD_ADDR_WIDTH-1:0]];
                cmd_len_next = cmd_table_len[cmd_table_read_ptr_reg[CMD_ADDR_WIDTH-1:0]];
                cmd_id_next = cmd_table_read_ptr_reg;
                cmd_tkeep_next = cmd_table_tkeep[cmd_table_read_ptr_reg[CMD_ADDR_WIDTH-1:0]];
                cmd_tid_next = cmd_table_tid[cmd_table_read_ptr_reg[CMD_ADDR_WIDTH-1:0]];
                cmd_tdest_next = cmd_table_tdest[cmd_table_read_ptr_reg[CMD_ADDR_WIDTH-1:0]];
                cmd_tuser_next = cmd_table_tuser[cmd_table_read_ptr_reg[CMD_ADDR_WIDTH-1:0]];
                cmd_valid_next = 1 << cmd_table_select[cmd_table_read_ptr_reg[CMD_ADDR_WIDTH-1:0]];
            end

            // commit
            if (cmd_status_valid_mux) begin
                cmd_status_ready_next = 1'b1;
                cmd_table_commit_ptr = cmd_status_id_mux;
                cmd_table_commit_en = 1'b1;
            end

            // clean-up
            if (cmd_table_active[cmd_table_finish_ptr_reg[CMD_ADDR_WIDTH-1:0]] && cmd_table_commit[cmd_table_finish_ptr_reg[CMD_ADDR_WIDTH-1:0]] && cmd_table_finish_ptr_reg != cmd_table_start_ptr_reg) begin
                // update read pointer
                rd_ptr_next = cmd_table_addr_end[cmd_table_finish_ptr_reg[CMD_ADDR_WIDTH-1:0]];
                cmd_table_finish_en = 1'b1;
            end
        end

        always @(posedge clk) begin
            wr_ptr_reg <= wr_ptr_next;
            wr_ptr_cur_reg <= wr_ptr_cur_next;
            rd_ptr_reg <= rd_ptr_next;

            len_reg <= len_next;

            drop_frame_reg <= drop_frame_next;
            overflow_reg <= overflow_next;
            bad_frame_reg <= bad_frame_next;
            good_frame_reg <= good_frame_next;

            ram_wr_data_reg <= ram_wr_data_next;
            ram_wr_addr_reg <= ram_wr_addr_next;
            ram_wr_en_reg <= ram_wr_en_next;

            cmd_addr_reg <= cmd_addr_next;
            cmd_len_reg <= cmd_len_next;
            cmd_id_reg <= cmd_id_next;
            cmd_tkeep_reg <= cmd_tkeep_next;
            cmd_tid_reg <= cmd_tid_next;
            cmd_tdest_reg <= cmd_tdest_next;
            cmd_tuser_reg <= cmd_tuser_next;
            cmd_valid_reg <= cmd_valid_next;

            cmd_status_ready_reg <= cmd_status_ready_next;

            if (cmd_table_start_en) begin
                cmd_table_start_ptr_reg <= cmd_table_start_ptr_reg + 1;
                cmd_table_active[cmd_table_start_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= 1'b1;
                cmd_table_commit[cmd_table_start_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= 1'b0;
                cmd_table_addr_start[cmd_table_start_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= cmd_table_start_addr_start;
                cmd_table_addr_end[cmd_table_start_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= cmd_table_start_addr_end;
                cmd_table_len[cmd_table_start_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= cmd_table_start_len;
                cmd_table_select[cmd_table_start_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= cmd_table_start_select;
                cmd_table_tkeep[cmd_table_start_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= cmd_table_start_tkeep;
                cmd_table_tid[cmd_table_start_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= cmd_table_start_tid;
                cmd_table_tdest[cmd_table_start_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= cmd_table_start_tdest;
                cmd_table_tuser[cmd_table_start_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= cmd_table_start_tuser;
            end

            if (cmd_table_read_en) begin
                cmd_table_read_ptr_reg <= cmd_table_read_ptr_reg + 1;
            end

            if (cmd_table_commit_en) begin
                cmd_table_commit[cmd_table_commit_ptr] <= 1'b1;
            end

            if (cmd_table_finish_en) begin
                cmd_table_finish_ptr_reg <= cmd_table_finish_ptr_reg + 1;
                cmd_table_active[cmd_table_finish_ptr_reg[CMD_ADDR_WIDTH-1:0]] <= 1'b0;
            end

            if (rst) begin
                wr_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
                wr_ptr_cur_reg <= {ADDR_WIDTH+1{1'b0}};
                rd_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
                len_reg <= {ADDR_WIDTH{1'b0}};
                drop_frame_reg <= 1'b0;
                overflow_reg <= 1'b0;
                bad_frame_reg <= 1'b0;
                good_frame_reg <= 1'b0;
                ram_wr_en_reg <= 1'b0;
                cmd_valid_reg <= 1'b0;
                cmd_status_ready_reg <= 1'b0;
                cmd_table_start_ptr_reg <= 0;
                cmd_table_read_ptr_reg <= 0;
                cmd_table_finish_ptr_reg <= 0;
            end
        end
    end // s_ifaces

    for (n = 0; n < M_COUNT; n = n + 1) begin : m_ifaces

        // command arbitration
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
        cmd_arb_inst (
            .clk(clk),
            .rst(rst),
            .request(request),
            .acknowledge(acknowledge),
            .grant(grant),
            .grant_valid(grant_valid),
            .grant_encoded(grant_encoded)
        );

        // mux
        reg  [RAM_ADDR_WIDTH-1:0] cmd_addr_mux;
        reg  [ADDR_WIDTH-1:0]     cmd_len_mux;
        reg  [CMD_ADDR_WIDTH-1:0] cmd_id_mux;
        reg  [KEEP_WIDTH-1:0]     cmd_tkeep_mux;
        reg  [M_ID_WIDTH-1:0]     cmd_tid_mux;
        reg  [M_DEST_WIDTH-1:0]   cmd_tdest_mux;
        reg  [USER_WIDTH-1:0]     cmd_tuser_mux;
        reg                       cmd_valid_mux;
        wire                      cmd_ready_mux;

        always @* begin
            cmd_addr_mux  = int_cmd_addr[grant_encoded*RAM_ADDR_WIDTH +: RAM_ADDR_WIDTH];
            cmd_len_mux   = int_cmd_len[grant_encoded*ADDR_WIDTH +: ADDR_WIDTH];
            cmd_id_mux    = int_cmd_id[grant_encoded*CMD_ADDR_WIDTH +: CMD_ADDR_WIDTH];
            cmd_tkeep_mux = int_cmd_tkeep[grant_encoded*KEEP_WIDTH +: KEEP_WIDTH];
            cmd_tid_mux   = int_cmd_tid[grant_encoded*S_ID_WIDTH +: S_ID_WIDTH_INT];
            if (UPDATE_TID && S_COUNT > 1) begin
                cmd_tid_mux[M_ID_WIDTH-1:M_ID_WIDTH-CL_S_COUNT] = grant_encoded;
            end
            cmd_tdest_mux = int_cmd_tdest[grant_encoded*S_DEST_WIDTH +: S_DEST_WIDTH];
            cmd_tuser_mux = int_cmd_tuser[grant_encoded*USER_WIDTH +: USER_WIDTH];
            cmd_valid_mux = int_cmd_valid[grant_encoded*M_COUNT+n] && grant_valid;
        end

        assign int_cmd_ready[n*S_COUNT +: S_COUNT] = (grant_valid && cmd_ready_mux) << grant_encoded;

        for (m = 0; m < S_COUNT; m = m + 1) begin
            assign request[m] = int_cmd_valid[m*M_COUNT+n] && !grant[m];
            assign acknowledge[m] = grant[m] && int_cmd_valid[m*M_COUNT+n] && cmd_ready_mux;
        end

        reg [RAM_ADDR_WIDTH-1:0] rd_ptr_reg = {RAM_ADDR_WIDTH-1{1'b0}}, rd_ptr_next;

        reg [ADDR_WIDTH-1:0] len_reg = {ADDR_WIDTH{1'b0}}, len_next;

        reg [CL_S_COUNT-1:0] src_reg = 0, src_next;
        reg [CMD_ADDR_WIDTH-1:0] id_reg = 0, id_next;

        reg [KEEP_WIDTH-1:0] last_cycle_tkeep_reg = {KEEP_WIDTH{1'b0}}, last_cycle_tkeep_next;
        reg [M_ID_WIDTH-1:0] tid_reg = {M_ID_WIDTH{1'b0}}, tid_next;
        reg [M_DEST_WIDTH-1:0] tdest_reg = {M_DEST_WIDTH_INT{1'b0}}, tdest_next;
        reg [USER_WIDTH-1:0] tuser_reg = {USER_WIDTH{1'b0}}, tuser_next;

        reg [DATA_WIDTH-1:0]    out_axis_tdata_reg = {DATA_WIDTH{1'b0}}, out_axis_tdata_next;
        reg [KEEP_WIDTH-1:0]    out_axis_tkeep_reg = {KEEP_WIDTH{1'b0}}, out_axis_tkeep_next;
        reg                     out_axis_tvalid_reg = 1'b0, out_axis_tvalid_next;
        wire                    out_axis_tready;
        reg                     out_axis_tlast_reg = 1'b0, out_axis_tlast_next;
        reg [M_ID_WIDTH-1:0]    out_axis_tid_reg   = {M_ID_WIDTH{1'b0}}, out_axis_tid_next;
        reg [M_DEST_WIDTH-1:0]  out_axis_tdest_reg = {M_DEST_WIDTH_INT{1'b0}}, out_axis_tdest_next;
        reg [USER_WIDTH-1:0]    out_axis_tuser_reg = {USER_WIDTH{1'b0}}, out_axis_tuser_next;

        reg  [RAM_ADDR_WIDTH-1:0] ram_rd_addr_reg = {RAM_ADDR_WIDTH{1'b0}}, ram_rd_addr_next;
        reg                       ram_rd_en_reg = 1'b0, ram_rd_en_next;
        wire                      ram_rd_ack;
        wire [DATA_WIDTH-1:0]     ram_rd_data;
        wire                      ram_rd_data_valid;

        reg cmd_valid_reg = 1'b0, cmd_valid_next;

        reg [CMD_ADDR_WIDTH-1:0] cmd_status_id_reg = {CMD_ADDR_WIDTH{1'b0}}, cmd_status_id_next;
        reg [S_COUNT-1:0]        cmd_status_valid_reg = 0, cmd_status_valid_next;

        wire [S_COUNT-1:0] port_cmd_status_ready;
        for (m = 0; m < S_COUNT; m = m + 1) begin
            assign port_cmd_status_ready[m] = int_cmd_status_ready[m*M_COUNT+n];
        end

        reg [DATA_WIDTH-1:0] out_fifo_tdata[31:0];
        reg [KEEP_WIDTH-1:0] out_fifo_tkeep[31:0];
        reg out_fifo_tlast[31:0];
        reg [M_ID_WIDTH-1:0] out_fifo_tid[31:0];
        reg [M_DEST_WIDTH-1:0] out_fifo_tdest[31:0];
        reg [USER_WIDTH-1:0] out_fifo_tuser[31:0];

        reg [5:0] out_fifo_data_wr_ptr_reg = 0;
        reg [DATA_WIDTH-1:0] out_fifo_data_wr_tdata;
        reg out_fifo_data_wr_en;
        reg [5:0] out_fifo_ctrl_wr_ptr_reg = 0;
        reg [KEEP_WIDTH-1:0] out_fifo_ctrl_wr_tkeep;
        reg out_fifo_ctrl_wr_tlast;
        reg [M_ID_WIDTH-1:0] out_fifo_ctrl_wr_tid;
        reg [M_DEST_WIDTH-1:0] out_fifo_ctrl_wr_tdest;
        reg [USER_WIDTH-1:0] out_fifo_ctrl_wr_tuser;
        reg out_fifo_ctrl_wr_en;
        reg [5:0] out_fifo_rd_ptr_reg = 0;
        reg out_fifo_rd_en;

        assign port_ram_rd_addr[n*RAM_ADDR_WIDTH +: RAM_ADDR_WIDTH] = ram_rd_addr_reg;
        assign port_ram_rd_en[n] = ram_rd_en_reg;
        assign ram_rd_ack = port_ram_rd_ack[n];
        assign ram_rd_data = port_ram_rd_data[n*DATA_WIDTH +: DATA_WIDTH];
        assign ram_rd_data_valid = port_ram_rd_data_valid[n];

        assign cmd_ready_mux = !cmd_valid_reg;

        assign int_cmd_status_id[n*CMD_ADDR_WIDTH +: CMD_ADDR_WIDTH] = cmd_status_id_reg;
        assign int_cmd_status_valid[n*S_COUNT +: S_COUNT] = cmd_status_valid_reg;

        always @* begin
            rd_ptr_next = rd_ptr_reg;

            len_next = len_reg;

            src_next = src_reg;
            id_next = id_reg;

            last_cycle_tkeep_next = last_cycle_tkeep_reg;
            tid_next = tid_reg;
            tdest_next = tdest_reg;
            tuser_next = tuser_reg;

            out_axis_tdata_next  = out_axis_tdata_reg;
            out_axis_tkeep_next  = out_axis_tkeep_reg;
            out_axis_tvalid_next = out_axis_tvalid_reg && !out_axis_tready;
            out_axis_tlast_next  = out_axis_tlast_reg;
            out_axis_tid_next    = out_axis_tid_reg;
            out_axis_tdest_next  = out_axis_tdest_reg;
            out_axis_tuser_next  = out_axis_tuser_reg;

            ram_rd_addr_next = ram_rd_addr_reg;
            ram_rd_en_next = ram_rd_en_reg && !ram_rd_ack;

            cmd_valid_next = cmd_valid_reg;

            cmd_status_id_next = cmd_status_id_reg;
            cmd_status_valid_next = cmd_status_valid_reg & ~port_cmd_status_ready;

            out_fifo_data_wr_tdata = ram_rd_data;
            out_fifo_data_wr_en = 1'b0;
            out_fifo_ctrl_wr_tkeep = len_reg == 0 ? last_cycle_tkeep_reg : {KEEP_WIDTH{1'b1}};
            out_fifo_ctrl_wr_tlast = len_reg == 0;
            out_fifo_ctrl_wr_tid = tid_reg;
            out_fifo_ctrl_wr_tdest = tdest_reg;
            out_fifo_ctrl_wr_tuser = tuser_reg;
            out_fifo_ctrl_wr_en = 1'b0;
            out_fifo_rd_en = 1'b0;

            // receive commands
            if (!cmd_valid_reg && cmd_valid_mux) begin
                cmd_valid_next = 1'b1;
                rd_ptr_next = cmd_addr_mux;
                len_next = cmd_len_mux;
                last_cycle_tkeep_next = cmd_tkeep_mux;
                id_next = cmd_id_mux;
                tid_next = cmd_tid_mux;
                tdest_next = cmd_tdest_mux;
                tuser_next = cmd_tuser_mux;

                src_next = grant_encoded;
            end

            // process commands and issue memory reads
            if (cmd_valid_reg && !cmd_status_valid_next && (!ram_rd_en_reg || ram_rd_ack) && ($unsigned(out_fifo_ctrl_wr_ptr_reg - out_fifo_rd_ptr_reg) < 32)) begin
                // update counters
                rd_ptr_next[ADDR_WIDTH-1:0] = rd_ptr_reg[ADDR_WIDTH-1:0] + 1;
                len_next = len_reg - 1;

                // issue memory read
                ram_rd_addr_next = rd_ptr_reg;
                ram_rd_en_next = 1'b1;

                // write output control FIFO
                out_fifo_ctrl_wr_tkeep = len_reg == 0 ? last_cycle_tkeep_reg : {KEEP_WIDTH{1'b1}};
                out_fifo_ctrl_wr_tlast = len_reg == 0;
                out_fifo_ctrl_wr_tid = tid_reg;
                out_fifo_ctrl_wr_tdest = tdest_reg;
                out_fifo_ctrl_wr_tuser = tuser_reg;
                out_fifo_ctrl_wr_en = 1'b1;

                if (len_reg == 0) begin
                    // indicate operation complete
                    cmd_status_id_next = id_reg;
                    cmd_status_valid_next = 1 << src_reg;
                    cmd_valid_next = 1'b0;
                end
            end

            // write RAM read data to output data FIFO
            if (ram_rd_data_valid) begin
                out_fifo_data_wr_tdata = ram_rd_data;
                out_fifo_data_wr_en = 1'b1;
            end

            // generate output AXI stream data from control and data FIFOs
            if ((out_axis_tready || !out_axis_tvalid_reg) && (out_fifo_rd_ptr_reg != out_fifo_ctrl_wr_ptr_reg) && (out_fifo_rd_ptr_reg != out_fifo_data_wr_ptr_reg)) begin
                out_fifo_rd_en = 1'b1;
                out_axis_tdata_next = out_fifo_tdata[out_fifo_rd_ptr_reg[4:0]];
                out_axis_tkeep_next = out_fifo_tkeep[out_fifo_rd_ptr_reg[4:0]];
                out_axis_tvalid_next = 1'b1;
                out_axis_tlast_next = out_fifo_tlast[out_fifo_rd_ptr_reg[4:0]];
                out_axis_tid_next   = out_fifo_tid[out_fifo_rd_ptr_reg[4:0]];
                out_axis_tdest_next = out_fifo_tdest[out_fifo_rd_ptr_reg[4:0]];
                out_axis_tuser_next = out_fifo_tuser[out_fifo_rd_ptr_reg[4:0]];
            end
        end

        always @(posedge clk) begin
            rd_ptr_reg <= rd_ptr_next;

            len_reg <= len_next;

            src_reg <= src_next;
            id_reg <= id_next;

            last_cycle_tkeep_reg <= last_cycle_tkeep_next;
            tid_reg <= tid_next;
            tdest_reg <= tdest_next;
            tuser_reg <= tuser_next;

            out_axis_tdata_reg <= out_axis_tdata_next;
            out_axis_tkeep_reg <= out_axis_tkeep_next;
            out_axis_tvalid_reg <= out_axis_tvalid_next;
            out_axis_tlast_reg <= out_axis_tlast_next;
            out_axis_tid_reg   <= out_axis_tid_next;
            out_axis_tdest_reg <= out_axis_tdest_next;
            out_axis_tuser_reg <= out_axis_tuser_next;

            ram_rd_addr_reg <= ram_rd_addr_next;
            ram_rd_en_reg <= ram_rd_en_next;

            cmd_valid_reg <= cmd_valid_next;

            cmd_status_id_reg <= cmd_status_id_next;
            cmd_status_valid_reg <= cmd_status_valid_next;

            if (out_fifo_data_wr_en) begin
                out_fifo_data_wr_ptr_reg <= out_fifo_data_wr_ptr_reg + 1;
                out_fifo_tdata[out_fifo_data_wr_ptr_reg[4:0]] <= out_fifo_data_wr_tdata;
            end

            if (out_fifo_ctrl_wr_en) begin
                out_fifo_ctrl_wr_ptr_reg <= out_fifo_ctrl_wr_ptr_reg + 1;
                out_fifo_tkeep[out_fifo_ctrl_wr_ptr_reg[4:0]] <= out_fifo_ctrl_wr_tkeep;
                out_fifo_tlast[out_fifo_ctrl_wr_ptr_reg[4:0]] <= out_fifo_ctrl_wr_tlast;
                out_fifo_tid[out_fifo_ctrl_wr_ptr_reg[4:0]] <= out_fifo_ctrl_wr_tid;
                out_fifo_tdest[out_fifo_ctrl_wr_ptr_reg[4:0]] <= out_fifo_ctrl_wr_tdest;
                out_fifo_tuser[out_fifo_ctrl_wr_ptr_reg[4:0]] <= out_fifo_ctrl_wr_tuser;
            end

            if (out_fifo_rd_en) begin
                out_fifo_rd_ptr_reg <= out_fifo_rd_ptr_reg + 1;
            end

            if (rst) begin
                len_reg <= 0;
                out_axis_tvalid_reg <= 1'b0;
                ram_rd_en_reg <= 1'b0;
                cmd_valid_reg <= 1'b0;
                cmd_status_valid_reg <= 0;
                out_fifo_data_wr_ptr_reg <= 0;
                out_fifo_ctrl_wr_ptr_reg <= 0;
                out_fifo_rd_ptr_reg <= 0;
            end
        end

        axis_adapter #(
            .S_DATA_WIDTH(DATA_WIDTH),
            .S_KEEP_ENABLE(1),
            .S_KEEP_WIDTH(KEEP_WIDTH),
            .M_DATA_WIDTH(M_DATA_WIDTH),
            .M_KEEP_ENABLE(M_KEEP_ENABLE),
            .M_KEEP_WIDTH(M_KEEP_WIDTH),
            .ID_ENABLE(ID_ENABLE),
            .ID_WIDTH(M_ID_WIDTH),
            .DEST_ENABLE(M_DEST_WIDTH > 0),
            .DEST_WIDTH(M_DEST_WIDTH_INT),
            .USER_ENABLE(USER_ENABLE),
            .USER_WIDTH(USER_WIDTH)
        )
        adapter_inst (
            .clk(clk),
            .rst(rst),
            // AXI input
            .s_axis_tdata(out_axis_tdata_reg),
            .s_axis_tkeep(out_axis_tkeep_reg),
            .s_axis_tvalid(out_axis_tvalid_reg),
            .s_axis_tready(out_axis_tready),
            .s_axis_tlast(out_axis_tlast_reg),
            .s_axis_tid(out_axis_tid_reg),
            .s_axis_tdest(out_axis_tdest_reg),
            .s_axis_tuser(out_axis_tuser_reg),
            // AXI output
            .m_axis_tdata(m_axis_tdata[M_DATA_WIDTH*n +: M_DATA_WIDTH]),
            .m_axis_tkeep(m_axis_tkeep[M_KEEP_WIDTH*n +: M_KEEP_WIDTH]),
            .m_axis_tvalid(m_axis_tvalid[n]),
            .m_axis_tready(m_axis_tready[n]),
            .m_axis_tlast(m_axis_tlast[n]),
            .m_axis_tid(m_axis_tid[M_ID_WIDTH*n +: M_ID_WIDTH]),
            .m_axis_tdest(m_axis_tdest[M_DEST_WIDTH*n +: M_DEST_WIDTH_INT]),
            .m_axis_tuser(m_axis_tuser[USER_WIDTH*n +: USER_WIDTH])
        );
    end // m_ifaces

endgenerate

endmodule

`resetall

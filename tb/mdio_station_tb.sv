`timescale 1ns/1ps
module testbench;

logic           clk = 'b0;
logic           rst = 'b0;
logic           en = 1'b1;
logic           busy;
logic           err;
logic [4:0]     phy_addr;
logic [4:0]     reg_addr;
logic           write;
logic [15:0]    up_data;
logic           up_valid;
logic           up_ready;
logic [15:0]    down_data;
logic           down_valid;
logic           down_ready;
logic           mdc;
logic           mdio_i;
logic           mdio_o;
logic           mdio_t;

mdio_station #(
    .ICLK_TO_MDC_FREQ_RATIO(40 /* default 40 */),
    .PREAMBLE_LENGTH       (32 /* default 32 */),
    .PHY_ADDR_WIDTH        (5 /* default 5 */),
    .REG_ADDR_WIDTH        (5 /* default 5 */),
    .DATA_WIDTH            (16 /* default 16 */)
) mdio_station (
    .clk       (clk),
    .rst       (rst),
    .en        (en),
    .busy      (busy),
    .err       (err),
    .phy_addr  (phy_addr),
    .reg_addr  (reg_addr),
    .write     (write),
    .up_data   (up_data),
    .up_valid  (up_valid),
    .up_ready  (up_ready),
    .down_data (down_data),
    .down_valid(down_valid),
    .down_ready(down_ready),
    .mdc       (mdc),
    .mdio_i    (mdio_i),
    .mdio_o    (mdio_o),
    .mdio_t    (mdio_t)
);

localparam CLK_PERIOD = 10;
initial begin
    forever begin
        #(CLK_PERIOD/2); 
        clk=~clk;
    end
end

task drive_rst();
    @(posedge clk);
    rst <= 'b1;
    repeat (3) @(posedge clk);
    rst <= 'b0;
endtask

task drive_inputs();
    wait (rst);
    @(posedge clk);
    phy_addr    <= 'h00;
    reg_addr    <= 'h00;
    write       <= 'b0;
    up_data     <= 'h0000;
    up_valid    <= 'b0;
    down_ready  <= 'b0;
    @(posedge clk);
    wait (~rst);
    @(posedge clk);
    phy_addr    <= 'h13;
    reg_addr    <= 'h1b;
    write       <= 'b1;
    up_data     <= 'hbeef;
    up_valid    <= 'b1;
    down_ready  <= 'b0;
    @(posedge clk);
    wait (~up_ready);
    wait (~busy);
endtask

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);

    $display("Test started");
    fork
        drive_rst();
        drive_inputs();
    join
    $display("Test finished");

    $finish();
end


endmodule
`resetall

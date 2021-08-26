# Verilog AXI Stream Components Readme

[![Build Status](https://github.com/alexforencich/verilog-axis/workflows/Regression%20Tests/badge.svg?branch=master)](https://github.com/alexforencich/verilog-axis/actions/)

For more information and updates: http://alexforencich.com/wiki/en/verilog/axis/start

GitHub repository: https://github.com/alexforencich/verilog-axis

## Introduction

Collection of AXI Stream bus components.  Most components are fully
parametrizable in interface widths.  Includes full cocotb testbenches that
utilize [cocotbext-axi](https://github.com/alexforencich/cocotbext-axi).

## Documentation

### `arbiter` module

General-purpose parametrizable arbiter.  Supports priority and round-robin
arbitration.  Supports blocking until request release or acknowledge.  

### `axis_adapter` module

The `axis_adapter` module bridges AXI stream buses of differing widths.  The
module is parametrizable, but there are certain restrictions.  First, the bus
word widths must be identical (e.g. one 8-bit lane and eight 8-bit lanes, but
not one 16-bit lane and one 32-bit lane).  Second, the bus widths must be
related by an integer multiple (e.g. 2 words and 6 words, but not 4 words
and 6 words).  Wait states will be inserted on the wider bus side when
necessary.

### `axis_arb_mux` module

Frame-aware AXI stream arbitrated multiplexer with parametrizable data width
and port count.  Supports priority and round-robin arbitration.

Wrappers can generated with `axis_arb_mux_wrap.py`.

### `axis_async_fifo` module

Configurable word-based or frame-based asynchronous FIFO with parametrizable
data width, depth, type, and bad frame detection.  Supports power of two
depths only.

### `axis_async_fifo_adapter` module

Configurable word-based or frame-based asynchronous FIFO with parametrizable
data width, depth, type, and bad frame detection.  Supports different input
and output data widths, inserting an axis_adapter instance appropriately.
Supports power of two depths only.

### `axis_broadcast` module

AXI stream broadcaster.  Duplicates one input stream across multiple output
streams.

### `axis_cobs_decode`

Consistent Overhead Byte Stuffing (COBS) decoder.  Fixed 8 bit width.

### `axis_cobs_encode`

Consistent Overhead Byte Stuffing (COBS) encoder.  Fixed 8 bit width.
Configurable zero insertion.

### `axis_crosspoint` module

Basic crosspoint switch.  `tready` signal not supported.  Parametrizable data
width.  

Wrappers can generated with `axis_crosspoint_wrap.py`.

### `axis_demux` module

Frame-aware AXI stream demultiplexer with parametrizable data width and port
count.

### `axis_fifo` module

Configurable word-based or frame-based synchronous FIFO with parametrizable
data width, depth, type, and bad frame detection.  Supports power of two
depths only.

### `axis_fifo_adapter` module

Configurable word-based or frame-based synchronous FIFO with parametrizable
data width, depth, type, and bad frame detection.  Supports different input
and output data widths, inserting an axis_adapter instance appropriately.
Supports power of two depths only.

### `axis_frame_join` module

Frame joiner with optional tag and parametrizable port count.  8 bit data path
only.

Wrappers can generated with `axis_frame_join_wrap.py`.

### `axis_frame_length_adjust` module

Frame length adjuster module.  Truncates or pads frames as necessary to meet
the specified minimum and maximum length.  Reports the original and current
lengths as well as whether the packet was truncated or padded.  Length limits
are configurable at run time.

### `axis_frame_length_adjust_fifo` module

Frame length adjuster module with FIFO.  Truncates or pads frames as necessary
to meet the specified minimum and maximum length.  Reports the original and
current lengths as well as whether the packet was truncated or padded.  FIFOs
are used so that the status information can be read before the packet itself.
Length limits are configurable at run time.

### `axis_ll_bridge` module

AXI stream to LocalLink bridge.

### `axis_mux` module

Frame-aware AXI stream multiplexer with parametrizable data width and port
count.

Wrappers can generated with `axis_mux_wrap.py`.

### `axis_pipeline_fifo` module

Parametrizable register pipeline with output FIFO.  LENGTH parameter
determines number of register stages.  For a sufficient pipeline length and
bus width, consumes fewer resources than `axis_pipeline_register` while
providing full throughput.

### `axis_pipeline_register` module

Parametrizable register pipeline.  LENGTH parameter determines number of
register stages (instances of `axis_register`).

### `axis_ram_switch` module

Frame-aware AXI stream RAM switch with parametrizable data width, port count,
and FIFO size.  Uses block RAM for storing packets in transit, time-sharing
the RAM interface between ports.  Functionally equivalent to a combination of
per-port frame FIFOs and width converters connected to an AXI stream switch.

### `axis_rate_limit` module

Fractional rate limiter, supports word and frame modes.  Inserts wait states
to limit data rate to specified ratio.  Frame mode inserts wait states at end
of frames, word mode ignores frames and inserts wait states at any point.
Parametrizable data width.  Rate and mode are configurable at run time.

### `axis_register` module

Datapath register with parameter to select between skid buffer, simple buffer,
and bypass.  Use to improve timing for long routes.  Use `REG_TYPE` parameter
to select the type of register (bypass, simple, or skid buffer).

### `axis_srl_fifo` module

SRL-based FIFO.  Good for small FIFOs.  SRLs on Xilinx FPGAs have a very fast
input setup time, so this module can be used to aid in timing closure.

### `axis_srl_register` module

SRL-based register.  SRLs on Xilinx FPGAs have a very fast input setup time,
so this module can be used to aid in timing closure.

### `axis_stat_counter` module

Statistics counter module.  Counts bytes and frames passing through monitored
AXI stream interface.  Trigger signal used to reset and dump counts out of AXI
interface, along with tag value.  Use with `axis_frame_join` to form a single
monolithic frame from multiple monitored points with the same trigger.

### `axis_switch` module

Frame-aware AXI stream switch with parametrizable data width and port count.

Wrappers can generated with `axis_switch_wrap.py`.

### `axis_tap` module

AXI stream tap module.  Used to make a copy of an AXI stream bus without
affecting the bus.  Back-pressure on the output results in truncated frames
with `tuser` set.

### `ll_axis_bridge` module

LocalLink to AXI stream bridge.

### `priority_encoder` module

Parametrizable priority encoder.

### Common signals

    tdata   : Data (width generally DATA_WIDTH)
    tkeep   : Data word valid (width generally KEEP_WIDTH)
    tvalid  : Data valid
    tready  : Sink ready
    tlast   : End-of-frame
    tid     : Identifier tag (width generally ID_WIDTH)
    tdest   : Destination tag (width generally DEST_WIDTH)
    tuser   : User sideband signals (width generally USER_WIDTH)

### Common parameters

    DATA_WIDTH           : width of tdata signal
    KEEP_ENABLE          : enable tkeep signal (default DATA_WIDTH>8)
    KEEP_WIDTH           : width of tkeep signal (default DATA_WIDTH/8)
    LAST_ENABLE          : enable tlast signal
    ID_ENABLE            : enable tid signal
    ID_WIDTH             : width of tid signal
    DEST_ENABLE          : enable tdest signal
    DEST_WIDTH           : width of tdest signal
    USER_ENABLE          : enable tuser signal
    USER_WIDTH           : width of tuser signal
    USER_BAD_FRAME_VALUE : value of tuser indicating bad frame
    USER_BAD_FRAME_MASK  : bitmask for tuser bad frame indication

### Source Files

    arbiter.v                          : General-purpose parametrizable arbiter
    axis_adapter.v                     : Parametrizable bus width adapter
    axis_arb_mux.v                     : Parametrizable arbitrated multiplexer
    axis_async_fifo.v                  : Parametrizable asynchronous FIFO
    axis_async_fifo_adapter.v          : FIFO/width adapter wrapper
    axis_broadcast.v                   : AXI stream broadcaster
    axis_cobs_decode.v                 : COBS decoder
    axis_cobs_encode.v                 : COBS encoder
    axis_crosspoint.v                  : Parametrizable crosspoint switch
    axis_demux.v                       : Parametrizable demultiplexer
    axis_fifo.v                        : Parametrizable synchronous FIFO
    axis_fifo_adapter.v                : FIFO/width adapter wrapper
    axis_frame_join.v                  : Parametrizable frame joiner
    axis_frame_length_adjust.v         : Frame length adjuster
    axis_frame_length_adjust_fifo.v    : Frame length adjuster with FIFO
    axis_ll_bridge.v                   : AXI stream to LocalLink bridge
    axis_mux.v                         : Multiplexer generator
    axis_pipeline_fifo.v               : AXI stream register pipeline with FIFO
    axis_pipeline_register.v           : AXI stream register pipeline
    axis_ram_switch.v                  : AXI stream RAM switch
    axis_rate_limit.v                  : Fractional rate limiter
    axis_register.v                    : AXI Stream register
    axis_srl_fifo.v                    : SRL-based FIFO
    axis_srl_register.v                : SRL-based register
    axis_switch.v                      : Parametrizable AXI stream switch
    axis_stat_counter.v                : Statistics counter
    axis_tap.v                         : AXI stream tap
    ll_axis_bridge.v                   : LocalLink to AXI stream bridge
    priority_encoder.v                 : Parametrizable priority encoder

### AXI Stream Interface Example

two byte transfer with sink pause after each byte

              __    __    __    __    __    __    __    __    __
    clk    __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__
                    _____ _________________
    tdata  XXXXXXXXX_D0__X_D1______________XXXXXXXXXXXXXXXXXXXXXXXX
                    _____ _________________
    tkeep  XXXXXXXXX_K0__X_K1______________XXXXXXXXXXXXXXXXXXXXXXXX
                    _______________________
    tvalid ________/                       \_______________________
           ______________             _____             ___________
    tready               \___________/     \___________/
                          _________________
    tlast  ______________/                 \_______________________

    tuser  ________________________________________________________


two back-to-back packets, no pauses

              __    __    __    __    __    __    __    __    __
    clk    __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__
                    _____ _____ _____ _____ _____ _____
    tdata  XXXXXXXXX_A0__X_A1__X_A2__X_B0__X_B1__X_B2__XXXXXXXXXXXX
                    _____ _____ _____ _____ _____ _____
    tkeep  XXXXXXXXX_K0__X_K1__X_K2__X_K0__X_K1__X_K2__XXXXXXXXXXXX
                    ___________________________________
    tvalid ________/                                   \___________
           ________________________________________________________
    tready
                                _____             _____
    tlast  ____________________/     \___________/     \___________

    tuser  ________________________________________________________


bad frame

              __    __    __    __    __    __
    clk    __/  \__/  \__/  \__/  \__/  \__/  \__
                    _____ _____ _____
    tdata  XXXXXXXXX_A0__X_A1__X_A2__XXXXXXXXXXXX
                    _____ _____ _____
    tkeep  XXXXXXXXX_K0__X_K1__X_K2__XXXXXXXXXXXX
                    _________________
    tvalid ________/                 \___________
           ______________________________________
    tready
                                _____
    tlast  ____________________/     \___________
                                _____
    tuser  ____________________/     \___________


## Testing

Running the included testbenches requires [cocotb](https://github.com/cocotb/cocotb), [cocotbext-axi](https://github.com/alexforencich/cocotbext-axi), and [Icarus Verilog](http://iverilog.icarus.com/).  The testbenches can be run with pytest directly (requires [cocotb-test](https://github.com/themperek/cocotb-test)), pytest via tox, or via cocotb makefiles.

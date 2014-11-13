# Verilog AXI Stream Components Readme

For more information and updates: http://alexforencich.com/wiki/en/verilog/axis/start

GitHub repository: https://github.com/alexforencich/verilog-axis

## Introduction

Collection of AXI Stream bus components.  Most components are fully
parametrizable in interface widths.  Includes full MyHDL testbench with
intelligent bus cosimulation endpoints.

## Documentation

### arbiter module

General-purpose parametrizable arbiter.  Supports priority and round-robin
arbitration.  Supports blocking until request release or acknowledge.  

### axis_adapter module

The axis_adapter module bridges AXI stream busses of differing widths.  The
module is parametrizable, but there are certain restrictions.  First, the bus
word widths must be identical (e.g. one 8-bit lane and eight 8-bit lanes, but
not one 16-bit lane and one 32-bit lane).  Second, the bus widths must be
related by an integer multiple (e.g. 2 words and 6 words, but not 4 words
and 6 words).  Wait states will be inserted on the wider bus side when
necessary.

### axis_arb_mux_N module

Frame-aware AXI stream arbitrated muliplexer with parametrizable data width.
Supports priority and round-robin arbitration.

Can be generated with arbitrary port counts with axis_arb_mux.py.

### axis_arb_mux_64_N module

Frame-aware AXI stream arbitrated muliplexer with tkeep signal and
parametrizable data width.  Supports priority and round-robin arbitration.

Can be generated with arbitrary port counts with axis_arb_mux_64.py.

### axis_async_fifo module

Basic word-based asynchronous FIFO with parametrizable data width and depth.
Supports power of two depths only.

### axis_async_fifo_64 module

Basic word-based asynchronous FIFO with tkeep signal and parametrizable data
width and depth.  Supports power of two depths only.

### axis_async_frame_fifo module

Basic frame-based asynchronous FIFO with parametrizable data width and depth.
Supports power of two depths only.

### axis_async_fifo_64 module

Basic frame-based asynchronous FIFO with tkeep signal and parametrizable data
width and depth.  Supports power of two depths only.

### axis_crosspoint module

Basic crosspoint switch.  tready signal not supported.  Parametrizable data
width.  

Can be generated with arbitrary port counts with axis_crosspoint.py.

### axis_crosspoint_64 module

Basic crosspoint switch with tkeep.  tready signal not supported.
Parametrizable data width.  

Can be generated with arbitrary port counts with axis_crosspoint_64.py.

### axis_demux_N module

Frame-aware AXI stream demuliplexer with parametrizable data width.

Can be generated with arbitrary port counts with axis_demux.py.

### axis_demux_64_N module

Frame-aware AXI stream demuliplexer with tkeep signal and parametrizable data
width.

Can be generated with arbitrary port counts with axis_demux_64.py.

### axis_fifo module

Basic word-based synchronous FIFO with parametrizable data width and depth.
Supports power of two depths only.

### axis_fifo_64 module

Basic word-based synchronous FIFO with tkeep signal and parametrizable data
width and depth.  Supports power of two depths only.

### axis_frame_fifo module

Basic frame-based synchronous FIFO with parametrizable data width and depth.
Supports power of two depths only.

### axis_frame_fifo_64 module

Basic frame-based synchronous FIFO with tkeep signal and parametrizable data
width and depth.  Supports power of two depths only.

### axis_frame_join_N module

Frame joiner with optional tag.  8 bit data path only.

Can be generated with arbitrary port counts with axis_frame_join.py.

### axis_ll_bridge module

AXI stream to LocalLink bridge.

### axis_mux_N module

Frame-aware AXI stream muliplexer with parametrizable data width.

Can be generated with arbitrary port counts with axis_mux.py.

### axis_mux_64_N module

Frame-aware AXI stream muliplexer with tkeep signal and parametrizable data
width.

Can be generated with arbitrary port counts with axis_mux_64.py.

### axis_rate_limit module

Fractional rate limiter, supports word and frame modes.  Inserts wait states
to limit data rate to specified ratio.  Frame mode inserts wait states at end
of frames, word mode ignores frames and inserts wait states at any point.
Parametrizable data width.  Rate and mode are configurable at run time.

### axis_rate_limit_64 module

Fractional rate limiter with tkeep signal, supports word and frame modes.
Inserts wait states to limit data rate to specified ratio.  Frame mode inserts
wait states at end of frames, word mode ignores frames and inserts wait states
at any point.  Parametrizable data width.  Rate and mode are configurable at
run time.

### axis_register module

Datapath register.  Use to improve timing for long routes.  

### axis_register_64 module

Datapath register with tkeep signal.  Use to improve timing for long routes.

### axis_stat_counter module

Statistics counter module.  Counts bytes and frames passing through monitored
AXI stream interface.  Trigger signal used to reset and dump counts out of AXI
interface, along with tag value.  Use with axis_frame_join_N to form a single
monolithic frame from multiple monitored points with the same trigger.

### ll_axis_bridge module

LocalLink to AXI stream bridge.

### priority_encoder module

Parametrizable priority encoder.

### Common signals

    tdata   : Data (width generally DATA_WIDTH)
    tkeep   : Data word valid (width generally KEEP_WIDTH, present on _64 modules)
    tvalid  : Data valid
    tready  : Sink ready
    tlast   : End-of-frame
    tuser   : Bad frame (valid with tlast & tvalid)

### Source Files

    rtl/arbiter.v                   : General-purpose parametrizable arbiter
    rtl/axis_adapter.v              : Parametrizable bus width adapter
    rtl/axis_arb_mux.py             : Arbitrated multiplexer generator
    rtl/axis_arb_mux_4.v            : 4 port arbitrated multiplexer
    rtl/axis_arb_mux_64.py          : Arbitrated multiplexer generator (64 bit)
    rtl/axis_arb_mux_64_4.v         : 4 port arbitrated multiplexer (64 bit)
    rtl/axis_async_fifo.v           : Asynchronous FIFO
    rtl/axis_async_fifo_64.v        : Asynchronous FIFO (64 bit)
    rtl/axis_async_frame_fifo.v     : Asynchronous frame FIFO
    rtl/axis_async_frame_fifo_64.v  : Asynchronous frame FIFO (64 bit)
    rtl/axis_crosspoint.py          : Crosspoint switch generator
    rtl/axis_crosspoint_4x4.v       : 4x4 crosspoint switch
    rtl/axis_crosspoint_64.py       : Crosspoint switch generator (64 bit)
    rtl/axis_crosspoint_64_4x4.v    : 4x4 crosspoint switch (64 bit)
    rtl/axis_demux.py               : Demultiplexer generator
    rtl/axis_demux_4.v              : 4 port demultiplexer
    rtl/axis_demux_64.py            : Demultiplexer generator (64 bit)
    rtl/axis_demux_64_4.v           : 4 port demultiplexer (64 bit)
    rtl/axis_fifo.v                 : Synchronous FIFO
    rtl/axis_fifo_64.v              : Synchronous FIFO (64 bit)
    rtl/axis_frame_fifo.v           : Synchronous frame FIFO
    rtl/axis_frame_fifo_64.v        : Synchronous frame FIFO (64 bit)
    rtl/axis_frame_join.py          : Frame joiner generator
    rtl/axis_frame_join_4.v         : 4 port frame joiner
    rtl/axis_ll_bridge.v            : AXI stream to LocalLink bridge
    rtl/axis_mux.py                 : Multiplexer generator
    rtl/axis_mux_4.v                : 4 port multiplexer
    rtl/axis_mux_64.py              : Multiplexer generator (64 bit)
    rtl/axis_mux_64_4.v             : 4 port multiplexer (64 bit)
    rtl/axis_rate_limit.v           : Fractional rate limiter
    rtl/axis_rate_limit_64.v        : Fractional rate limiter (64 bit)
    rtl/axis_register.v             : AXI Stream register
    rtl/axis_register_64.v          : AXI Stream register (64 bit)
    rtl/axis_stat_counter.v         : Statistics counter
    rtl/ll_axis_bridge.v            : LocalLink to AXI stream bridge
    rtl/priority_encoder.v          : Parametrizable priority encoder

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

Running the included testbenches requires MyHDL and Icarus Verilog.  Make sure
that myhdl.vpi is installed properly for cosimulation to work correctly.  The
testbenches can be run with a Python test runner like nose or py.test, or the
individual test scripts can be run with python directly.

### Testbench Files

    tb/axis_ep.py        : MyHDL AXI Stream endpoints
    tb/ll_ep.py          : MyHDL LocalLink endpoints

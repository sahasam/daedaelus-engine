// Sahas Munamala
// Created: Sun Oct 08 2023, 10:40AM PDT

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FPGA top-level module
 */
module fpga
(
    /*
     * Clock: 125MHz LVDS
     */
    input  wire         clk_25mhz_ref
);

// Clock and reset
wire clk_25mhz_int;

// Internal 10 MHz clock
wire clk_10mhz_int;
wire clk_10mhz_mmcm_out;

wire mmcm_rst = zynq_pl_reset;
wire mmcm_locked;
wire mmcm_clkfb;

// MMCM instance
MMCME4_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(20),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(1),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(8),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(40.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_25mhz_int),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_10mhz_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked)
);

BUFG
clk_10mhz_bufg_inst (
    .I(clk_10mhz_mmcm_out),
    .O(clk_10mhz_int)
);

/* Zynq Design. This module is generated through Vivado Block Designer
 * in ip/zynq_ps.tcl
 */
zynq_ps zynq_ps_inst ();


wire     rx;
wire     tx;

wire     axis_din_tdata;
wire     axis_din_tready;
wire     axis_din_tvalid;

wire     axis_dout_tdata;
wire     axis_dout_tready;
wire     axis_dout_tvalid;

uart_loopback uart_loopback_inst (
    .clk     (clk_10mhz_int),

    .m_axis_din_tdata       (axis_din_tdata),
    .m_axis_din_tready      (axis_din_tready),
    .m_axis_din_tvalid      (axis_din_tvalid),

    .s_axis_dout_tdata      (axis_dout_tdata),
    .s_axis_dout_tready     (axis_dout_tready),
    .s_axis_dout_tvalid     (axis_dout_tvalid)
);

uart #(
    .TICKS_PER_BIT(87),
    .FRAME_WIDTH(8)
) uart_inst_0 (
    .clk     (clk_10mhz_int),
    .rx      (rx),
    .tx      (tx),

    .s_axis_din_tdata       (axis_din_tdata),
    .s_axis_din_tready      (axis_din_tready),
    .s_axis_din_tvalid      (axis_din_tvalid),

    .m_axis_dout_tdata      (axis_dout_tdata),
    .m_axis_dout_tready     (axis_dout_tready),
    .m_axis_dout_tvalid     (axis_dout_tvalid)
);

endmodule


`resetall

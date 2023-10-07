// Sahas Munamala
// Created: Sat Oct 07 2023, 01:09PM PDT

// Module: uart
// Purpose: UART Implementation Top Module. This module
// Just routes wires to uart_rx and uart_tx modules that
// contain all the logic. AXI Streams serve as input and output
// for the module
module uart #(
    // # of clock cycles between bits on the wire
    // 10MHz -> 115200 Baud is (10000000/115200) ~= 87
    // Doesn't need to be perfect, just accurate enough
    // to last the entire frame width
    parameter TICKS_PER_BIT=87,

    // number of bits in a single uart frame. Standard
    // is 8, but my special case requries 64 bit slices.
    parameter FRAME_WIDTH=64
)
(
    input                   clk,
    input                   rx,
    output                  tx,

    // input axi stream
    input  wire [7:0]       s_axis_din_tdata,
    output wire             s_axis_din_tready,
    input  wire             s_axis_din_tvalid,

    // output axi stream
    output wire [7:0]       m_axis_dout_tdata,
    input  wire             m_axis_dout_tready,
    output wire             m_axis_dout_tvalid
);

uart_rx #(
    .TICKS_PER_BIT(87),
    .FRAME_WIDTH(64)
) uart_rx_inst (
    .clk(clk),
    .rx(rx),

    .m_axis_rx_tdata  (m_axis_dout_tdata),
    .m_axis_rx_tready (m_axis_dout_tready),
    .m_axis_rx_tvalid (m_axis_dout_tvalid)
);

uart_tx #(
    .TICKS_PER_BIT(87),
    .FRAME_WIDTH(64)
) uart_tx_inst (
    .clk(clk),
    .tx(tx),

    .m_axis_rx_tdata  (m_axis_din_tdata),
    .m_axis_rx_tready (m_axis_din_tready),
    .m_axis_rx_tvalid (m_axis_din_tvalid)
);

endmodule

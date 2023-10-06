`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2023 02:38:57 PM
// Design Name: Uart Module
// Module Name: uart
// Project Name: Uart Test Module 
// Target Devices: 
// Tool Versions: 
// Description: Simple 8 bit Uart Interface. Send and receive 8 bits at
// a time. 115200 Baud
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart(
    input                   clk,
    input                   rx,
    output	                tx,			

    // input axi stream
    input  wire [7:0]       s_axis_din_tdata,
    output wire             s_axis_din_tready,
    input  wire             s_axis_din_tvalid,

    // output axi stream
    output wire [7:0]       m_axis_dout_tdata,
    input  wire             m_axis_dout_tready,
    output wire             m_axis_dout_tvalid
);

endmodule

// Sahas Munamala
// Created: Sun Oct 08 2023, 03:45PM PDT

// Module: uart_loopback
// Purpose: loopback uart from rx to tx. This is
// to test my uart module on the board itself
// by bitbanging from an arduino
module uart_loopback (
    input           clk,
    input           rst,

    input [7:0]          s_axis_din_tdata,
    output reg           s_axis_din_tready,
    input wire           s_axis_din_tvalid,

    output reg [7:0]     m_axis_dout_tdata,
    input wire           m_axis_dout_tready,
    output reg           m_axis_dout_tvalid
);

localparam [2:0] IDLE      = 3'd0;
localparam [2:0] HOLDING = 3'd2;
localparam [2:0] SENDING   = 3'd1;


reg [2:0]        loopback_sm = IDLE;

always @ ( posedge clk )
begin
    case ( loopback_sm )

        IDLE : begin
            if ( s_axis_din_tvalid == 1'b1 ) begin
                loopback_sm <= HOLDING;
                s_axis_din_tready  <= 0;
                m_axis_dout_tvalid <= 1;
                m_axis_dout_tdata  <= s_axis_din_tdata;
            end
            else begin
                loopback_sm <= IDLE;
                s_axis_din_tready  <= 1;
                m_axis_dout_tvalid <= 0;
            end
        end

        HOLDING : begin
            if ( m_axis_dout_tready == 1'b1 ) begin
                loopback_sm <= SENDING;
                s_axis_din_tready  <= 0;
                m_axis_dout_tvalid <= 0;
            end
            else begin
                loopback_sm <= HOLDING;
                s_axis_din_tready  <= 0;
                m_axis_dout_tvalid <= 1;
            end
        end

        SENDING : begin
            if ( m_axis_dout_tready == 1'b1 ) begin
                loopback_sm <= IDLE;
                s_axis_din_tready <= 1;
                m_axis_dout_tvalid <= 0;
            end
            else begin
                loopback_sm <= SENDING;
                s_axis_din_tready <= 0;
                m_axis_dout_tvalid <= 0;
            end
        end

    endcase
end


endmodule

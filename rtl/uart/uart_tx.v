// Sahas Munamala
// Created: Wed Oct 04 2023, 04:42PM PDT
// Purpose: Receive Side Module for UART

// Module: uart_tx
// Purpose: UART Transmit Side Module
module uart_tx #(
    // # of clock cycles between bits on the wire
    // 10MHz -> 115200 Baud is (10000000/115200) ~= 87
    // Doesn't need to be perfect, just accurate enough to last the entire frame width
    parameter TICKS_PER_BIT=87,

    // number of bits in a single uart frame. Standard
    // is 8, but my special case requries 64 bit slices.
    parameter FRAME_WIDTH=64
)
(
    input	            clk,
    output	            tx,

    // RX AXIS Interface
    input [FRAME_WIDTH-1:0]         s_axis_tx_tdata,
    output                          s_axis_tx_tready,
    input                           s_axis_tx_tvalid
);

// UART TX State Machine States
localparam IDLE      = 3'd0;
localparam START_BIT = 3'd1;
localparam DATA_BITS = 3'd2;
localparam STOP_BIT  = 3'd3;
localparam CLEANUP   = 3'd4;

reg [2:0]                tx_state = IDLE;
reg [FRAME_WIDTH-1:0]    tx_data = 0;

reg                 tx_val = 0;
reg [8:0]           tick_count = 0;
reg [8:0]           bit_count = 0;
reg                 tx_tready = 0;

always @ ( posedge clk ) begin
    case ( tx_state )
        IDLE : begin
            tx_val     <= 1;
            bit_count  <= 0;
            tick_count <= 0;
            if ( s_axis_tx_tvalid ) begin
                tx_data   <= s_axis_tx_tdata;
                tx_tready <= 0;
                tx_state  <= START_BIT;
            end
            else begin
                tx_tready <= 1;
                tx_state  <= IDLE;
            end
        end
        
        START_BIT : begin
            tx_val <= 0;
            bit_count <= 0;
            if ( tick_count < TICKS_PER_BIT ) begin
                tick_count <= tick_count + 1;
                tx_state   <= START_BIT;
            end
            else begin
                tick_count <= 0;
                tx_state   <= DATA_BITS;
            end
        end
        
        DATA_BITS : begin
            tx_val    <= tx_data[bit_count];
            if ( tick_count < TICKS_PER_BIT - 1 ) begin
                tick_count <= tick_count + 1;
                tx_state   <= DATA_BITS;
            end
            else begin
                tick_count <= 0;
                if ( bit_count < FRAME_WIDTH-1 ) begin
                    bit_count <= bit_count + 1;
                    tx_state  <= DATA_BITS;
                end
                else begin
                    bit_count <= 0;
                    tx_state  <= STOP_BIT;
                end
            end
        end
        
        STOP_BIT : begin
            tx_val <= 1;
            if ( tick_count < TICKS_PER_BIT ) begin
                tick_count <= tick_count+1;
                tx_state   <= STOP_BIT;
            end
            else begin
                tx_state <= CLEANUP;
            end
        end
        
        CLEANUP : begin
            tx_tready <= 1;
            tx_state  <= IDLE;
        end
    endcase
end

assign tx               = tx_val;
assign s_axis_tx_tready = tx_tready;

endmodule

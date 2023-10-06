// Sahas Munamala
// Created: Mon Oct 02 2023, 07:49PM PDT

// Module: uart_rx
// Purpose: UART Receive Side Module
module uart_rx #(
    // # of clock cycles between bits on the wire
    // 10MHz -> 115200 Baud is (10000000/115200) ~= 87
    // Doesn't need to be perfect, just accurate enough
    // to last the entire frame width
    parameter TICKS_PER_BIT=87,

    // number of bits in a single uart frame. Standard
    // is 8, but my special case requries 64 bit slices.
    parameter FRAME_WIDTH=64
) (
    input	            clk,
    input	            rx,

    // RX AXIS Interface
    output [FRAME_WIDTH-1:0]        m_axis_rx_tdata,
    input                           m_axis_rx_tready,
    output reg                      m_axis_rx_tvalid = 0
);

// UART RX State Machine States
localparam IDLE      = 3'd0;
localparam START_BIT = 3'd1;
localparam DATA_BITS = 3'd2;
localparam STOP_BIT  = 3'd3;
localparam CLEANUP   = 3'd4;

reg [2:0]      rx_state = IDLE;

// Double Register Incoming Data
// This way, we can compare prev to curr and  catch the start
// bit from the idle state
reg             rx_stage_1;
reg             rx_stage_2;
always @ ( posedge clk ) begin
    rx_stage_1 <= rx;
    rx_stage_2 <= rx_stage_1;
end

reg [8:0]       tick_count;
reg [8:0]       bit_count;

reg [FRAME_WIDTH-1:0]           frame_data;

// RX Side State Machine
always @ ( posedge clk ) begin
    case ( rx_state )
        IDLE : begin
            tick_count <= 0;
            bit_count  <= 0;

            // Start bit is 0 from idle state of 1
            if ( rx_stage_2 == 1'b0 ) begin
                rx_state <= START_BIT;
            end
            else begin
                rx_state <= IDLE;
            end
        end // case: IDLE

        START_BIT : begin
            // wait a half-bit time so bit samples
            // align with incoming signal.
            bit_count <= 0;
            if ( tick_count < (TICKS_PER_BIT-1)/2 ) begin
                tick_count <= tick_count + 1;
                rx_state <= START_BIT;
            end
            else begin
                // check if bit is still 0. Otherwise, ignore glitch.
                if ( rx_stage_2 == 1'b0 ) begin
                    tick_count <= 0;
                    rx_state <= DATA_BITS;
                end
                else begin
                    rx_state <= IDLE;
                end
            end
        end // case: START_BIT

        DATA_BITS : begin
            // wait for next bit time
            if ( tick_count < TICKS_PER_BIT - 1 ) begin
                tick_count <= tick_count + 1; 
                rx_state   <= DATA_BITS;
            end
            else begin
                // fill up frame data
                tick_count <= 0;
                if ( bit_count < FRAME_WIDTH ) begin
                    bit_count  <= bit_count + 1;
                    frame_data[bit_count] <= rx_stage_2;
                    rx_state <= DATA_BITS;
                end
                else begin
                    bit_count <= 0;
                    rx_state  <= STOP_BIT;
                end
            end
        end // case: DATA_BITS

        STOP_BIT : begin
            if ( tick_count < TICKS_PER_BIT-1 ) begin
                tick_count <= tick_count+1;
                rx_state <= STOP_BIT;
            end
            else begin
                m_axis_rx_tvalid <= 1'b1;
                rx_state <= CLEANUP;
            end
        end // case: STOP_BIT

        CLEANUP : begin
            if ( m_axis_rx_tready ) begin
                m_axis_rx_tvalid <= 1'b0;
                rx_state <= IDLE;
            end
            else begin
                rx_state <= CLEANUP;
            end
        end // case: CLEANUP
    endcase
end


assign m_axis_rx_tdata = frame_data;


endmodule

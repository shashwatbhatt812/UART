module protocol_rx(

    input clk,
    input rst,

    input rx_valid,
    input [7:0] rx_data,

    output reg frame_ok,
    output reg [7:0] address,
    output reg [7:0] command,
    output reg [7:0] data

);

reg [2:0] state;
reg [7:0] checksum;

localparam WAIT_START = 3'd0,
           GET_ADDR   = 3'd1,
           GET_CMD    = 3'd2,
           GET_DATA   = 3'd3,
           GET_CHK    = 3'd4,
           GET_STOP   = 3'd5;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin
        state <= WAIT_START;
        frame_ok <= 0;
    end

    else if(rx_valid)
    begin

        frame_ok <= 0;

        case(state)

        WAIT_START:
        begin
            if(rx_data==8'hAA)
                state<=GET_ADDR;
        end

        GET_ADDR:
        begin
            address<=rx_data;
            state<=GET_CMD;
        end

        GET_CMD:
        begin
            command<=rx_data;
            state<=GET_DATA;
        end

        GET_DATA:
        begin
            data<=rx_data;
            checksum<=address^command^rx_data;
            state<=GET_CHK;
        end

        GET_CHK:
        begin
            if(rx_data==checksum)
                state<=GET_STOP;
            else
                state<=WAIT_START;
        end

        GET_STOP:
        begin
            if(rx_data==8'h55)
                frame_ok<=1;

            state<=WAIT_START;
        end

        endcase

    end

end

endmodule
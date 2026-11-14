module protocol_tx(
    input clk,
    input rst,
    input start,

    input [7:0] address,
    input [7:0] command,
    input [7:0] data,

    output reg [7:0] tx_data,
    output reg tx_valid,
    output reg done
);

reg [2:0] state;
reg [7:0] checksum;

localparam IDLE     = 3'd0,
           START_B  = 3'd1,
           ADDR_B   = 3'd2,
           CMD_B    = 3'd3,
           DATA_B   = 3'd4,
           CHK_B    = 3'd5,
           STOP_B   = 3'd6;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        state <= IDLE;
        tx_valid <= 0;
        done <= 0;
    end
    else
    begin
        tx_valid <= 1'b1;
        done <= 1'b0;

        case(state)

        IDLE:
        begin
            tx_valid <= 0;
            if(start)
            begin
                checksum <= address ^ command ^ data;
                state <= START_B;
            end
        end

        START_B:
        begin
            tx_data <= 8'hAA;
            state <= ADDR_B;
        end

        ADDR_B:
        begin
            tx_data <= address;
            state <= CMD_B;
        end

        CMD_B:
        begin
            tx_data <= command;
            state <= DATA_B;
        end

        DATA_B:
        begin
            tx_data <= data;
            state <= CHK_B;
        end

        CHK_B:
        begin
            tx_data <= checksum;
            state <= STOP_B;
        end

        STOP_B:
        begin
            tx_data <= 8'h55;
            done <= 1;
            state <= IDLE;
        end

        endcase
    end
end

endmodule
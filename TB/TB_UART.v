`timescale 1ns/1ps

module TB_protocol;

reg clk;
reg rst;
reg start;

reg [7:0] address;
reg [7:0] command;
reg [7:0] data;

wire [7:0] tx_data;
wire tx_valid;
wire done;

wire frame_ok;
wire [7:0] rx_address;
wire [7:0] rx_command;
wire [7:0] rx_data;

//------------------------------------------------------
// Instantiate Transmitter
//------------------------------------------------------

protocol_tx TX(
    .clk(clk),
    .rst(rst),
    .start(start),
    .address(address),
    .command(command),
    .data(data),
    .tx_data(tx_data),
    .tx_valid(tx_valid),
    .done(done)
);

//------------------------------------------------------
// Instantiate Receiver
//------------------------------------------------------

protocol_rx RX(
    .clk(clk),
    .rst(rst),
    .rx_valid(tx_valid),
    .rx_data(tx_data),
    .frame_ok(frame_ok),
    .address(rx_address),
    .command(rx_command),
    .data(rx_data)
);

//------------------------------------------------------
// Clock Generation
//------------------------------------------------------

always #5 clk = ~clk;

//------------------------------------------------------
// Task : Send Packet
//------------------------------------------------------

task send_packet;

input [7:0] addr;
input [7:0] cmd;
input [7:0] dat;

begin

    @(posedge clk);
    address = addr;
    command = cmd;
    data    = dat;

    start = 1;

    @(posedge clk);
    start = 0;

    wait(done);

    repeat(2) @(posedge clk);

end

endtask

//------------------------------------------------------
// Initial Block
//------------------------------------------------------

initial
begin

    clk = 0;
    rst = 1;
    start = 0;

    address = 0;
    command = 0;
    data = 0;

    #20;
    rst = 0;

    //--------------------------------------------------
    // Test 1
    //--------------------------------------------------

    send_packet(8'h01,8'h10,8'h5A);

    //--------------------------------------------------
    // Test 2
    //--------------------------------------------------

    send_packet(8'h02,8'h20,8'hAA);

    //--------------------------------------------------
    // Test 3
    //--------------------------------------------------

    send_packet(8'hFF,8'h55,8'h99);

    #100;
    $finish;

end

//------------------------------------------------------
// Monitor
//------------------------------------------------------

always @(posedge clk)
begin

    if(tx_valid)
    begin
        $display("Time=%0t  TX Byte = %h",$time,tx_data);
    end

    if(frame_ok)
    begin
        $display("--------------------------------");
        $display("FRAME RECEIVED SUCCESSFULLY");
        $display("Address = %h",rx_address);
        $display("Command = %h",rx_command);
        $display("Data    = %h",rx_data);
        $display("--------------------------------");
    end

end

endmodule
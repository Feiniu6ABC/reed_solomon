`timescale 1ns / 1ps

module BerlekampMassey_tb();

reg clk;
reg rst_n;
reg [127:0] data_in;
reg valid_in;
wire [127:0] poly_out;
wire valid_out;
wire busy;

// Instantiate the Unit Under Test (UUT)
BerlekampMassey uut (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_in(data_in), 
    .valid_in(valid_in), 
    .poly_out(poly_out), 
    .valid_out(valid_out), 
    .busy(busy)
);

// Clock generation
always begin
    #5 clk = ~clk;
end

// Test scenario
initial begin
    // Initialize Inputs
    clk = 0;
    rst_n = 0;
    data_in = 0;
    valid_in = 0;

    // Wait for global reset
    #100;
    rst_n = 1;

    // Test case using the same data as in C++ code
    #10;
    data_in = 128'h02_04_08_10_20_80_80_02_04_08_10_20_40_80_00_00;
    valid_in = 1;
    #10;
    valid_in = 0;

    // Wait for processing
    wait(valid_out);
    $display("Berlekamp-Massey result:");
    $display("%h", poly_out);

    // End simulation
    #100;
    $finish;
end

// Monitor changes
initial begin
    $monitor("Time=%t, State=%d, N=%d, L=%d, busy=%b, valid_out=%b", 
             $time, uut.current_state, uut.N, uut.L, busy, valid_out);
end

endmodule

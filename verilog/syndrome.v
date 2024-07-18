module syndrome(
    input rst_n,
    input clk,
    input [127:0] data_in,
    input valid_in,

    output [127:0] syndrome_out,
    output valid_out
);

wire [7:0] syndrome[15:0];
wire [15:0] valid_out_temp;


genvar gen_i;
generate
    for (gen_i = 0; gen_i < 16; gen_i = gen_i+1)begin :gen_syndrome_slice
        syndrome_slice syndrome_slice_int(
            .rst_n      (rst_n),
            .clk        (clk),
            .data_in    (data_in),
            .i          (gen_i),
            .valid_in   (valid_in),

            .syndrome   (syndrome[gen_i]),
            .valid_out  (valid_out_temp[gen_i])
        );
    end
endgenerate


genvar gen_j;
generate
    for (gen_j = 0; gen_j < 16; gen_j = gen_j+1)begin :gen_syndrome_out
        assign syndrome_out[gen_j*8 +:8] = syndrome[gen_j];
    end
endgenerate

assign valid_out = &valid_out_temp;

endmodule

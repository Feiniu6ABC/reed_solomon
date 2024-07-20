module syndrome_slice(
    input rst_n,
    input clk,
    input [127:0] data_in,
    input valid_in,
    input [3:0] i,

    output reg [7:0] syndrome,
    output reg valid_out
);

reg [127:0] data_in_reg;
reg [8:0] cnt;


wire [127:0] alpha_power;
wire [127:0] mul_result;

wire [7:0] level1[7:0];
wire [7:0] level2[3:0];
wire [7:0] level3[1:0];

wire [7:0] sum_result;

always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        data_in_reg <= 128'b0;
    end else begin
        data_in_reg <= data_in;
    end
end



genvar gen_i;
generate
    for (gen_i = 0; gen_i < 16; gen_i = gen_i + 1) begin
        gf256_power_lut power_lut(
            .addr   (((cnt - 1) * 16 + gen_i )* (i + 1)),
            .data   (alpha_power[gen_i * 8 +: 8])
        );
    end
endgenerate


genvar gen_j;
generate
    for (gen_j = 0; gen_j < 16; gen_j = gen_j + 1) begin
        gf256_mul mul_inst(
            .a      (data_in_reg[gen_j * 8 +: 8]),
            .b      (alpha_power[gen_j * 8 +: 8]),
            .result (mul_result[gen_j * 8 +: 8])
        );
    end
endgenerate

assign level1[0] = mul_result[0 * 8 +: 8] ^ mul_result[1 * 8 +: 8];
assign level1[1] = mul_result[2 * 8 +: 8] ^ mul_result[3 * 8 +: 8];
assign level1[2] = mul_result[4 * 8 +: 8] ^ mul_result[5 * 8 +: 8];
assign level1[3] = mul_result[6 * 8 +: 8] ^ mul_result[7 * 8 +: 8];
assign level1[4] = mul_result[8 * 8 +: 8] ^ mul_result[9 * 8 +: 8];
assign level1[5] = mul_result[10* 8 +: 8] ^ mul_result[11* 8 +: 8];
assign level1[6] = mul_result[12* 8 +: 8] ^ mul_result[13* 8 +: 8];
assign level1[7] = mul_result[14* 8 +: 8] ^ mul_result[15* 8 +: 8];

assign level2[0] = level1[0] ^ level1[1];
assign level2[1] = level1[2] ^ level1[3];
assign level2[2] = level1[4] ^ level1[5];
assign level2[3] = level1[6] ^ level1[7];

assign level3[0] = level2[0] ^ level2[1];
assign level3[1] = level2[2] ^ level2[3];

assign sum_result = level3[0] ^ level3[1];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        syndrome <= 8'b0;
        cnt <= 8'b0;
    end else if (valid_in) begin
        if (cnt < 8'd16) begin
            syndrome <= syndrome ^ sum_result;
            cnt <= cnt + 1'b1;
        end else begin
            syndrome <= syndrome ^ sum_result;
            cnt <= 8'b0;
        end
    end
end

always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        valid_out <= 1'b0;
    end else begin
        if (cnt == 8'd15)begin
            valid_out <= 1'b1;
        end
    end

end

endmodule

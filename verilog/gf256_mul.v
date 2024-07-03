module gf256_mul(
    input wire [7:0] a,
    input wire [7:0] b,
    output reg [7:0] result
);
    reg [15:0] tmp;
    integer i;

    always @(*) begin
        tmp = 16'b0;
        for (i = 0; i < 8; i = i + 1) begin
            if (b[i]) begin
                tmp = tmp ^ (a << i);
            end
        end
        for (i = 15; i >= 8; i = i - 1) begin
            if (tmp[i]) begin
                tmp = tmp ^ (16'h11B << (i - 8));
            end
        end
        result = tmp[7:0];
    end
endmodule

module gf256_div(
    input [7:0] a,
    input [7:0] b,
    output [7:0] result
);
    wire [7:0] inverse_b;
    wire [7:0] product;

    // 实例化逆元模块
    gf256_inv inv_module(
        .x(b),
        .inv_x(inverse_b)
    );

    // 实例化乘法模块
    gf256_mul mul_module(
        .a(a),
        .b(inverse_b),
        .result(product)
    );

    // 组合逻辑连接输出
    assign result = product;

endmodule

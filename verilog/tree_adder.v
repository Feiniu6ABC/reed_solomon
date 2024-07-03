//gen by chatgpt4
module tree_adder #(
    parameter NUM_INPUTS = 16,
    parameter DATA_WIDTH = 8
)(
    input wire [DATA_WIDTH-1:0] data_in[NUM_INPUTS-1:0],
    output wire [DATA_WIDTH-1:0] data_out
);

    // 计算树形加法器的级数
    localparam NUM_LEVELS = $clog2(NUM_INPUTS);

    // 定义内部信号
    wire [DATA_WIDTH-1:0] sum[NUM_LEVELS:0][NUM_INPUTS-1:0];

    // 第一级输入
    genvar i;
    generate
        for (i = 0; i < NUM_INPUTS; i = i + 1) begin
            assign sum[0][i] = data_in[i];
        end
    endgenerate

    // 生成树形加法器的各级
    genvar level, j;
    generate
        for (level = 1; level <= NUM_LEVELS; level = level + 1) begin
            for (j = 0; j < NUM_INPUTS >> level; j = j + 1) begin
                assign sum[level][j] = gf256_add(sum[level-1][j*2], sum[level-1][j*2+1]);
            end
        end
    endgenerate

    // 输出最终结果
    assign data_out = sum[NUM_LEVELS][0];

    // GF(256) 域上的加法操作
    function [DATA_WIDTH-1:0] gf256_add;
        input [DATA_WIDTH-1:0] a, b;
        begin
            gf256_add = a ^ b;
        end
    endfunction

endmodule

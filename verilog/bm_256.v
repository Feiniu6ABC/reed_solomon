module BerlekampMassey(
    input rst_n,
    input clk,
    input reset,
    input enable,
    input [7:0] data_in,
    input [7:0] syndome_len,
    input valid_in,
    output reg [7:0] poly_out,
    output reg valid_out,
    output reg busy
);

parameter MAX_LENGTH = 16;  

reg [7:0] data_buffer[MAX_LENGTH-1:0];
reg [7:0] data_pointer;

reg [7:0] C[MAX_LENGTH-1:0];
reg [7:0] B[MAX_LENGTH-1:0];
reg [7:0] T[MAX_LENGTH-1:0];
reg [7:0] L, m, N;
reg [7:0] b, d, coef;
reg [7:0] temp;


wire [7:0] products[MAX_LENGTH-1:0];
wire [7:0] products[MAX_LENGTH-1:0];

wire resize;

reg [7:0] C_ptr;
reg [7:0] B_ptr;
reg [7:0] T_ptr;

reg [7:0] counter;
reg [7:0] n;

reg [3:0] current_state;
reg [3:0] next_state;
// 有限域算术模块实例化
wire [7:0] sum_tree[MAX_LENGTH-1:0];

wire [7:0] gf256_mul_result[MAX_LENGTH-1:0];
reg  [7:0] gf256_mul_result_reg[MAX_LENGTH-1:0];

parameter IDLE = 4'b0;
parameter INPUT = 4'b1;
parameter CALC_D = 4'b10;
parameter RESIZE = 4'b11;
parameter UPDATE_C = 4'b100;
parameter OUPUT   = 4'b101;


always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        current_state  <= IDLE;
    end else begin
        current_state <= next_state;
    end 
end


always@(*)begin
    case(current_state)
        IDLE: if (enable)begin
                next_state  = INPUT;
            end else begin
                next_state = next_state;
            end
        INPUT:  if (data_pointer == syndome_len - 1)begin
                    next_state = CALC_D;
                end else begin
                    next_state = next_state;
                end
        CALC_D: if (calc_done)begin
                    next_state = DONE;
                end else begin
                    next_state = RESIZE;
                end
        RESIZE:
                next_state = UPDATE_C;
        UPDATE_C:
                if (calc_done)begin
                    next_state = FINISH;
                end else begin
                    next_state = CALC_D;
                end
        FINISH:
                if (output_done)begin
                    next_state = IDLE;
                end else begin
                    next_state = FINISH;
                end
    endcase
end

always@(posede clk or negedge rst_n)begin
    if (!rst_n)begin
        n <= 8'b0;
    end else begin
        if (current_state == IDLE && enable)begin
            n <= syndome_len;
        end else if (current_state == FINISH)begin
            n <= 8'b0;
        end else begin
            n <= n;
        end
    end
end


always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        data_pointer <= 8'b0;
    end else begin
        if (current_state == INPUT && valid_in)begin
            data_buffer[data_pointer] = data_in;
            data_pointer <= data_pointer + 1;
        end else begin
            data_buffer <= data_buffer;
            data_pointer <= data_pointer;
        end
    end
end


genvar i;
generate
    for (i = 0; i < MAX_LENGTH; i = i + 1) begin
        gf256_mult mult_inst (
            .a(C[i]),
            .b(data_buffer[i]),
            .result(products[i])
        );
    end
endgenerate

always @(posedge clk or rst_n) begin
    if (!rst_n)begin
        for (i = 0; i < MAX_LENGTH; i = i + 1) begin
            products_reg[i] <= 8'b0;
        end
    end else begin
        for (i = 0; i < MAX_LENGTH; i = i + 1) begin
            products_reg[i] <= products[i];
        end
    end
end

always @(posedge clk) begin
    d <= 0; // 初始化 sum_reg 为 0
    for (i = 0; i < MAX_LENGTH; i = i + 1) begin
        d <= d ^ products_reg[i]; // 使用异或运算符计算 GF(256) 中的加法
    end
end

assign sum_tree[0] = products_reg[0] ^ products_reg[1];
assign sum_tree[1] = products_reg[2] ^ products_reg[3];
assign sum_tree[2] = products_reg[4] ^ products_reg[5];
assign sum_tree[3] = products_reg[6] ^ products_reg[7];
assign sum_tree[4] = products_reg[8] ^ products_reg[9];
assign sum_tree[5] = products_reg[10] ^ products_reg[11];
assign sum_tree[6] = products_reg[12] ^ products_reg[13];
assign sum_tree[7] = products_reg[14] ^ products_reg[15];

assign sum_tree[8] = sum_tree[0] ^ sum_tree[1];
assign sum_tree[9] = sum_tree[2] ^ sum_tree[3];
assign sum_tree[10] = sum_tree[4] ^ sum_tree[5];
assign sum_tree[11] = sum_tree[6] ^ sum_tree[7];

assign sum_tree[12] = sum_tree[8] ^ sum_tree[9];
assign sum_tree[13] = sum_tree[10] ^ sum_tree[11];

assign sum_tree[14] = sum_tree[12] ^ sum_tree[13];

always @(posedge clk) begin
    d <= sum_tree[14];
end


always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        for (i = 0; i < MAX_LENGTH; i = i + 1) begin
            C[i] <= 8'b0;
        end
    end
    if (current_state == INPUT)begin
        for (i = 1; i < MAX_LENGTH; i = i + 1) begin
            C[i] <= 8'b0;
        end
        C[0] = 8'b1;
    end else if (current_state == RESIZE)begin
        if (C_ptr >= (B_ptr + m))begin
            C_ptr <= C_ptr;
        end else begin
            C_ptr <= (B_ptr + m);
        end
    end
end

gf256_div div_inst (
            .a(d),
            .b(b),
            .result(coef)
);

genvar i;
generate
    for (i = 0; i < MAX_LENGTH; i = i + 1) begin
        gf256_mul mul_inst (
            .a(coef),
            .b(B[i]),
            .result(gf256_mul_result[i])
        );
    end
endgenerate

// 在时钟上升沿捕获乘法结果并存储到寄存器中
always @(posedge clk) begin
    for (i = 0; i < MAX_LENGTH; i = i + 1) begin
        gf256_mul_result_reg[i] <= gf256_mul_result[i];
    end
end


endmodule

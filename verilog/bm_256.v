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

//wire [7:0] sum_tree[MAX_LENGTH-1:0];

wire [7:0] gf256_mul_result[MAX_LENGTH-1:0];
reg  [7:0] gf256_mul_result_reg[MAX_LENGTH-1:0];

wire [7:0] sum_result;

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

tree_adder #(
    .NUM_INPUTS(16),
    .DATA_WIDTH(8)
) adder_inst (
    .data_in(products_reg),
    .data_out(sum_result)
);


always @(posedge clk) begin
    d <= sum_result;
end


always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        for (i = 0; i < MAX_LENGTH; i = i + 1) begin
            C[i] <= 8'b0;
        end
        C_ptr <= 8'b0;
    end
    if (current_state == INPUT)begin
        for (i = 1; i < MAX_LENGTH; i = i + 1) begin
            C[i] <= 8'b0;
        end
        C[0] <= 8'b1;
        C_ptr <= 8'b0;
    end else if (current_state == RESIZE)begin
        if (C_ptr >= (B_ptr + m))begin
            C_ptr <= C_ptr;
        end else begin
            C_ptr <= (B_ptr + m);
        end
        C <= C;
    end else if (current_state == UPDATE_C)begin
        for (i = 0; i < MAX_LENGTH; i = i + 1) begin
            C[i + m] <= adder_out[i];
        end
        C_ptr <= C_ptr;
    end else begin
        C       <= C;
        C_ptr   <= C_ptr;
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
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        gf256_mul_result_reg <= '0;
    end else begin
        for (i = 0; i < MAX_LENGTH; i = i + 1) begin
            gf256_mul_result_reg[i] <= gf256_mul_result[i];
        end
    end
end

genvar i;
generate
    for (i = 0; i < MAX_LENGTH; i = i + 1) begin

        //assign adder_in[i] = (i < B_size) ? gf256_mul_result_reg[i] : 8'b0;
        assign adder_in[i] =  gf256_mul_result_reg[i];
        
        gf256_adder adder_inst (
            .a(C[i + m]),
            .b(adder_in[i]),
            .sum(adder_out[i])
        );
    end
endgenerate


always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        L <= 8'b0;
        b <= 8'b1;
        m <= 8'b1;
        for (i = 1; i < MAX_LENGTH; i = i + 1) begin
            B[i] <= 8'b0;
        end
        B[0] <= 8'b1;
    end else begin
        if (current_state == UPDATE_C)begin
            if ((L << 1) <= N)begin
                L <= N + 1 - L;
                B <= T;
                b <= d;
                m <= 1;
            end else begin
                    L <= L;
                    B <= B;
                    b <= b;
                    m <= m + 1;
                end
        end else begin
                L <= L;
                B <= B;
                b <= b;
                m <= m;
        end
    end
end

endmodule

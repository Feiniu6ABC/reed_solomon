module BerlekampMassey(
    input rst_n,
    input clk,
    input [127:0] data_in,
    input valid_in,
    output [127:0] poly_out,
    output reg valid_out,
    output reg busy
);

//parameter 16 = 16;  

reg [7:0] data_buffer[16-1:0];

reg [7:0] C[16-1:0];
reg [7:0] B[16-1:0];
//reg [7:0] T[16-1:0];
reg [7:0] L, m, N, b, d;
reg [7:0] temp;

wire [7:0] coef;


wire [7:0] products[16-1:0];
reg [7:0] products_reg[16-1:0];

wire [7:0] adder_in[16-1: 0];
wire [7:0] adder_out[16-1: 0];

wire resize;

reg [7:0] C_ptr;
reg [7:0] B_ptr;
//reg [7:0] T_ptr;


reg [7:0] length;
reg [7:0] n;

reg [3:0] current_state;
reg [3:0] next_state;

//wire [7:0] sum_tree[16-1:0];

wire [7:0] gf256_mul_result[16-1:0];
reg  [7:0] gf256_mul_result_reg[16-1:0];


wire [7:0] level1[7:0];  // 第一级异或输出
wire [7:0] level2[3:0];  // 第二级异或输出
wire [7:0] level3[1:0];  // 第三级异或输出

wire [7:0] sum_result;

//reg [7:0] counter;

wire [127:0] poly_out_temp;

parameter IDLE = 4'b0;
parameter CALC_D = 4'b1;
parameter UPDATE_C = 4'b10;
parameter FINISH = 4'b11;

always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        busy <= 1'b0;
        valid_out <= 1'b0;
    end else begin
        case(next_state)
            CALC_D : begin
                    busy <= 1'b1;
                    valid_out <= 1'b0;
                end
            UPDATE_C: begin
                    busy <= 1'b1;
                    valid_out <= 1'b0;
                end
            FINISH  :begin
                    busy <= 1'b0;
                    valid_out <= 1'b1;
            end
            default: begin
                    busy <= 1'b0;
                    valid_out <= 1'b0;
            end
        endcase
    end
end


genvar j;
generate
    for (j = 0; j < 16; j = j + 1) begin : gen_poly_out
        assign poly_out_temp[j*8 +: 8] = (current_state == FINISH) ? C[j] : 8'b0;
    end
endgenerate

assign poly_out = poly_out_temp;


always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        current_state  <= IDLE;
    end else begin
        current_state <= next_state;
    end 
end


always@(*)begin
    case(current_state)
        IDLE: if (valid_in)begin
                next_state  = CALC_D;
            end else begin
                next_state = IDLE;
            end
        CALC_D: 
                if (N<8'd16)begin
                    next_state = UPDATE_C;
                end else begin
                    next_state = FINISH;
                end                   
            
        UPDATE_C:
                if (N < 8'd16)begin
                    next_state = CALC_D;
                end else begin
                    next_state = FINISH;
                end
        FINISH:
                next_state = IDLE;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        n <= 8'b0;
    end else begin
        if (current_state == IDLE || current_state == FINISH)begin
            n <= 0;
        end else if (current_state == CALC_D)begin
            n <= n + 1;
        end else begin
            n <= n;
        end
    end
end

integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            data_buffer[i] <= 8'b0;
        end
    end else begin
        if (current_state == IDLE && valid_in) begin
            for (i = 0; i < 16; i = i + 1) begin
                data_buffer[i] <= data_in[i*8 +: 8];
            end
        end
    end
end


genvar gen_i;
generate
    for (gen_i = 0; gen_i < 16; gen_i = gen_i + 1) begin
        gf256_mul mult_inst (
            .a(gen_i < L ? C[gen_i+1] : 8'b0),  // 只使用 C[1] 到 C[L]
            .b(gen_i < N ? data_buffer[N-gen_i-1] : 8'b0),  // 使用正确的数据
            .result(products[gen_i])
        );
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        for (i = 0; i < 16; i = i + 1) begin
            products_reg[i] <= 8'b0;
        end
    end else begin
        for (i = 0; i < 16; i = i + 1) begin
            products_reg[i] <= products[i];
        end
    end
end


//assign level1[0] = products_reg[0] ^ products_reg[1];
//assign level1[1] = products_reg[2] ^ products_reg[3];
//assign level1[2] = products_reg[4] ^ products_reg[5];
//assign level1[3] = products_reg[6] ^ products_reg[7];
//assign level1[4] = products_reg[8] ^ products_reg[9];
//assign level1[5] = products_reg[10] ^ products_reg[11];
//assign level1[6] = products_reg[12] ^ products_reg[13];
//assign level1[7] = products_reg[14] ^ products_reg[15];

assign level1[0] = products[0] ^ products[1];
assign level1[1] = products[2] ^ products[3];
assign level1[2] = products[4] ^ products[5];
assign level1[3] = products[6] ^ products[7];
assign level1[4] = products[8] ^ products[9];
assign level1[5] = products[10] ^ products[11];
assign level1[6] = products[12] ^ products[13];
assign level1[7] = products[14] ^ products[15];

// 第二级：将第一级的8个结果两两异或，得到4个结果
assign level2[0] = level1[0] ^ level1[1];
assign level2[1] = level1[2] ^ level1[3];
assign level2[2] = level1[4] ^ level1[5];
assign level2[3] = level1[6] ^ level1[7];

// 第三级：将第二级的4个结果两两异或，得到2个结果
assign level3[0] = level2[0] ^ level2[1];
assign level3[1] = level2[2] ^ level2[3];

// 最后一级：将第三级的2个结果异或，得到最终结果
assign sum_result = level3[0] ^ level3[1];


always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        d <= 8'b0;
    end else begin
        case(current_state)
            CALC_D:
                begin
                    if (N == 0)begin
                        d <= data_buffer[0];
                    end else begin
                        d <= sum_result ^ data_buffer[N];
                    end
                end
            UPDATE_C:
                d <= d;
            default:
                d <= 8'b0;
        endcase
    end
end



always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        for (i = 0; i < 16; i = i + 1) begin
            C[i] <= 8'b0;
        end
        C_ptr <= 8'b0;
    end
    if (current_state == IDLE)begin
        for (i = 1; i < 16; i = i + 1) begin
            C[i] <= 8'b0;
        end
        C[0] <= 8'b1;
        C_ptr <= 8'b0;

    end else if (current_state == UPDATE_C)begin
        if (C_ptr >= (B_ptr + m))begin
            C_ptr <= C_ptr;
        end else begin
            C_ptr <= (B_ptr + m);
        end

        for (i = 0; i < 16; i = i + 1) begin
            if ((i+m) < 16)begin
                C[i + m] <= adder_out[i];
            end
        end
    end 
end

gf256_div div_inst (
            .a(d),
            .b(b),
            .result(coef)
);


genvar gen_j;
generate
    for (gen_j = 0; gen_j < 16; gen_j = gen_j + 1) begin
        gf256_mul mul_inst (
            .a(coef),
            .b(B[gen_j]),
            .result(gf256_mul_result[gen_j])
        );
    end
endgenerate

// 在时钟上升沿捕获乘法结果并存储到寄存器中
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        for (i = 0; i < 16; i = i + 1) begin
            gf256_mul_result_reg[i] <= 0;
        end
    end else begin
        for (i = 0; i < 16; i = i + 1) begin
            gf256_mul_result_reg[i] <= gf256_mul_result[i];
        end
    end
end

genvar k;
generate
    for (k = 0; k < 16; k = k + 1) begin

        assign adder_in[k] =  gf256_mul_result[k];
        
        gf256_add adder_inst (
            .a(C[k + m]),
            .b(adder_in[k]),
            .result(adder_out[k])
        );
    end
endgenerate

always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        N <= 8'b0;
    end else begin
        if (current_state == IDLE || current_state == FINISH)begin
            N <= 8'b0;
        end else begin
            if (current_state == UPDATE_C)begin
                N <= N + 1;
            end
        end
    end
end


always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        L <= 8'b0;
        b <= 8'b1;
        for (i = 1; i < 16; i = i + 1) begin
            B[i] <= 8'b0;
        end
        B[0] <= 8'b1;
        B_ptr <= 8'b0;
    end else begin
        if (current_state == UPDATE_C)begin
            if ((L << 1) <= N)begin
                L <= N + 1 - L;
                //B <= T;
                for (i = 0; i < 16; i = i + 1) begin
                    B[i] <= C[i];
                end
                B_ptr <= C_ptr;
                b <= d;
            end
        end else begin
            if (current_state == FINISH)begin
                L <= 8'b0;
                b <= 8'b1;
                for (i = 1; i < 16; i = i + 1) begin
                    B[i] <= 8'b0;
                end
                B[0] <= 8'b1;
                B_ptr <= 8'b0;
            end
        end
    end
end


always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        m <= 8'b0;
    end else begin
        case(current_state)
            IDLE: m <= 8'b1;

            UPDATE_C:
                if (d == 0)begin
                    m <= m + 1;
                end else begin
                    if (2 * L <= N)begin
                        m <= 1;
                    end else begin
                        m <= m + 1;
                    end
                end
            default:    m <= 1;
        endcase
    end
end

endmodule

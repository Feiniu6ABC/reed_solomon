import galois

# 创建 GF(256) 域
GF = galois.GF(2**8, irreducible_poly=galois.Poly([1, 0, 0, 0, 1, 1, 0, 1, 1])) 

# 确保使用 2 作为本原元
alpha = GF(3)

# 生成所有幂
powers = [int(alpha**i) for i in range(255)]  # 0 到 254 次幂

# 开始生成 Verilog 代码
verilog_code = """
module gf256_power_lut (
    input [7:0] addr,
    output reg [7:0] data
);

always @(*) begin
    case(addr)
"""

# 添加每个幂的值
for i, power in enumerate(powers):
    verilog_code += f"        8'd{i}: data = 8'h{power:02X};\n"

# 添加默认情况（255 次幂等于 1）
verilog_code += f"        default: data = 8'h01; // 255th power (same as 0th)\n"

# 结束 case 语句和模块
verilog_code += """    endcase
end

endmodule
"""

# 将 Verilog 代码写入文件
with open("gf256_power_lut.v", "w") as f:
    f.write(verilog_code)

print("Verilog code has been generated in 'gf256_power_lut.v'")

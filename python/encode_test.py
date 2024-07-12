import galois

# 参数设置
n = 255  # 码字长度
k = 239  # 信息长度
GF = galois.GF(2**8)  # 使用伽罗瓦域 GF(2^8)

# 生成数据
data = GF(list(range(k)))  # 生成从 0 到 238 的数据

# 创建 Reed-Solomon 编码器
rs = galois.ReedSolomon(n, k)

# 编码数据
encoded_data = rs.encode(data)

# 输出编码结果
print("Encoded Data:")
print(encoded_data)

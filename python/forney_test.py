import galois

# 参数设置
n = 255  # 码字长度
k = 239  # 信息长度
GF = galois.GF(2**8, irreducible_poly=galois.Poly([1, 0, 0, 0, 1, 1, 0, 1, 1]))  # 使用伽罗瓦域 GF(2^8)

# 生成数据
data = GF(list(range(k)))

print(data)

def calculate_syndromes(received):
    # 将接收到的数据转换为 GF(2^8) 元素
    received_array = GF(received)
    received_gf = GF([int(x) for x in received_array])
    
    # 获取本原元
    alpha = GF.primitive_element

    print(alpha)
    
    # 计算 syndrome
    syndromes = []
    for i in range(1, 17):  # 修改范围为 1 到 n-k
        syndrome = GF(0)
        for j in range(0, 255):
            syndrome += received_gf[j] * (alpha ** (i * (254 - j)))  # 修改指数计算
            if (i == 0 and (j % 16) == 15):
                print("______________________________________")
                print("j is: ", j)
                print(f"current message is {int(received_gf[j]):02X}")
                print(f"current syndrome is {int(syndrome):02X}")
                print(f"current mul_result is {int(received_gf[j] * (alpha ** (i * j))):02X}, i * j {int((i * j)):02X} is aplha^(i*j) is {int((alpha ** (i * j))):02X}")
                print("______________________________________")
        syndromes.append(syndrome)
    
    # 将syndrome转换为16进制并打印
    hex_syndromes = [f"0x{int(s):02X}" for s in syndromes]
    print(f"Syndromes: {hex_syndromes}")
    return GF(syndromes)

def chien_search(error_locator_poly):
    sigma = error_locator_poly.coeffs
    alpha = GF.primitive_element
    print(alpha)
    errors = []
    
    for i in range(n - 1, -1, -1):  # 从 254 到 0
        x = alpha**i
        # 使用 Horner 方法进行多项式求值
        error = GF(0)
        for coef in sigma:
            error = error * x + coef

        if error == 0:
            errors.append(n - 1 - i)  # 错误位置
    
    return errors

def forney_algorithm(error_locator_poly, error_positions, syndromes):
    alpha = GF.primitive_element
    # 构建 syndrome 多项式
    syndrome_poly = galois.Poly(syndromes[::-1], field=GF)
    
    # 计算 S(x) * σ(x)
    product = syndrome_poly * error_locator_poly
    
    # mod x^2t
    omega_poly = galois.Poly(product.coeffs[len(syndromes)-1:])
    print("omega poly is: ", omega_poly)

    
    error_values = []
    
    for j in error_positions:
        # 计算 X_j
        X_j = alpha ** (-j)  # 注意这里直接使用 j
        
        omega_value = omega_poly(X_j)
        
        # 计算 x * σ'(x) 的值
        x_sigma_prime_value = GF(0)

        for i in range(1, len(error_locator_poly.coeffs) - 1):
            if (i % 2 == 1):
                x_sigma_prime_value += error_locator_poly.coeffs[::-1][i] * X_j**(i)
        
        # 计算错误值
        error_value = X_j * (omega_value / x_sigma_prime_value)
        error_values.append(int(error_value))
        
        print(f"Error position: {j}")
        print(f"X_j: {X_j}")
        print(f"omega_value: {omega_value}")
        print(f"sigma_prime_value: {x_sigma_prime_value}")
        print(f"Calculated error value: {error_value}")
        print("--------------------")
    
    return error_values

# 创建 Reed-Solomon 编码器
rs = galois.ReedSolomon(n, k, field=GF)

print("generator poly is", rs.generator_poly)

print("root is", rs.generator_poly)

# 编码数据
encoded_data = rs.encode(data)

print("length of encoded data is", len(encoded_data))

# 输出编码结果
print("Encoded Data:")
print(encoded_data)

# 模拟错误
encoded_data[1] = GF(0)

encoded_data[224] = GF(0)

syndromes = calculate_syndromes(encoded_data)

error_locator_poly = galois.berlekamp_massey(syndromes)
print(f"Error locator polynomial: {error_locator_poly.coeffs}")

calculated_error_positions = chien_search(error_locator_poly)
print(f"Calculated error positions: {calculated_error_positions}")

# 使用 Forney 算法计算错误值
error_values = forney_algorithm(error_locator_poly, calculated_error_positions, syndromes)
print(f"Calculated error values: {error_values}")

# 纠正错误
corrected_data = encoded_data.copy()
for pos, value in zip(calculated_error_positions, error_values):
    corrected_data[pos] ^= value

print("Corrected Data:")
print(corrected_data)

# 验证纠错是否成功
if all(corrected_data == rs.encode(data)):
    print("Error correction successful!")
else:
    print("Error correction failed.")

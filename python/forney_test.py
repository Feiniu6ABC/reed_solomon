import galois

# 参数设置
n = 255  # 码字长度
k = 239  # 信息长度
fcr = 3  # First Consecutive Root，仅在 Forney 算法中使用

GF = galois.GF(2**8, irreducible_poly=0x11B)  # 使用伽罗瓦域 GF(2^8)

# 生成数据
data = GF(list(range(k)))

#print(data)

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
    print("ALPHA IN chien serach is: ", alpha)
    errors = []
    
    for i in range(n - 1, -1, -1):  # 从 254 到 0
        x = alpha**i
        # 使用 Horner 方法进行多项式求值
        error = GF(0)
        for coef in sigma:
            error = error * x + coef

        if error == 0:
            errors.append(n - 1 - i)  # 错误位置
    print(f"chein search result is {errors}")
    return errors


#GF = galois.GF(2**8)
def forney_algorithm(error_locator_poly, error_positions, syndromes, fcr):
    alpha = GF.primitive_element
    print("ALPHA IN forney is: ", alpha)
    syndrome_poly = galois.Poly(syndromes[::-1], field=GF)
    error_locator_poly = galois.Poly(error_locator_poly.coeffs[::-1], field=GF)
    print("error_locator is : ", error_locator_poly)
    print("syndrome is : ", syndrome_poly)

    # 构造 x * sigma'(x)
    new_coeffs = [GF(0)] * len(error_locator_poly.coeffs)
    for i in range(1, len(error_locator_poly.coeffs), 2):
        if i % 2 == 1:
            new_coeffs[i] = error_locator_poly.coeffs[::-1][i]
        else:
            new_coeffs[i] = 0
    x_sigma_prime_poly = galois.Poly(new_coeffs[::-1], field=GF)
    print("x_sigma_prime_poly is : ", x_sigma_prime_poly)

    # 计算 omega
    product = syndrome_poly * error_locator_poly
    print("product is :", product)

    t = len(syndromes) // 2
    omega_coeffs = product.coeffs[-(2*t - 1):]
    omega_poly = galois.Poly(omega_coeffs, field=GF)
    print("omega poly is: ", omega_poly)
    
    error_values = []
    
    for i in error_positions:
        print(f"value of alpha power 254 is {int(GF(2) ** 254):02X}, alpha is {int(alpha)}")
        X_i_inv = alpha ** (i + 1)  #(255 - (254 - i))
        print(f"value of i is {i} and alpha**(254 - i) {int(X_i_inv):02X}")
        omega_value = omega_poly(X_i_inv)
        print(f"result of eval poly is: {omega_value}")
        print(f"omega value is : 0x{int(omega_value):02X}")
        print(f"X_i_inv is: {int(X_i_inv):02X}")
        
        x_sigma_prime_value = x_sigma_prime_poly(X_i_inv)
        print("_____________________________________________")
        print(f"x_sigma_prime is: {int(x_sigma_prime_value):02X}")
        print(f"x_sigma_prime poly is: {int(x_sigma_prime_poly(X_i_inv)):02X}")
        print("_____________________________________________")

        print(f"omega / x_sigma_prime is: {int(omega_value / x_sigma_prime_value):02X}")
        
        error_value = ((X_i_inv) ** (fcr)) * (omega_value / x_sigma_prime_value)

        print(f"Calculated error values: {int(error_value):02X}")
        error_values.append(int(error_value))
        
        print("--------------------")
    
    return error_values
# 创建 Reed-Solomon 编码器
rs = galois.ReedSolomon(n, k, field=GF)

print("generator poly is", rs.generator_poly)
print("root is", rs.roots)

# 编码数据
encoded_data = rs.encode(data)

#print("length of encoded data is", len(encoded_data))
#print("Encoded Data:")
print(encoded_data)

# 模拟错误
encoded_data[0] = GF(1)
encoded_data[1] = GF(0)
encoded_data[2] = GF(0)
encoded_data[4] = GF(0)
encoded_data[254] = GF(0)

#encoded_data[3] = GF(0)
encoded_data[5] = GF(0)
encoded_data[7] = GF(0)
encoded_data[253] = GF(0)


syndromes = calculate_syndromes(encoded_data)

error_locator_poly = galois.berlekamp_massey(syndromes)
print(f"Error locator polynomial: {error_locator_poly}")

calculated_error_positions = chien_search(error_locator_poly)
print(f"_____________________Calculated error positions: {calculated_error_positions}")

# 使用 Forney 算法计算错误值
error_values = forney_algorithm(error_locator_poly, calculated_error_positions, syndromes, 1)


# 纠正错误
corrected_data = encoded_data.copy()
for pos, value in zip(calculated_error_positions, error_values):
    corrected_data[pos] ^= value

#print("Corrected Data:")
#print(corrected_data)

# 验证纠错是否成功
if all(corrected_data == rs.encode(data)):
    print("Error correction successful!")
else:
    print("Error correction failed.")

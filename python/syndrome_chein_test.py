import galois

n = 255
k = 239
GF = galois.GF(2**8)

data = GF(list(range(k)))

print(data)

def calculate_syndromes(received):
    # 将接收到的数据转换为 GF(2^8) 元素
    received_array = GF(received[::-1])

    received_gf = GF([int(x) for x in received_array])
    
    # 获取本原元
    alpha = GF.primitive_element
    
    # 计算 syndrome
    syndromes = []
    for i in range(1, 17):  # 修改范围为 1 到 n-k
        #print(i)
        syndrome = GF(0)
        for j in range(0, 255):
            syndrome += received_gf[j] * (alpha ** (i * j))  # 修改指数计算

            if (i == 2):
                print(j, received_gf[j], i*j, alpha ** (i * j))
        syndromes.append(syndrome)
    
    print(f"Syndromes: {[int(s) for s in syndromes]}")
    return GF(syndromes)


def chien_search(error_locator_poly):
    # 获取多项式系数
    #sigma = error_locator_poly.coeffs[::-1]  # 反转系数顺序以匹配之前的格式
    sigma = error_locator_poly.coeffs
    alpha = GF.primitive_element
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

#bch = galois.BCH(255, 239)

#c = bch.encode(data)
# 创建 Reed-Solomon 编码器
rs = galois.ReedSolomon(n, k)

print("generator poly is %d" %(rs.generator_poly))

# 编码数据
encoded_data = rs.encode(data)
#encoded_data = bch.encode(data)

print("length of encoded data is %d" %(len(encoded_data)))

# 输出编码结果
print("Encoded Data:")
print(encoded_data)


encoded_data[0] = encoded_data[0] + GF(1)
encoded_data[1] = encoded_data[1] + GF(1)


#encoded_data = encoded_data[::-1]


syndromes = calculate_syndromes(encoded_data)

#syndromes = GF([0] * 16)
error_locator_poly = galois.berlekamp_massey(syndromes)
print(f"Error locator polynomial: {error_locator_poly}")


calculated_error_positions = chien_search(error_locator_poly)
print(f"Calculated error positions: {calculated_error_positions}")

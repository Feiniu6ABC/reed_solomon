import galois

# 参数设置
n = 255  # 码字长度
k = 239  # 信息长度
GF = galois.GF(2**8, irreducible_poly=galois.Poly([1, 0, 0, 0, 1, 1, 0, 1, 1]))  # 使用伽罗瓦域 GF(2^8)
#GF = galois.GF(2**8)
# 生成数据
#data = GF([2] * 239)  # 生成从 0 到 238 的数据
data = GF(list(range(k)))

print(data)

def calculate_syndromes(received):
    # 将接收到的数据转换为 GF(2^8) 元素
    #received_array = GF(received[::-1])
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
            syndrome += received_gf[j] * (alpha ** (i * j))  # 修改指数计算
            if (i == 1):
                print(f"current message is {int(received_gf[j]):02X}")
                print(f"current syndrome is {int(syndrome):02X}")
                print(f"current mul_result is {int(received_gf[j] * (alpha ** (i * j))):02X}, i * j {int((i * j)):02X} is aplha^(i*j) is {int((alpha ** (i * j))):02X}")

            #if (i == 2):
                #print(f"{j:3d}, {received_gf[j]:3d}, {i*j:4d}, {int(alpha ** (i * j)):3d}")
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

#bch = galois.BCH(255, 239)

#c = bch.encode(data)
# 创建 Reed-Solomon 编码器
rs = galois.ReedSolomon(n, k, field=GF)
#rs = galois.ReedSolomon(n, k)

print("generator poly is %d" %(rs.generator_poly))

# 编码数据
encoded_data = rs.encode(data)
#encoded_data = bch.encode(data)

print("length of encoded data is %d" %(len(encoded_data)))

# 输出编码结果
print("Encoded Data:")
print(encoded_data)


#encoded_data[32] = encoded_data[32] + GF(1)
#encoded_data[1] = encoded_data[1] + GF(1)
#encoded_data[12] = encoded_data[12] + GF(1)

#encoded_data = encoded_data[::-1]


syndromes = calculate_syndromes(encoded_data)

#syndromes = GF([0] * 16)
error_locator_poly = galois.berlekamp_massey(syndromes)
#print(f"Error locator polynomial: {error_locator_poly}")


calculated_error_positions = chien_search(error_locator_poly)
#print(f"Calculated error positions: {calculated_error_positions}")

#new_arr = [142, 71, 173, 216, 108, 54, 27, 131, 207, 233, 250, 125, 176, 88, 44, 22]
print(galois.berlekamp_massey(syndromes).coeffs)

GF_default = galois.GF(2**8)
#print(f"默认不可约多项式: 0x{GF_default.irreducible_poly:x}")

GF_11b = galois.GF(2**8, irreducible_poly=0x11b)
#print(f"指定的不可约多项式: 0x{GF_11b.irreducible_poly:x}")

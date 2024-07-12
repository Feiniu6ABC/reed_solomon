import galois
import reedsolo
import random
import numpy as np

# 定义参数
n = 255  # 码字长度
k = 239  # 信息符号数
t = (n - k) // 2  # 纠错能力

# 创建 GF(2^8) 域
GF = galois.GF(2**8)

# 创建 Reed-Solomon 编码器
rs = reedsolo.RSCodec(n - k)

def encode_and_inject_errors(data, num_errors):
    # 编码
    encoded = rs.encode(data)
    print(f"Original encoded data: {list(encoded)}")

    # 注入错误
    error_positions = random.sample(range(n), num_errors)
    for pos in error_positions:
        encoded[pos] ^= random.randint(1, 255)  # XOR with a random value to change it
    print(f"Data with {num_errors} errors injected: {list(encoded)}")
    print(f"Actual error positions: {error_positions}")

    return encoded, error_positions

def calculate_syndromes(received, n, k):
    # 将接收到的数据转换为 GF(2^8) 元素
    received_gf = GF([int(x) for x in received])
    
    # 获取本原元
    alpha = GF.primitive_element
    
    # 计算 syndrome
    syndromes = []
    for i in range(0, n - k):
        syndrome = GF(0)
        for j in range(0, n):
            syndrome += received_gf[j] * (alpha ** (i * j))
        syndromes.append(syndrome)
    
    print(f"Syndromes: {[int(s) for s in syndromes]}")
    return GF(syndromes)

def chien_search(error_locator_poly):
    # 获取多项式系数
    sigma = error_locator_poly.coeffs[::-1]  # 反转系数顺序以匹配之前的格式
    
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

# 主程序
if __name__ == "__main__":
    # 创建一些示例数据
    data = bytes([i % 256 for i in range(k)])
    
    # 编码并注入错误
    for num_errors in [0, 1, 2, 3]:
        print(f"\nTesting with {num_errors} errors:")
        received, actual_error_positions = encode_and_inject_errors(data, num_errors)
        
        # 1. 计算syndrome多项式
        syndromes = calculate_syndromes(received, n, k)
        
        if len(syndromes) == 0:
            print("No errors detected.")
            continue
        
        # 2. 用galois库内置的BM算法计算错误定位多项式
        error_locator_poly = galois.berlekamp_massey(syndromes)
        print(f"Error locator polynomial: {error_locator_poly}")
        
        # 3. 使用Chien搜索算法计算错误位置
        calculated_error_positions = chien_search(error_locator_poly)
        print(f"Calculated error positions: {calculated_error_positions}")
        
        # 检查计算出的错误位置是否与注入的错误位置一致
        print(f"Calculated positions match actual positions: {sorted(calculated_error_positions) == sorted(actual_error_positions)}")
        
        # 额外：尝试使用reedsolomon库解码（用于验证）
        try:
            decoded, _, errata_pos = rs.decode(received)
            print(f"Decoded successfully. Errors corrected at positions: {errata_pos}")
        except reedsolo.ReedSolomonError as e:
            print(f"Decoding failed: {e}")

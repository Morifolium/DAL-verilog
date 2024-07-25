import numpy as np

seq_size = 1024
dim_size = 128

# 初始化查找表，数据类型设置为FP16
sines_lut = np.zeros((seq_size, dim_size // 2), dtype=np.float16)
cosines_lut = np.zeros((seq_size, dim_size // 2), dtype=np.float16)

# 计算频率参数和角度值
for pos in range(seq_size):
    for i in range(dim_size // 2):
        angle = pos / (10000 ** (2 * i / dim_size))
        sines_lut[pos, i] = np.sin(angle)
        cosines_lut[pos, i] = np.cos(angle)

# 将FP16格式的数据转换为其二进制表示，然后保存为Verilog初始化模块文件
def save_fp16_data(filename, array, var_name):
    with open(filename, 'w') as f:
        f.write(f"module {var_name}_init;\n")
        f.write(f"  logic [15:0] {var_name} [{seq_size-1}:0][{dim_size//2-1}:0];\n\n")
        f.write("  initial begin\n")
        for i, row in enumerate(array):
            for j, val in enumerate(row):
                f.write(f"    {var_name}[{i}][{j}] = 16'h{val.view(np.uint16):04x};\n")
        f.write("  end\n")
        f.write("endmodule\n")

# 保存查找表到文件
save_fp16_data('sines_lut.sv', sines_lut, 'sines_lut')
save_fp16_data('cosines_lut.sv', cosines_lut, 'cosines_lut')

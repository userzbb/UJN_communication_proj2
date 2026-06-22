# 语音传输系统 — BPSK/D-BPSK HDL 协仿真项目

基于 BPSK/D-BPSK 调制的数字语音传输系统，通过 AWGN 信道传输，含 PCM 编解码和 RRC 脉冲整形，目标平台为 Xilinx Zynq-7020 FPGA（通过 HDL Coder 和 Vivado）。

## 目录结构

```
proj2/
  models/                         # Simulink 模型
    bpsk/                         # BPSK 模型
      voice_tx_system.slx         # 浮点参考模型（完整音频链路）
      voice_tx_hdl_cosim.slx      # HDL 协仿真模型
      bpsk_hdl_cosim.slx          # BPSK 调制解调器 HDL 协仿真
    dbpsk/                        # D-BPSK 模型
      voice_tx_system.slx         # 浮点 D-BPSK 参考模型
      voice_tx_hdl_cosim.slx      # D-BPSK HDL 协仿真音频模型
      dbpsk_hdl_cosim.slx         # D-BPSK BER 测试台
  scripts/                        # MATLAB 脚本
    bpsk/                         # BPSK 脚本
    common/                       # 通用脚本
      run_ber_sweep.m             # BER vs Eb/N0 扫描 (0:2:10 dB)
      board_def/alinx_ax7z020.m   # ALINX AX7Z020 板卡定义
    dbpsk/                        # D-BPSK 脚本
      create_dbpsk_hdl_models.m   # 从 BPSK 模板创建 D-BPSK HDL 模型
      config_hdl_dbpsk.m          # D-BPSK DUT HDL Coder 配置
      config_hdl_dbpsk_voice.m    # 语音 TX DUT HDL Coder 配置
      verify_dbpsk_hdl.m          # D-BPSK 差分编解码验证
  audio/                          # 音频文件
    voice_input.wav               # 输入音频 (16 kHz mono)
    voice_output_ref.wav          # 参考输出
  data/                           # 实验数据 (.mat)
  vivado/                         # Vivado 工程
    bpsk/                         # BPSK DUT Vivado 工程 (xc7z020-2clg400)
  hdl_prj/hdlsrc/                 # HDL Coder 输出 (Verilog/VHDL 源码)
```

## 信号链路

```
音频 (.wav) → PCM 编码器 → BPSK/D-BPSK 调制器 → RRC 发送滤波器 → AWGN 信道 → RRC 接收滤波器 → BPSK/D-BPSK 解调器 → PCM 解码器 → 音频输出
```

D-BPSK 在 BPSK 基础上增加了差分编解码：
- **差分编码器**: `enc[n] = bit[n] XOR enc[n-1]`（初始状态 0）
- **差分解码器**: `bit[n] = enc[n] XOR enc[n-1]`

## ⚠️ 注意：BPSK 与 D-BPSK 模型同名冲突

`models/bpsk/` 和 `models/dbpsk/` 中有同名文件（`voice_tx_system.slx`、`voice_tx_hdl_cosim.slx`）。MATLAB 按名称而非路径解析模型，使用前需先移除另一版本的路径：

```matlab
% 使用 D-BPSK 模型前：
rmpath('models/bpsk');
cd('models/dbpsk');
load_system('voice_tx_system');

% 使用 BPSK 模型前：
rmpath('models/dbpsk');
addpath('models/bpsk');
load_system('voice_tx_system');
```

## 快速开始

### MATLAB / Simulink

添加项目目录到 MATLAB 路径（在项目根目录运行）：

```matlab
addpath('models/bpsk', 'models/dbpsk', 'scripts/bpsk', 'scripts/dbpsk', 'scripts/common', 'scripts/common/board_def');
```

运行 BPSK 浮点参考模型：

```matlab
open_system('voice_tx_system');
sim('voice_tx_system');
```

运行 D-BPSK 浮点参考模型：

```matlab
rmpath('models/bpsk');
cd('models/dbpsk');
open_system('voice_tx_system');
sim('voice_tx_system');
```

BER vs Eb/N0 扫描：

```matlab
run('scripts/common/run_ber_sweep.m');
```

播放参考音频：

```matlab
[audio, fs] = audioread('audio/voice_input.wav');
sound(audio, fs);
```

### Vivado 行为仿真

创建工程（首次）：

```cmd
call F:\AMDDesignTools\2025.2\Vivado\settings64.bat
cd /d D:\zizim\Documents\UJN_HW\proj2
vivado -mode batch -source vivado\bpsk\create_project.tcl
```

运行仿真 — 在 Vivado GUI 中打开 `vivado/bpsk/bpsk.xpr`，然后在 Tcl Console 中执行：

```tcl
source vivado/bpsk/sim_bpsk.tcl
```

### BPSK HDL 架构

**定点格式**: `sfix16_En14` — 16 位有符号，14 位小数，范围 [-2, +2)，分辨率 ~6.1e-5。

**LUT 映射**（BPSK_Mod_HDL / DBPSK_Mod_HDL 共用）:
- 比特 0 → `+1.0` = `0x4000` (16384)
- 比特 1 → `-1.0` = `0xC000` (-16384)

**流水线延迟**:
- BPSK: 2 个时钟周期（bits_out[C] = bits_in[C-2]）
- D-BPSK: 3 个时钟周期（bits_out[C] = bits_in[C-3]）

## 环境

| 工具 | 版本 | 路径 |
|------|------|------|
| MATLAB | R2025b | + HDL Coder, DSP HDL, Communications, Signal Processing, Audio, Fixed-Point Designer |
| Vivado | 2025.2 | `F:\AMDDesignTools\2025.2\Vivado` |
| 目标板卡 | ALINX AX7Z020 | xc7z020-2clg400 (Zynq-7020) |

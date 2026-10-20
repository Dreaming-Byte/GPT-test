# 数字信号处理 MATLAB 实验

本仓库依据哈尔滨工程大学水声工程学院《数字信号处理》实验课教学指导书（2026）实现七个实验。每个实验使用一个独立目录，主程序均为可直接运行的 MATLAB 脚本；运行后会在对应目录的 `results/` 中保存图形。

## 实验目录

| 实验 | 内容 | 主程序 |
| --- | --- | --- |
| 1 | 常见离散时间信号的产生和图形显示 | `experiment01_discrete_signals/experiment01_discrete_signals.m` |
| 2 | 利用 DFT 分析离散时间信号的频谱 | `experiment02_dft_analysis/experiment02_dft_analysis.m` |
| 3 | 差分方程、冲激响应和卷积分析 | `experiment03_discrete_systems/experiment03_discrete_systems.m` |
| 4 | IIR 与 FIR 数字带通滤波器设计 | `experiment04_filter_design/experiment04_filter_design.m` |
| 5 | 数字滤波器分离三个单频分量 | `experiment05_filter_application/experiment05_filter_application.m` |
| 6 | 方波的傅里叶级数分解、合成与滤波 | `experiment06_square_wave/experiment06_square_wave.m` |
| 7 | 基于亮点模型的目标回波仿真 | `experiment07_highlight_echo/experiment07_highlight_echo.m` |

完整的理论分析、参数解释、算法步骤和预期结果见 [实验分析与实现思路](docs/实验分析与实现思路.md)。

## 运行环境

- MATLAB R2018b 或更高版本；
- Signal Processing Toolbox（实验 3 至实验 6 使用 `filter`、`freqz`、`butter`、`fir1`、`filtfilt` 等函数）；
- 建议使用 MATLAB R2020a 或更高版本运行全部绘图代码。

仓库不依赖外部数据或网络。代码只在各实验自己的 `results/` 目录写入 PNG 结果图。

## 运行方法

在 MATLAB 中将仓库根目录设为当前目录，然后运行任一脚本，例如：

```matlab
run('experiment01_discrete_signals/experiment01_discrete_signals.m')
run('experiment07_highlight_echo/experiment07_highlight_echo.m')
```

依次运行全部实验：

```matlab
run('experiment01_discrete_signals/experiment01_discrete_signals.m');
run('experiment02_dft_analysis/experiment02_dft_analysis.m');
run('experiment03_discrete_systems/experiment03_discrete_systems.m');
run('experiment04_filter_design/experiment04_filter_design.m');
run('experiment05_filter_application/experiment05_filter_application.m');
run('experiment06_square_wave/experiment06_square_wave.m');
run('experiment07_highlight_echo/experiment07_highlight_echo.m');
```

每个脚本开头集中放置实验参数，修改参数后可重复实验。脚本会打印关键数值，并自动创建结果目录。

## 结果解读要点

- 实验 1 展示离散频率的周期性及混叠；
- 实验 2 区分“补零使频谱曲线变密”和“增加观测长度提高实际分辨率”；
- 实验 3 同时计算理论响应与 `filter` 结果并给出最大误差；
- 实验 4 检查 IIR/FIR 带通滤波器是否满足通阻带指标，并绘制实现结构示意图；
- 实验 5 比较滤波前后的三个单频分量；
- 实验 6 演示奇次谐波合成、吉布斯现象以及逐次带通分解；
- 实验 7 比较 CW、LFM 在两个角度亮点模型下的时域和频域回波，并包含指导书中的选作弹性散射模型。

## 说明

指导书未明确给出实验 1 的默认长度和频率、实验 6 的采样率及滤波阶数。本实现选取满足采样定理且便于观察的默认值，并把它们保留为脚本顶部参数，便于按教师要求调整。


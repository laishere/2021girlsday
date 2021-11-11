# 用Verilog HDL语言写的一个小项目，虚拟LED显示屏输出广工大”女生节“祝福语

## 简介

本项目主要使用Verilog HDL语言编写，主要硬件逻辑有：

1. ROM
2. RAM
3. 虚拟显示屏
4. ROM数据载入RAM逻辑
5. RAM数据逐行移位逻辑
6. 顶层逻辑控制

其次使用了python对虚拟显示屏的数据进行渲染

*思维导图见：`LED显示屏.xmind`*

## 使用

### 环境

1. quartus + modelsim

2. python
> 安装项目python依赖 `pip install -r requirements.txt`

### 步骤

1. 使用ps等工具创建包含文字或图案的png图片，尺寸为32 x 32

2. 在项目根目录下，调用 `python img2mem.py` 生成mem.txt，此文件用作rom的数据

3. 在quartus中编译好代码，然后执行 `Tool > Run Simulation Tools > Gate Level Simulation`  
    *testbench代码见: `simulation\modelsim\LED.vt`*

5. 等待modelsim仿真完毕，确认finish

6. 在项目根目录下，调用`python video.py`渲染视频
# UART → FPGA SPI-Flash 固件升级工程

该工程包含两部分：

- `host/`：PC 端升级工具（Python），通过 UART 与 FPGA 通信
- `fpga/`：FPGA 侧“串口升级引导/写 Flash”逻辑（SystemVerilog）

## 目录

- `docs/`：协议与架构文档
- `host/`：PC 端工具与单元测试
- `fpga/rtl/`：UART/SPI-Flash/协议解析等 RTL
- `fpga/sim/`：简易仿真/自测（偏向协议层）

## 快速开始（PC 端）

1) 安装依赖

```bash
python -m venv .venv
.venv\\Scripts\\activate
pip install -r host/requirements.txt
```

2) 升级

```bash
python -m host.uart_fwu \
  --port COM5 \
  --baud 921600 \
  --fw firmware.bin \
  --base-addr 0x000000
```

列出串口：

```bash
python -m host.uart_fwu --list-ports
```

自动选择串口（仅当系统匹配到唯一串口时）：

```bash
python -m host.uart_fwu --port auto --fw firmware.bin --base-addr 0x000000
```

## FPGA 侧集成

从 [fwu_top.sv](file:///k:/TRAE/uart_spi/fpga/rtl/fwu_top.sv) 顶层接入：

- `clk`：系统时钟
- `rst_n`：低有效复位
- `uart_rx`/`uart_tx`
- `spi_*`：连接到外部 SPI Flash（`cs_n/sck/mosi/miso`）

更多信息见：

- [protocol.md](file:///k:/TRAE/uart_spi/docs/protocol.md)
- [architecture.md](file:///k:/TRAE/uart_spi/docs/architecture.md)

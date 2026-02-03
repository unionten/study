# 工程架构

## 模块划分

FPGA 侧（`fpga/rtl/`）：

- `uart_rx.sv` / `uart_tx.sv`：8N1 串口收发
- `slip_codec.sv`：SLIP 编解码（RX 解码、TX 编码）
- `fwu_packet.sv`：帧头解析、CRC32 校验、ACK 生成
- `spi_flash_ctrl.sv`：SPI Flash 基本指令（读/页写/扇区擦/读状态）
- `fwu_engine.sv`：升级状态机（START/ERASE/DATA/FINISH/QUERY）
- `fwu_top.sv`：顶层封装

PC 侧（`host/`）：

- `protocol.py`：SLIP + 帧封装/CRC
- `transport_serial.py`：串口收发与超时
- `uart_fwu.py`：升级流程（重试、进度、最终 CRC 对比）

## 关键设计点

- 可靠性：每个命令都必须 ACK；DATA 包带 `seq`，允许重发
- 可恢复：SLIP 定界 + CRC32，能从噪声/错帧中快速重新同步
- Flash 写入：按页编程（默认 256B），写前 WREN，写后轮询 WIP
- 统一校验：FPGA 写入时同时对 image 做 rolling CRC32，FINISH 后上报

# UART→FPGA SPI-Flash 固件升级操作手册

## 1. 适用范围

本手册用于指导：通过 UART 与 FPGA 通信，将 `firmware.bin` 写入外部 SPI Flash，实现固件更新。

工程包含：

- PC 端升级工具：`host/uart_fwu.py`
- FPGA 侧升级逻辑：`fpga/rtl/fwu_top.sv` 及其依赖模块

## 2. 硬件连接

### 2.1 UART

- `uart_rx`：FPGA 接收（连接到 USB-UART 的 TX）
- `uart_tx`：FPGA 发送（连接到 USB-UART 的 RX）
- 建议：使用 3.3V TTL 电平，确保共地

### 2.2 SPI Flash

- `spi_cs_n`：片选（低有效）
- `spi_sck`：时钟
- `spi_mosi`：主机输出
- `spi_miso`：主机输入

本工程默认使用 SPI 单线模式（非 QSPI）。

## 3. FPGA 侧集成与参数

### 3.1 顶层模块

顶层：[fwu_top.sv](file:///k:/TRAE/uart_spi/fpga/rtl/fwu_top.sv)

接口：

- `clk`：系统时钟
- `rst_n`：低有效复位
- `uart_rx/uart_tx`
- `spi_cs_n/spi_sck/spi_mosi/spi_miso`

### 3.2 可配置参数

- `CLK_HZ`：系统时钟频率（Hz）
- `UART_BAUD`：串口波特率，推荐 `921600`
- `SPI_CLK_DIV`：SPI SCK 分频（SCK 约为 `CLK_HZ/(2*SPI_CLK_DIV)`）

示例：50MHz 时钟、SPI_CLK_DIV=4，则 SCK≈6.25MHz。

## 4. 升级流程说明（主机↔FPGA）

升级流程（推荐顺序）：

1) `HELLO`：主机探测设备，FPGA 返回 `HELLO_RSP`（Flash ID/参数能力）
2) `START`：下发一次升级会话参数（写入基地址/镜像大小/镜像 CRC/page_size）
3) `ERASE`：按覆盖区域擦除（按 sector_size 循环扇区擦除）
4) `DATA`：分块写入（offset + 数据长度 + 数据）
5) `FINISH`：完成并校验（写入字节数 + CRC32 比较）
6) `QUERY`：任意时刻查询 `written_bytes` 与 `running_crc32`

重传机制：主机对 `DATA` 使用 `seq`，若 ACK 超时则重发同一 `seq`；FPGA 对重复 `seq+offset+len` 的 DATA 做幂等 ACK。

## 5. PC 端升级工具操作说明

### 5.1 安装依赖

```bash
python -m venv .venv
.venv\\Scripts\\activate
pip install -r host/requirements.txt
```

### 5.2 执行升级

```bash
python -m host.uart_fwu \
  --port COM5 \
  --baud 921600 \
  --fw firmware.bin \
  --base-addr 0x000000 \
  --chunk 256 \
  --timeout 0.2 \
  --retries 8
```

列出可用串口并退出：

```bash
python -m host.uart_fwu --list-ports
```

自动选择串口（仅当匹配到唯一串口时）：

```bash
python -m host.uart_fwu --port auto --fw firmware.bin --base-addr 0x000000
```

参数说明：

- `--port`：串口号（Windows 如 `COM5`）
- `--port-like`：按描述/硬件ID模糊匹配（例如 `CH340` 或 `VID:PID=1A86:7523`）
- `--list-ports`：列出可用串口并退出
- `--baud`：波特率
- `--fw`：固件 `.bin` 文件路径，或包含 `.bin` 的目录（自动选择最新文件）
- `--fw-name`：当 `--fw` 为目录时，按文件名选择目标 `.bin`
- `--bin`：兼容参数：固件 `.bin` 文件路径
- `--base-addr`：Flash 写入基地址（与 FPGA 侧一致）
- `--chunk`：DATA 分块大小（建议 256）
- `--timeout`：等待 ACK/响应超时（秒）
- `--retries`：超时重试次数

## 6. 协议与字段说明（“寄存器说明”）

### 6.1 帧格式

UART 采用 SLIP 定界与转义；解码后的帧：

```
| magic[2] | ver[1] | type[1] | seq[2] | len[2] | payload[len] | crc32[4] |
```

- `magic`：0x55 0xAA
- `ver`：0x01
- `type`：消息类型
- `seq`：16 位序号
- `len`：payload 长度
- `crc32`：对 `magic..payload` 计算 CRC32(IEEE)

详细类型/载荷见 [protocol.md](file:///k:/TRAE/uart_spi/docs/protocol.md)。

### 6.2 SPI Flash 状态寄存器（SR1）

FPGA 在擦除/写页后通过 `RDSR(0x05)` 轮询 SR1：

- Bit0 `WIP`：Write In Progress，1=忙，0=空闲
- Bit1 `WEL`：Write Enable Latch，1=已写使能

不同 Flash 厂商可能扩展更多位，本工程最小依赖 `WIP/WEL`。

### 6.3 Flash 命令使用

- `RDID(0x9F)`：读取 3 字节 ID
- `WREN(0x06)`：写使能
- `SE(0x20)`：4KB 扇区擦除（如 Flash 为 64KB 扇区擦除请替换为 `0xD8` 并同步 sector_size）
- `PP(0x02)`：页编程
- `RDSR(0x05)`：读状态寄存器

## 7. Flash 分区建议

建议在 Flash 预留升级区：

- `base_addr`：固件镜像起始地址
- 可选：预留头部存放版本/长度/CRC（本工程当前用 UART 的 START/FINISH 校验，不强制写头）

## 8. 常见问题

- ACK 超时：检查 UART 线序、波特率、地线；降低波特率或增大 `--timeout`
- Flash 写入失败：确认 `SE/PP` 命令与 Flash 型号匹配；确认 `sector_size` 与命令一致

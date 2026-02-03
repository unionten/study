# UART 固件升级协议（帧 + 命令）

## 目标

- UART 字节流上可靠传输（丢字节/插入噪声可恢复）
- 支持分包写入 SPI Flash，带 CRC 校验与重传
- FPGA 侧实现简单、状态明确

## 链路帧格式

采用 `SLIP` 风格的定界与转义：

- 帧定界字节：`0xC0`
- 转义字节：`0xDB`
- 转义规则：
  - `0xC0` → `0xDB 0xDC`
  - `0xDB` → `0xDB 0xDD`

解码后（即“有效负载”）格式如下：

```
| magic[2] | ver[1] | type[1] | seq[2] | len[2] | payload[len] | crc32[4] |
```

- `magic`：固定 `0x55 0xAA`
- `ver`：协议版本，当前 `0x01`
- `type`：消息类型
- `seq`：16 位序号（主机递增），用于 ACK/重传
- `len`：payload 长度（0..1024）
- `crc32`：对 `magic..payload`（不含 crc32 字段）计算的 IEEE CRC32（多项式 `0x04C11DB7`，输入按字节流）

## 消息类型

主机 → FPGA：

- `0x01 HELLO`：探测/同步
  - payload：空
- `0x02 START`：开始一次升级
  - payload：`base_addr[4] image_size[4] image_crc32[4] page_size[2]`
- `0x03 ERASE`：擦除覆盖区域
  - payload：`base_addr[4] size[4] sector_size[4]`
- `0x04 DATA`：写入数据块
  - payload：`offset[4] data_len[2] data[data_len]`
  - `offset` 相对 `base_addr`
- `0x05 FINISH`：完成写入并请求最终校验
  - payload：空
- `0x06 QUERY`：查询当前写入进度
  - payload：空

FPGA → 主机：

- `0x81 HELLO_RSP`：返回 Flash 参数/能力
  - payload：`flash_id[3] page_size[2] sector_size[4] max_payload[2]`
- `0x82 ACK`：对命令确认
  - payload：`ack_type[1] status[1] detail[2]`
  - `ack_type`：被确认的 type
  - `status`：`0=OK` `1=BUSY` `2=BAD_CRC` `3=BAD_STATE` `4=FLASH_ERR`
- `0x83 PROGRESS`：返回进度
  - payload：`written_bytes[4] running_crc32[4]`
- `0x84 ERROR`：错误报告
  - payload：`code[2] info[2]`

## 时序建议

1) 主机发 `HELLO`，等待 `HELLO_RSP`
2) 主机发 `START`，等待 `ACK(START)`
3) 主机发 `ERASE`，等待 `ACK(ERASE)`
4) 主机循环发 `DATA`（带 `seq`），等待 `ACK(DATA)`；超时则重发同 `seq`
5) 主机发 `FINISH`，等待 `ACK(FINISH)`，再拉取 `PROGRESS`（对比最终 CRC）


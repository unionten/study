
`timescale 1ns/1ps

module tb_slip_tx_example;

  // 1. 定义时钟和复位
  reg clk;
  reg rst_n;

  // 生成 50MHz 时钟 (周期 20ns)
  initial clk = 0;
  always #10 clk = ~clk;

  // 2. 实例化 UART 发送模块
  // 参数：时钟 50MHz, 波特率 921600 (为了仿真快一点，也可以设得更快)
  // 注意：在实际仿真波形中，如果波特率太低，发送一个字节需要很长时间
  // 这里为了仿真演示，我们把 BAUD 设得很高，或者让 DIV 变小
  // 但为了保持真实性，还是用标准值，只是仿真时间跑长一点
  
  wire tx_line;
  reg [7:0] tx_data;
  reg       tx_valid;
  wire      tx_ready;

  uart_tx #(
    .CLK_HZ(50000000),
    .BAUD(921600)    // 约 1.085 us 一个 bit
  ) u_uart_tx (
    .clk(clk),
    .rst_n(rst_n),
    .tx(tx_line),
    .data(tx_data),
    .valid(tx_valid),
    .ready(tx_ready)
  );

  // 3. 定义发送任务
  task send_byte;
    input [7:0] byte_in;
    begin
      // 等待 UART 模块准备好
      wait(tx_ready);
      @(posedge clk);
      
      // 放置数据并拉高 valid
      tx_data  <= byte_in;
      tx_valid <= 1'b1;
      
      // 等待一个时钟周期让模块采样
      @(posedge clk);
      tx_valid <= 1'b0;
      
      // 等待模块进入非空闲状态 (开始发送)
      wait(!tx_ready);
      
      // 再次等待模块变回空闲 (发送完成)
      wait(tx_ready);
      
      // 稍微加一点延时，让波形好看一点
      repeat(100) @(posedge clk);
    end
  endtask

  // 4. 主测试过程
  initial begin
    // 初始化信号
    rst_n = 0;
    tx_valid = 0;
    tx_data = 0;

    // 复位 100ns
    #100;
    rst_n = 1;
    #100;

    $display("Starting SLIP Sequence Transmission...");

    // 发送序列: C0 01 02 DB DC 03 DB DD 04 C0
    
    // 1. Frame Start
    send_byte(8'hC0); 
    
    // 2. Payload: 01
    send_byte(8'h01);
    
    // 3. Payload: 02
    send_byte(8'h02);
    
    // 4. Payload: C0 -> Escaped as DB DC
    send_byte(8'hDB);
    send_byte(8'hDC);
    
    // 5. Payload: 03
    send_byte(8'h03);
    
    // 6. Payload: DB -> Escaped as DB DD
    send_byte(8'hDB);
    send_byte(8'hDD);
    
    // 7. Payload: 04
    send_byte(8'h04);
    
    // 8. Frame End
    send_byte(8'hC0);

    $display("Transmission Complete!");
    
    // 等待足够时间让波形显示完整
    #1000;
    $finish;
  end

  // 可选：打印输出波形变化，或者导出 VCD
  initial begin
    $dumpfile("slip_wave.vcd");
    $dumpvars(0, tb_slip_tx_example);
  end

endmodule

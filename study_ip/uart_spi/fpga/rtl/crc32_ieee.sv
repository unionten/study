module crc32_ieee(
  input  logic        clk,
  input  logic        rst_n,
  input  logic        init,
  input  logic        en,
  input  logic [7:0]  data,
  output logic [31:0] crc
);
  function automatic logic [31:0] next_crc32(input logic [31:0] c, input logic [7:0] d);
    logic [31:0] x;
    int i;
    begin
      x = c ^ {24'd0, d};
      for (i = 0; i < 8; i++) begin
        if (x[0]) x = (x >> 1) ^ 32'hEDB88320;
        else      x = (x >> 1);
      end
      next_crc32 = x;
    end
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      crc <= 32'hFFFFFFFF;
    end else begin
      if (init) crc <= 32'hFFFFFFFF;
      else if (en) crc <= next_crc32(crc, data);
    end
  end
endmodule


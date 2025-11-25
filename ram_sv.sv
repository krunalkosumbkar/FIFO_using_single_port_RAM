

module ram_sv#(
  parameter int DEPTH       = 32,
  parameter int DATA_WIDTH  = 8,
  parameter int ADDR_WIDTH  = $clog2(DEPTH)
)(
  input  logic                  clk,
  input  logic                  we,
  input  logic                  en,
  input  logic [ADDR_WIDTH-1:0] addr,
  input  logic [DATA_WIDTH-1:0] di,
  output logic [DATA_WIDTH-1:0] dout
);

  // RAM array
  logic [DATA_WIDTH-1:0] RAM [0:DEPTH-1];

  // Synchronous read/write
  always_ff @(posedge clk) begin
    if (en) begin
      if (we) begin
        RAM[addr] <= di;        // Write
      end else begin
        dout <= RAM[addr];      // Read
      end
    end
  end

endmodule

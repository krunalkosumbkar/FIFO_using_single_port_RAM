// top module of fifo
module top_fifo_sv #(
  parameter int FFDEPTH       = 1024,
  parameter int FFDATA_WIDTH  = 32,
  parameter int FFPTR_WIDTH   = $clog2(FFDEPTH)
)(
  input  logic                  t_clk,
  input  logic                  rst_n,
  input  logic                  r_en,
  input  logic                  w_en,
  input  logic [FFDATA_WIDTH-1:0] data_in,
  output logic [FFDATA_WIDTH-1:0] data_out,
  output logic                  full,
  output logic                  empty
);

  // Internal signals

  logic internal_clk_100;
  logic twice_frequency;
  logic [FFPTR_WIDTH-1:0] addr_wire;
  logic enable;
  logic wr_en, rd_en;
  logic [FFDATA_WIDTH-1:0] data_write;
  logic write_enable;
  logic reset;
  logic toggle;
  logic full_wire,empty_wire;
  logic rd_in;

  // ============================================================
  // Write/read capture at 100 MHz
  // ============================================================
  always_ff @(posedge internal_clk_100) begin 
    if (!rst_n)
    reset <= 1'b0;
    else 
    reset <= 1'b1;end
   
  always_ff @(posedge twice_frequency) begin 
    if(!rst_n)toggle <= 1'b0;
    else begin
    if(reset) toggle <= ~toggle;
    else      toggle <= 1'b0;end
    end
    
  always_ff @(posedge twice_frequency) begin 
    if (!rst_n) begin
      wr_en      <= 1'b0;
      rd_in      <= 1'b0;
      data_write <= 'h0;
    end else begin
      if(toggle)begin
      wr_en      <= w_en;
      rd_in      <= r_en;
      data_write <= data_in;end 
      end   
    end

  
 always_ff @(posedge twice_frequency) begin 
    if (!rst_n) 
      rd_en      <= 1'b0;
    else 
      rd_en      <= rd_in;
   end 

 always_ff @(posedge twice_frequency) begin 
    if (!rst_n)begin
          full   <= 1'b0;
    end   
    else if(toggle)begin
         if(rd_en)begin
          full   <= 1'b0;end
         else begin
          full   <= full_wire;end
    end   
    else  full   <= full ;  
    end
    
 always_ff @(posedge twice_frequency) begin 
    if (!rst_n)begin
          empty  <= 1'b0;
    end   
    else if(toggle)begin
         if(wr_en)begin
          empty  <= 1'b0;end
         else begin
          empty  <= empty_wire;end
    end   
    else  empty  <= empty;
    end   


  // ============================================================
  // FSM for FIFO control
  // ============================================================
 // fsm_sv #(
   fsm_next #(
    .PTR_WIDTH(FFPTR_WIDTH)
  ) fft1 (
    .clk      (twice_frequency),
    .rst_n    (rst_n),
    .w_bit    (wr_en),
    .r_bit    (rd_en),
    .en       (enable),
    .write_en (write_enable),
    .addr     (addr_wire),
    .full     (full_wire),
    .empty    (empty_wire)
    
  );

  // ============================================================
  // Single-port RAM
  // ============================================================
  ram_sv #(
    .DEPTH      (FFDEPTH),
    .DATA_WIDTH (FFDATA_WIDTH),
    .ADDR_WIDTH (FFPTR_WIDTH)
  ) fft2 (
    .clk  (twice_frequency),
    .we   (write_enable),
    .en   (enable),
    .addr (addr_wire),
    .di   (data_write),
    .dout (data_out)
 
  ); 

  // ============================================================
  // Clock Wizard (MMCM)
  // ============================================================
  clk_wizard_mmcm fft (
    // Clock out ports
    .clk_100 (internal_clk_100), // output
    .clk_200 (twice_frequency),  // output
    // Status/control
    .resetn  (rst_n),
    // Clock input
    .clk_in1 (t_clk)
  );

endmodule

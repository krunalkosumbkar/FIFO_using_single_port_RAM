

module fsm_next#(  parameter int PTR_WIDTH = 9
)(
  input  logic                  clk,
  input  logic                  rst_n,
  input  logic                  r_bit,
  input  logic                  w_bit,
  output logic                  full,//_out,
  output logic                  empty,//_out,
  output logic                  write_en,
  output logic                  en,
  output logic [PTR_WIDTH-1:0]  addr
);
  typedef enum logic [2:0] {
    IDLE  = 3'b001,
    WRITE = 3'b010,
    READ  = 3'b100
  } state_t;
(* fsm_encoding="user", fsm_safe_state = "default_state" *)
//https://docs.amd.com/r/en-US/ug912-vivado-properties/FSM_SAFE_STATE
  state_t state, next_state;
  // ============================================================
  // FIFO pointers (binary + Gray)
  // ============================================================
 
  logic [PTR_WIDTH:0] w_ptr, r_ptr;
  logic [PTR_WIDTH:0] w_ptr_gray, r_ptr_gray;
  logic [PTR_WIDTH:0] next_w_ptr, next_r_ptr;
  assign next_w_ptr = w_ptr + 1'b1;
  assign next_r_ptr = r_ptr + 1'b1;
    

  // ============================================================
  // State register
  // ============================================================
always_ff @(negedge clk) begin
  if (!rst_n) begin
    state <= IDLE; 
  end else begin
    state <= next_state;
  end
end

  // ============================================================
  // Next state logic
  // ============================================================
  always_comb begin
    next_state = state;
    unique case (state)
      IDLE  : next_state = (w_bit && !full)?   WRITE  : (r_bit && !empty) ? READ : IDLE;
      WRITE : next_state = (r_bit && !empty)?  READ   : IDLE;
      READ  : next_state = (w_bit && !full)?   WRITE  : IDLE;
      default: next_state = IDLE;
    endcase
  end

  // ============================================================
  // Output and pointer logic
  // ============================================================
  
assign en = (state[1]) | (state[2]);  
assign write_en  = (state[1]) ;

 always_ff@(negedge clk) begin 
    if (!rst_n) begin
      w_ptr      <= 'h0;
      r_ptr      <= 'h0;
      addr       <= 'h0;
      w_ptr_gray <= 'h0;
      r_ptr_gray <= 'h0;end 
    else begin
    unique case(1'b1)
             
      next_state[1]: begin
         addr       <=  w_ptr;
         w_ptr      <= next_w_ptr;
         w_ptr_gray <= (next_w_ptr >> 1) ^ next_w_ptr;      
         end      
      next_state[2]: begin     
         addr       <=  r_ptr;
         r_ptr      <= next_r_ptr;
         r_ptr_gray <= (next_r_ptr >> 1) ^ next_r_ptr;             
         end 
      default:begin
         addr       <= 'h0;
         w_ptr      <= w_ptr;
         r_ptr      <= r_ptr;
         w_ptr_gray <= w_ptr_gray;
         r_ptr_gray <= r_ptr_gray; end                   
     endcase
     end   
 end

  // ============================================================
  // FIFO status flags
  // ============================================================
  assign full  = (w_ptr_gray ==
                 {~r_ptr_gray[PTR_WIDTH:PTR_WIDTH-1],
                   r_ptr_gray[PTR_WIDTH-2:0]});

  assign empty = (r_ptr_gray == w_ptr_gray);
  

endmodule

`timescale 1ns / 1ps

module apb_slave(
  input clk,
  input RESETn,
  input PSELx,
  input PENABLE,
  input PWRITE,
  input [31:0] PADDR,
  input [31:0] PWDATA,
  output reg [31:0] PRDATA,
  output reg PREADY
);

  reg [31:0] mem [63:0]; // 64-word memory
  reg [1:0] present_state, next_state;

  parameter IDLE   = 2'b00,
            SETUP  = 2'b01,
            ACCESS = 2'b10;

  // State Transition: Move between IDLE, SETUP, ACCESS
  always @(posedge clk or negedge RESETn) begin
    if (!RESETn)
      present_state <= IDLE;
    else
      present_state <= next_state;
  end

  // Next State Logic
  always @(*) begin
    case (present_state)
      IDLE: 
        if (PSELx == 1'b1 && PENABLE == 1'b0)
          next_state = SETUP;
        else
          next_state = IDLE;

      SETUP: 
        if (PSELx == 1'b1 && PENABLE == 1'b1)begin
          next_state = ACCESS;
          PREADY<=1'b1;
          end
        else
          next_state = SETUP;

      ACCESS: 
        if (PSELx == 1'b1 && PENABLE == 1'b0)
          next_state = SETUP;
        else
          next_state = IDLE;

      default: 
        next_state = IDLE;
    endcase
  end

  // Output and Datapath Logic
  always @(posedge clk or negedge RESETn) begin
    if (!RESETn) begin
      PREADY <= 1'b0;
      PRDATA <= 32'd0;
    end
    else begin
      case (present_state)
        IDLE: begin
          PREADY <= 1'b0;
        end

        SETUP: begin
          PREADY <= 1'b0;
        end

        ACCESS: begin
          PREADY <= 1'b1; // In ACCESS state, slave ready to perform operation
          if (PWRITE ) 
            mem[PADDR] <= PWDATA; // Write operation
          else 
            PRDATA <= mem[PADDR]; // Read operation
        end

        default: begin
          PREADY <= 1'b0;
        end
      endcase
    end
  end

endmodule

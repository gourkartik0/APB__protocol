`timescale 1ns / 1ps

module apb_slave_tb;

  reg clk;
  reg RESETn;
  reg PSELx;
  reg PENABLE;
  reg PWRITE;
  reg [31:0] PADDR;
  reg [31:0] PWDATA;
  wire [31:0] PRDATA;
  wire PREADY;

  // Instantiate the DUT
  apb_slave uut (
    .clk(clk),
    .RESETn(RESETn),
    .PSELx(PSELx),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz Clock
  end

  // Reset
  initial begin
    RESETn = 0;
    #15;
    RESETn = 1;
  end

  // Task to perform APB Write
  task apb_write(input [31:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      PSELx = 1'b1;
      PENABLE = 1'b0;
      PWRITE = 1'b1;
      PADDR = addr;

      @(posedge clk);
      PENABLE = 1'b1;
       wait(PREADY) 
      PWDATA = data;
      @(posedge clk);
      while (!PREADY) @(posedge clk); // Wait till slave is ready

      @(posedge clk);
      PSELx = 1'b0;
      PENABLE = 1'b0;
    end
  endtask

  // Task to perform APB Read
  task apb_read(input [31:0] addr);
    begin
      @(posedge clk);
      PSELx = 1'b1;
      PENABLE = 1'b0;
      PWRITE = 1'b0;
      PADDR = addr;

      @(posedge clk);
      PENABLE = 1'b1;

      @(posedge clk);
      while (!PREADY) @(posedge clk); // Wait till slave is ready

      @(posedge clk);
      $display("Read Address: %h, Data: %h", addr, PRDATA);

      PSELx = 1'b0;
      PENABLE = 1'b0;
    end
  endtask

  // Stimulus
  initial begin
    // Initialize
    PSELx = 0;
    PENABLE = 0;
    PWRITE = 0;
    PADDR = 0;
    PWDATA = 0;

    wait(RESETn == 1);

    #10;

    // Write some data
    apb_write(32'h04, 32'hDEADBEEF);
    apb_write(32'h08, 32'hFACEB00C);

    // Read back data
    apb_read(32'h04);
    apb_read(32'h08);

    // Write new data
    apb_write(32'h10, 32'h12345678);

    // Read back new data
    apb_read(32'h10);

    #50;
    $finish;
  end

endmodule

interface apb_intf(input logic clk,RESETn);
  
  logic [31:0] PADDR;
  logic  [31:0] PWDATA;
  logic  PWRITE;
  logic PSELx;
  logic  PENABLE;
  
  // output signals for APB slave
  logic  PREADY;
  logic  [31:0] PRDATA;
  
  //driver clocking block
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    output PADDR;
    output PWDATA;
    output PWRITE;
    output PSELx;
    output  PENABLE; 
    input  PRDATA;
    input  PREADY;
  endclocking
  
  //monitor clocking block
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input PADDR;
    input PWDATA;
    input PWRITE;
    input PSELx;
    input  PENABLE; 
    input  PRDATA;
    input  PREADY;
  endclocking
  
  //driver modport
  modport DRIVER  (clocking driver_cb,input clk,RESETn);
  
  //monitor modport  
  modport MONITOR (clocking monitor_cb,input clk,RESETn);
  
endinterface        

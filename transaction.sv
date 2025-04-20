class transaction;
  rand bit [31:0] PADDR;
  rand bit[31:0] PWDATA;
  rand bit  PWRITE;
  rand bit  PSELx;
  rand bit  PENABLE;

 bit[31:0] PRDATA;
bit PREADY;
  constraint c1 {PADDR inside{[10:20]};}
  constraint c2 {PWDATA inside{[50:100]};}
  
  function void display(string class_name);
    $write("------------------ [%s]  ------",class_name);
    $display(" PWRITE=%b PADDR= %0d PWDATA= %0d PRADTA=%0d  ",PWRITE,PADDR,PWDATA,PRDATA);
   
  endfunction
endclass

module Compare_Logic(
  clock,
  reset,
  write_Pointer,
  read_Pointer,
  write_Enable,
  read_Enable,
  sig_Full,
  sig_Empty,
  counter,
  );

  parameter BUFFER_WIDTH = 3;
  parameter BUFFER_SIZE = 8;

  input clock;
  input reset;
  input [BUFFER_WIDTH-1:0] write_Pointer;
  inout [BUFFER_WIDTH-1:0] read_Pointer;
  input write_Enable;
  input read_Enable;
  output reg sig_Full;
  output reg sig_Empty;
  output reg [BUFFER_WIDTH-1:0] counter;         
  
  always @(counter) begin
    sig_Empty = (counter==0);
    sig_Full = (counter== BUFFER_SIZE);
  end

  always @(posedge clock or negedge reset) begin
    if( !reset )
      counter <= 0;
    else if(!sig_Full && write_Enable )
      counter <= counter + 1;
    else if(!sig_Empty && read_Enable )
      counter <= counter - 1;
    else
      counter <= counter;
  end

endmodule  
module Memory_Array(
  clock,
  write_Enable,
  write_Pointer,
  sig_Full,
  read_Pointer,
  buffer_Input,
  buffer_Output
  );

  parameter BUFFER_WIDTH = 3;
  parameter DATA_WIDTH = 8;
  parameter BUFFER_SIZE = 8;

  input clock;
  input sig_Full;
  input write_Enable;
  input [BUFFER_WIDTH-1:0] write_Pointer;
  input [BUFFER_WIDTH-1:0] read_Pointer;
  input [DATA_WIDTH-1:0] buffer_Input;
  output [DATA_WIDTH-1:0] buffer_Output;
  reg  [DATA_WIDTH-1:0] buffer [BUFFER_SIZE-1: 0];
  
  reg [DATA_WIDTH-1:0] buffer_Output;
  always @(posedge clock) begin
    buffer_Output = buffer [read_Pointer];
    if( write_Enable  & !sig_Full)
      buffer[write_Pointer ] <= buffer_Input;
  end
  
endmodule 
module Read_Interface(
  clock,
  reset,
  read_Enable,
  sig_Empty,
  read_Pointer
  );

  parameter BUFFER_WIDTH = 3;
  input clock;
  input reset;
  input read_Enable;
  input sig_Empty;
  output [BUFFER_WIDTH-1:0] read_Pointer;
  
  reg[BUFFER_WIDTH-1:0] read_Pointer; 
  wire fifo_Read_Enable;

  assign fifo_Read_Enable = (~sig_Empty)& read_Enable;  
  always @(posedge clock or negedge reset) begin  
    if(~reset)
      read_Pointer <= 0;  
    else if(fifo_Read_Enable)  
      read_Pointer <= read_Pointer + 1;  
  end 

endmodule  
module Write_Interface(
    clock,
    reset,
    write_Enable,
    sig_Full,
    write_Pointer
    );

    parameter BUFFER_WIDTH = 3;
    input clock;
    input reset;
    input write_Enable;
    input sig_Full;
    output [BUFFER_WIDTH-1:0] write_Pointer;
    
    reg [BUFFER_WIDTH-1:0] write_Pointer;  
    wire fifo_Write_Enable;

    assign fifo_Write_Enable = (~sig_Full) & write_Enable;  
    always @(posedge clock or negedge reset) begin  
        if(~reset)
            write_Pointer <= 0;  
        else if(fifo_Write_Enable)  
            write_Pointer <= write_Pointer + 1;     
    end 

endmodule  
module iiitb_fifo(
  clock,
  reset,
  write_Enable,
  read_Enable,
  buffer_Input,
  buffer_Output,
  sig_Full,
  sig_Empty
  ); 

  parameter BUFFER_WIDTH = 3;
  parameter DATA_WIDTH = 8;
  parameter BUFFER_SIZE = 8;

  input clock;
  input reset;
  input write_Enable;
  input read_Enable;
  input [DATA_WIDTH-1:0] buffer_Input;
  output [DATA_WIDTH-1:0] buffer_Output;
  output sig_Full;
  output sig_Empty;
  
  
  wire sig_Full;
  wire sig_Empty;
  wire [BUFFER_WIDTH-1:0] read_Pointer;
  wire [BUFFER_WIDTH-1:0] write_Pointer;
  wire [DATA_WIDTH-1:0] buffer_Output;
  wire [BUFFER_WIDTH-1:0] counter;         

  Write_Interface #(.BUFFER_WIDTH(3))write_interface(
    .clock(clock),
    .reset(reset),
    .write_Enable(write_Enable),
    .sig_Full(sig_Full),
    .write_Pointer(write_Pointer)
    );


  Memory_Array #(.BUFFER_WIDTH(3),
                 .DATA_WIDTH(8),
                 .BUFFER_SIZE(8))
    memory_array(
      .clock(clock),
      .write_Enable(write_Enable),
      .write_Pointer(write_Pointer),
      .sig_Full(sig_Full),
      .read_Pointer(read_Pointer),
      .buffer_Input(buffer_Input),
      .buffer_Output(buffer_Output)
    );


  Read_Interface #(.BUFFER_WIDTH(3))read_interface(
    .clock(clock),
    .reset(reset),
    .read_Enable(read_Enable),
    .sig_Empty(sig_Empty),
    .read_Pointer(read_Pointer)
    ); 


  Compare_Logic #(.BUFFER_WIDTH(3),
                 .BUFFER_SIZE(8))
    compare_logic(
      .clock(clock),
      .reset(reset),
      .write_Pointer(write_Pointer),
      .read_Pointer(read_Pointer),
      .write_Enable(write_Enable),
      .read_Enable(read_Enable),
      .sig_Full(sig_Full),
      .sig_Empty(sig_Empty),
      .counter(counter)
    );

endmodule  

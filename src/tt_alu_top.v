/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_alu_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [3:0] a;
  wire [3:0] b;
  wire [9:0] result;
  wire [1:0] c;
  wire [1:0] opcode;
  wire [1:0] inmode;
  wire [5:0] uio_out_unused;
  wire [1:0] uio_in_unused;
  
  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out = {result[7:0]} ;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out ={result[9:8],uio_out_unused}; 
  assign {a,b}   = ui_in;
  assign {uio_in_unused,c,opcode,inmode} = uio_in;
  assign uio_oe  = 'b11000000;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};
  assign uio_out_unused = 0;

  tt_alu u_tt_alu (
    .a(a),
    .b(b),
    .result(result),
    .c(c),
    .opcode(opcode),
    .inmode(inmode),
    .clk(clk),
    .rst_n(rst_n)
  );

endmodule

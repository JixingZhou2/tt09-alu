/*
 * Copyright (c) 2024 Jxing zhou
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_alu (
    input  wire [3:0] a,    // Dedicated inputs
    input  wire [3:0] b,    // Dedicated inputs
    output wire [9:0] result,   // Dedicated outputs
    input  wire [1:0] c,   // IOs: Input path
    input  wire [1:0] opcode,  // IOs: Output path
    input  wire [1:0] inmode,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
/*
Data Signals:
Inputs: 4-bit parameters A and B, and a 2-bit parameter C.
Output: A 10-bit computation result.
Control Signals:
INMODE[0]: Controls whether to use the lower 4 bits of the previous result as the new parameter A, enabling accumulation or iterative multiplication operations.
INMODE[1]: Selects between B+C mode or B:C mode. In B:Cmode, the ALU can functions as a 4-bit by 6-bit multiplier, or a 4-bit by 6 bit adder.
OPMODE[1:0]: Selects the operation mode among multiplication (00), addition (01), subtraction (10), and XOR (11).
*/
logic [3:0] a_r1 ;
logic [3:0] a_r2 ;
logic [3:0] b_r1 ;
logic [5:0] result_tmp1 ; //result out from bc
logic [9:0] result_tmp2 ; //result out from caculation
logic [9:0] result_tmp3 ;
logic [1:0] c_r1 ;
logic [1:0] opcode_r1 ;
logic [1:0] opcode_r2 ;
logic [1:0] inmode_r1 ;
logic [1:0] inmode_r2 ;

//
always_ff @ (posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        opcode_r1 <= 2'b0 ;
        opcode_r2 <= 2'b0 ;
    end
    else
    begin
        opcode_r1 <= opcode ;
        opcode_r2 <= opcode_r1 ;
    end
end

always_ff @ (posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        inmode_r1 <= 2'b0 ;
        inmode_r2 <= 2'b0 ;
    end
    else
    begin
        inmode_r1 <= inmode ;
        inmode_r2 <= inmode_r1 ;
    end
end

// 
always_ff @ (posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        a_r1 <= 4'b0 ;
    end
    else
    begin
        a_r1 <= a ;
    end
end

always_ff @(posedge clk or negedge rst_n) 
begin
    if (~rst_n)
    begin
        a_r2 <= 4'b0 ;
    end
    else
    begin
        if (inmode_r1[0] == 1'b1)
        begin
            a_r2 <= result_tmp2[3:0] ;
        end
        else
        begin
            a_r2 <= a_r1 ;
        end
    end
end

//
always_ff @ (posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        b_r1 <= 4'b0 ;
    end
    else
    begin
        b_r1 <= b ;
    end
end

always_ff @ (posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        c_r1 <= 2'b0 ;
    end
    else
    begin
        c_r1 <= c ;
    end
end

always_ff @(posedge clk or negedge rst_n) 
begin
    if (~rst_n)
    begin
        result_tmp1 <= 10'b0 ;
    end
    else
    begin
        if (inmode_r1[1] == 0)
        begin
            result_tmp1 <= b_r1 + c_r1 ;
        end
        else if (inmode_r1[1] == 1)
        begin
            result_tmp1 <= {c_r1,b_r1} ;
        end
    end
end

//
always_comb
begin
    if (~rst_n)
    begin
        result_tmp2 = 10'b0 ;
    end
    else
    begin
        case (opcode_r2)
            2'b00: result_tmp2 = a_r2 * result_tmp1 ;
            2'b01: result_tmp2 = a_r2 + result_tmp1 ;
            2'b10: result_tmp2 = result_tmp1 - a_r2 ;
            2'b11: result_tmp2 = a_r2 ^ result_tmp1 ;
            default: result_tmp2 = 10'b0 ;
        endcase
    end
end

//
always_ff @ (posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        result_tmp3 <= 10'b0 ;
    end
    else
    begin
        result_tmp3 <= result_tmp2 ;
    end
end

assign result = result_tmp3 ;




endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/15/2021 06:40:11 PM
// Design Name: 
// Module Name: top_demo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_demo
(
  // input
  input  logic [7:0] sw,
  input  logic [3:0] btn,
  input  logic       sysclk_125mhz,
  input  logic       rst,
  // output  
  output logic [7:0] led,
  output logic sseg_ca,
  output logic sseg_cb,
  output logic sseg_cc,
  output logic sseg_cd,
  output logic sseg_ce,
  output logic sseg_cf,
  output logic sseg_cg,
  output logic sseg_dp,
  output logic [3:0] sseg_an
);

  logic [16:0] CURRENT_COUNT;
  logic [16:0] NEXT_COUNT;
  logic        smol_clk;
  logic [63:0] key1;
  logic [63:0] plaintext1, ciphertext1;
  assign key1 = 64'h0123456789ABCDEF;
  assign plaintext1 = 64'hAAAABBBBCCCCDDDD;
  // Place TicTacToe instantiation here
  DES dut(key1,plaintext1,sw[7],ciphertext1);
  logic[1:0] keyinp;
  assign keyinp = {sw[1],sw[0]};
  logic[15:0] output1;
  logic[63:0] inptext;
  always @(inptext,ciphertext1,sw[3:2],plaintext1,key1) begin
  case(sw[3:2])
    2'b00: inptext = plaintext1;
    2'b01: inptext = key1;
    2'b10: inptext = ciphertext1;
    2'b11: inptext = ciphertext1;
  endcase
  end
  always @(output1,inptext,sw[1:0]) begin
  case(sw[1:0])
    2'b00: output1 = inptext[63:48];
    2'b01: output1 = inptext[47:32];
    2'b10: output1 = inptext[31:16];
    2'b11: output1 = inptext[15:0];
  endcase
  end
  // 7-segment display
  segment_driver driver(
  .clk(smol_clk),
  .rst(btn[3]),
  .digit3(output1[15:12]),
  .digit2(output1[11:8]),
  .digit1(output1[7:4]),
  .digit0(output1[3:0]),
  .decimals({1'b0, btn[2:0]}),
  .segment_cathodes({sseg_dp, sseg_cg, sseg_cf, sseg_ce, sseg_cd, sseg_cc, sseg_cb, sseg_ca}),
  .digit_anodes(sseg_an)
  );

// Register logic storing clock counts
  always@(posedge sysclk_125mhz)
  begin
    if(btn[3])
      CURRENT_COUNT = 17'h00000;
    else
      CURRENT_COUNT = NEXT_COUNT;
  end
  
  // Increment logic
  assign NEXT_COUNT = CURRENT_COUNT == 17'd100000 ? 17'h00000 : CURRENT_COUNT + 1;

  // Creation of smaller clock signal from counters
  assign smol_clk = CURRENT_COUNT == 17'd100000 ? 1'b1 : 1'b0;

endmodule

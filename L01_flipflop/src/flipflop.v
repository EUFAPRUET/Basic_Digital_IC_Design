`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Thai-Nichi Institute of Technology
// Engineer: Ph.Pruet
// 
// Create Date: 06/02/2026 10:01:00 AM
// Design Name: flipflop
// Module Name: flipflop
// Project Name: flipflop
// Target Devices: xc7z010clg400-2
// Tool Versions: Vivado 2024.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module flipflop(
    input               Clk     ,
    input               Rst     ,

    input       [4-1:0] iData   ,

    output      [4-1:0] oQ      ,
    output      [4-1:0] oQn  
);

    reg     [4-1:0] rQ;

    always @(posedge Clk) begin
        if (!Rst) begin
            rQ  <= 4'b0000;
        end else begin
            rQ  <= iData;
        end       
    end

    assign oQ   = rQ;
    assign oQn  = ~rQ;


endmodule

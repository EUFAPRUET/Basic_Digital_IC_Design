`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Thai-Nichi Institute of Technology
// Engineer: Ph.Pruet
// 
// Create Date: 06/02/2026 02:19:54 PM
// Design Name: counter
// Module Name: counter
// Project Name: 4BitCnt
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


module counter(
    input               Clk     ,
    input               Rst     ,

    input               iCntEn  ,
    output  [4-1:0]     oCnt
);
    reg [4-1:0] rCnt;

    always @(posedge Clk) begin
        if (!Rst) begin
            rCnt    <= 4'b0000;
        end else begin
            if (iCntEn) begin
                rCnt    <= rCnt + 1;
            end else begin
                rCnt    <= rCnt;
            end
        end
    end

    assign oCnt = rCnt;

endmodule

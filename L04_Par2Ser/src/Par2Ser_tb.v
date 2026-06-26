`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Thai-Nichi Institute of Technology
// Engineer: Ph.Pruet
// 
// Create Date: 06/26/2026 12:48:18 PM
// Design Name: Parallel to Serial
// Module Name: Par2Ser_tb
// Project Name: Par2Ser
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


module Par2Ser_tb;

    localparam  CLK_PERIOD      = 20; 
    localparam  CLOCK_FREQ_HZ   = 50_000_000;
    localparam  BAUD_RATE       = 115_200;

    reg Clk, RstB, iStart;
    reg [8-1:0] iParData;
    wire        oSerData, oTxBusy;

    Par2Ser #(
        .CLOCK_FREQ_HZ  (CLOCK_FREQ_HZ),
        .BAUD_RATE      (BAUD_RATE)
    ) u_Par2Ser (
        .Clk            (Clk),
        .RstB           (RstB),
        .iParData       (iParData),
        .oSerData       (oSerData),
        .oTxBusy        (oTxBusy)
    );

    always #(CLK_PERIOD/2) Clk = ~Clk;


endmodule

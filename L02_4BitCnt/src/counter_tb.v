`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Thai-Nichi Institute of Technology
// Engineer: Ph.Pruet
// 
// Create Date: 06/02/2026 02:26:15 PM
// Design Name: conter_tb
// Module Name: counter_tb
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


module counter_tb();

localparam      CLK_PERIOD = 20;

reg             Clk;
reg             Rst;
reg             iCntEn;
wire [4-1:0]    oCnt;

counter u_counter(
    .Clk    (Clk    ),
    .Rst    (Rst    ),
    .iCntEn (iCntEn ),
    .oCnt   (oCnt   )
);

initial Clk = 0;
always #(CLK_PERIOD/2) Clk = ~Clk;

task apply_reset;
    begin
        Rst     = 0;
        iCntEn  = 1'b0;
        @(posedge Clk); #1;
        @(posedge Clk); #1;
        Rst     = 1;
        @(posedge Clk); #1;
    end
endtask

task counter_enable;
    input enable;
    begin
        iCntEn = enable;
        @(posedge Clk); #1;
        $display("t=%0t | iCntEn=%b | oCnt=%d", $time, iCntEn, oCnt);
    end
endtask

initial begin
    $monitor("t=%0t | iCntEn=%b | oCnt=%d", $time, iCntEn, oCnt);

    apply_reset;

    $display("--- Test: Count Enable ---");
    counter_enable(1'b1);
    #100;
    counter_enable(1'b0);
    #100;
    counter_enable(1'b1);
    #100;
    counter_enable(1'b0);

    $display("Simulation done.");
    $finish;
end

endmodule

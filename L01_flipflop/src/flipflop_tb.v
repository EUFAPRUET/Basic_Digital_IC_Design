`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Thai-Nichi Institute of Technology
// Engineer: Ph.Pruet
// 
// Create Date: 06/02/2026 10:55:56 AM
// Design Name: flipflop_tb
// Module Name: flipflop_tb
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


module flipflop_tb();

localparam      CLK_PERIOD = 20;

reg             Clk;
reg             Rst;
reg     [4-1:0] iData;
wire    [4-1:0] oQ;
wire    [4-1:0] oQn;

flipflop u_flipflop (
    .Clk    (Clk    ),
    .Rst    (Rst    ),
    .iData  (iData  ),
    .oQ     (oQ     ),
    .oQn    (oQn    )
);

initial Clk = 0;
always #(CLK_PERIOD/2) Clk = ~Clk;

task apply_reset;
    begin
        Rst     = 0;
        iData   = 4'd0;
        @(posedge Clk); #1;
        @(posedge Clk); #1;
        Rst     = 1;
        @(posedge Clk); #1;
    end
endtask

task drive_data;
    input   [4-1:0] data;
    begin
        iData = data;
        @(posedge Clk); #1;
        $display("t=%0t | iData=%h | oQ=%h | oQn=%h", $time, iData, oQ, oQn);
    end
endtask

task check_output;
    input [3:0] expected_Q;
    begin
        if (oQ === expected_Q)
            $display("PASS: oQ=%h (expected %h)", oQ, expected_Q);
        else
            $display("FAIL: oQ=%h (expected %h)", oQ, expected_Q);
        if (oQn !== ~expected_Q)
            $display("FAIL: oQn=%h (expected %h)", oQn, ~expected_Q);
    end
endtask

task test_reset_mid;
    begin
        $display("--- Test: reset mid-operation ---");
        drive_data(4'hA);
        Rst = 0;
        @(posedge Clk); #1;
        check_output(4'd0);
        Rst = 1;
    end
endtask

initial begin
    $monitor("t=%0t | Rst=%b | iData=%h | oQ=%h | oQn=%h",
             $time, Rst, iData, oQ, oQn);

    apply_reset;

    $display("--- Test: normal data ---");
    drive_data(4'hA); check_output(4'hA);
    drive_data(4'h5); check_output(4'h5);
    drive_data(4'hF); check_output(4'hF);
    drive_data(4'h3); check_output(4'h3);

    test_reset_mid;

    drive_data(4'h7); check_output(4'h7);

    $display("Simulation done.");
    $finish;
end
endmodule

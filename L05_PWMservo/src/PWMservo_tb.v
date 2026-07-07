`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Thai-Nichi Institute of Technology
// Engineer: Ph.Pruet
// 
// Create Date: 07/03/2026 09:59:16 AM
// Design Name: PWM Testbench for servo motor
// Module Name: PWMservo_tb
// Project Name: PWMservo
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


module PWMservo_tb;

    localparam CLK_PERIOD = 20;
    localparam SV_PERIOD  = 2_000_000;
    localparam PW_CENTER  = 150_000;
    localparam PW_RIGHT   = 125_000;
    localparam PW_LEFT    = 175_000;

    reg        Clk, Rst;
    reg  [1:0] iCmdLR;
    wire [1:0] oPWMSv;
    wire [31:0] oStatusSv;

    PWMservo u_PWMservo (
        .Clk       (Clk),
        .Rst       (Rst),
        .iCmdLR    (iCmdLR),
        .oPWMSv    (oPWMSv),
        .oStatusSv (oStatusSv)
    );

    always #(CLK_PERIOD/2) Clk = ~Clk;

    integer pass_cnt = 0;
    integer fail_cnt = 0;

    task measure_pw;
        output integer pw_cycles;
        integer cnt;
        begin
            cnt = 0;
            @(negedge oPWMSv[0]);
            @(posedge oPWMSv[0]); 
            while (oPWMSv[0] === 1'b1) begin
                cnt = cnt + 1;
                @(posedge Clk);
            end
            pw_cycles = cnt;
        end
    endtask

    task check_pw;
        input integer expected;
        input [8*20-1:0] label;
        integer measured;
        integer diff;
        begin
            measure_pw(measured);
            diff = measured - expected;

            if (diff < 0) diff = -diff;
            if (diff <= 2) begin
                $display("  [PASS] %s | measured=%0d expected=%0d", label, measured, expected);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("  [FAIL] %s | measured=%0d expected=%0d", label, measured, expected);
                fail_cnt = fail_cnt + 1;
            end
        end
    endtask

    initial begin
        Clk    = 0;
        Rst    = 0;
        iCmdLR = 2'b00;

        #(CLK_PERIOD * 5);
        Rst = 1;
        #(CLK_PERIOD * 5);

        $display("=== PWMservo Test Start ===");

        $display("[TC1] CMD=2'b00 -> CENTER");
        iCmdLR = 2'b00;
        check_pw(PW_CENTER, "CENTER");

        $display("[TC2] CMD=2'b01 -> RIGHT");
        iCmdLR = 2'b01;
        check_pw(PW_RIGHT, "RIGHT");

        $display("[TC3] CMD=2'b10 -> LEFT");
        iCmdLR = 2'b10;
        check_pw(PW_LEFT, "LEFT");

        $display("[TC4] CMD=2'b11 -> DEFAULT=CENTER");
        iCmdLR = 2'b11;
        check_pw(PW_CENTER, "DEFAULT->CENTER");

        $display("[TC5] CMD=2'b00 -> CENTER again");
        iCmdLR = 2'b00;
        check_pw(PW_CENTER, "CENTER again");

        $display("[TC6] oPWMSv both bits match");
        @(posedge oPWMSv[0]);
        @(posedge Clk);
        if (oPWMSv[0] === oPWMSv[1]) begin
            $display("  [PASS] oPWMSv = %02b", oPWMSv);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("  [FAIL] oPWMSv = %02b (mismatch)", oPWMSv);
            fail_cnt = fail_cnt + 1;
        end

        $display("[TC7] oStatusSv field check");
        iCmdLR = 2'b01;
        @(posedge Clk); @(posedge Clk);
        if (oStatusSv[1:0] === 2'b01) begin
            $display("  [PASS] oStatusSv[1:0] = %02b", oStatusSv[1:0]);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("  [FAIL] oStatusSv[1:0] = %02b (expected 01)", oStatusSv[1:0]);
            fail_cnt = fail_cnt + 1;
        end

        $display("==========================");
        $display("  PASS: %0d / FAIL: %0d", pass_cnt, fail_cnt);
        $display("==========================");
        $finish;
    end

    initial begin
        #(CLK_PERIOD * SV_PERIOD * 12);
        $display("[TIMEOUT]");
        $finish;
    end

endmodule
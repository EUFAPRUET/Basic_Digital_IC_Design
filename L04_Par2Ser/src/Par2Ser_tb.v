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
    localparam  BIT_PERIOD      = 8680; 

    reg         Clk, RstB, iStart;
    reg [8-1:0] iParData;
    wire        oSerData, oTxBusy;

    Par2Ser #(
        .CLOCK_FREQ_HZ  (CLOCK_FREQ_HZ),
        .BAUD_RATE      (BAUD_RATE)
    ) u_Par2Ser (
        .Clk            (Clk),
        .RstB           (RstB),
        .iStart         (iStart), 
        .iParData       (iParData),
        .oSerData       (oSerData),
        .oTxBusy        (oTxBusy)
    );

    always #(CLK_PERIOD/2) Clk = ~Clk;

    integer pass_cnt = 0;
    integer fail_cnt = 0;

    task check_tx;
        input [7:0] expected;
        reg   [7:0] rx_byte;
        integer i;
        begin
            @(negedge oSerData);
            #(BIT_PERIOD/2);
            if (oSerData !== 1'b0)
                $display("  [WARN] Start bit not 0 at sample point");

            for (i = 0; i < 8; i = i + 1) begin
                #(BIT_PERIOD);
                rx_byte[i] = oSerData;
            end

            #(BIT_PERIOD);
            if (oSerData !== 1'b1)
                $display("  [WARN] Stop bit not 1");

            if (rx_byte === expected) begin
                $display("  [PASS] TX = 0x%02X", rx_byte);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("  [FAIL] TX = 0x%02X | Expected 0x%02X", rx_byte, expected);
                fail_cnt = fail_cnt + 1;
            end
        end
    endtask

    initial begin
        Clk      = 0;
        RstB     = 0;
        iStart   = 0;
        iParData = 8'h00;

        #(CLK_PERIOD * 5);
        RstB = 1;
        #(CLK_PERIOD * 5);

        $display("=== Par2Ser TX Test Start ===");

        $display("[TC1] Send 0x55");
        iParData = 8'h55;
        @(posedge Clk); iStart   = 1'b1;
        @(posedge Clk);
        iStart   = 1'b0;
        check_tx(8'h55);
        wait (!oTxBusy);
        #(BIT_PERIOD);

        $display("[TC2] Send 0xA5");
        iParData = 8'hA5;
        @(posedge Clk); iStart   = 1'b1;
        @(posedge Clk);
        iStart   = 1'b0;
        check_tx(8'hA5);
        wait (!oTxBusy);
        #(BIT_PERIOD);

        $display("[TC3] Send 0x00");
        iParData = 8'h00;
        @(posedge Clk); iStart   = 1'b1;
        @(posedge Clk);
        iStart   = 1'b0;
        check_tx(8'h00);
        wait (!oTxBusy);
        #(BIT_PERIOD);

        $display("[TC4] Send 0xFF");
        iParData = 8'hFF;
        @(posedge Clk); iStart   = 1'b1;
        @(posedge Clk);
        iStart   = 1'b0;
        check_tx(8'hFF);
        wait (!oTxBusy);
        #(BIT_PERIOD);

        $display("[TC5] iStart during Busy - must be ignored");
        iParData = 8'h12;
        @(posedge Clk); iStart   = 1'b1;
        @(posedge Clk);
        iStart   = 1'b0;

        fork
            check_tx(8'h12);
            begin
                #(BIT_PERIOD);
                iParData = 8'h99;
                @(posedge Clk); iStart   = 1'b1;
                @(posedge Clk);
                iStart   = 1'b0;
            end
        join

        wait (!oTxBusy);
        #(BIT_PERIOD);

        $display("==========================");
        $display("  PASS: %0d / FAIL: %0d", pass_cnt, fail_cnt);
        $display("==========================");
        $finish;
    end

    initial begin
        #(BIT_PERIOD * 200);
        $display("[TIMEOUT] Test \u0e22\u0e07\u0e44\u0e21\u0e48\u0e08\u0e1a");
        $finish;
    end

endmodule

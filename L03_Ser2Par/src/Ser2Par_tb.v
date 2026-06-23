`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Thai-Nichi Institute of Technology
// Engineer: Ph.Pruet
// 
// Create Date: 06/17/2026 02:04:37 PM
// Design Name: Serial to Parallel Test Bench
// Module Name: Ser2Par_tb
// Project Name: Ser2Par
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


`timescale 1ns / 1ps

module Ser2Par_tb;

    localparam CLK_PERIOD = 20; 
    localparam BIT_PERIOD = 8680;

    reg        Clk, Rst, iSerData;
    wire [7:0] oParData;
    wire       oDataValid;

    Ser2Par #(
        .CLOCK_FREQ_HZ(50_000_000),
        .BAUD_RATE    (115_200)
    ) u_Ser2Par (
        .Clk       (Clk),
        .Rst       (Rst),
        .iSerData  (iSerData),
        .oParData  (oParData),
        .oDataValid(oDataValid)
    );

    always #(CLK_PERIOD/2) Clk = ~Clk;

    integer pass_cnt = 0;
    integer fail_cnt = 0;

    task uart_send;
        input [7:0] data;
        integer i;
        begin
            iSerData = 1'b0;
            #(BIT_PERIOD);
            for (i = 0; i < 8; i = i + 1) begin
                iSerData = data[i];
                #(BIT_PERIOD);
            end
            iSerData = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    task check;
        input [7:0] expected;
        begin
            @(posedge oDataValid);
            @(posedge Clk);
            if (oParData === expected) begin
                $display("  [PASS] Got 0x%02X", oParData);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("  [FAIL] Got 0x%02X | Expected 0x%02X", oParData, expected);
                fail_cnt = fail_cnt + 1;
            end
        end
    endtask

    initial begin
        Clk      = 0;
        Rst      = 0;
        iSerData = 1'b1;

        #(CLK_PERIOD * 5);
        Rst = 1;
        #(CLK_PERIOD * 5);

        $display("=== UART RX Test Start ===");

        $display("[TC1] Send 0x55");
        fork
            uart_send(8'h55);
            check(8'h55);
        join
        #(BIT_PERIOD);

        $display("[TC2] Send 0xA5");
        fork
            uart_send(8'hA5);
            check(8'hA5);
        join
        #(BIT_PERIOD);

        $display("[TC3] Send 0x00");
        fork
            uart_send(8'h00);
            check(8'h00);
        join
        #(BIT_PERIOD);

        $display("[TC4] Send 0xFF");
        fork
            uart_send(8'hFF);
            check(8'hFF);
        join
        #(BIT_PERIOD);

        $display("[TC5] Back-to-back 0x12, 0x34");
        fork
            begin
                uart_send(8'h12);
                uart_send(8'h34);
            end
            begin
                check(8'h12);
                check(8'h34);
            end
        join
        #(BIT_PERIOD);

        $display("==========================");
        $display("  PASS: %0d / FAIL: %0d", pass_cnt, fail_cnt);
        $display("==========================");
        $finish;
    end

    initial begin
        #(BIT_PERIOD * 200);
        $display("[TIMEOUT] Test did not finish");
        $finish;
    end

endmodule

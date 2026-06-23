`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Thai-Nichi Institute of Technology
// Engineer: Ph.Pruet
// 
// Create Date: 06/23/2026 02:49:26 PM
// Design Name: Parallel to Serial
// Module Name: Par2Ser
// Project Name: L04_Par2Ser
// Target Devices: Parallel
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


module Par2Ser #(
    parameter CLOCK_FREQ_HZ = 50_000_000,
    parameter BAUD_RATE     = 115_200
)(
    input               RstB, 
    input               Clk,

    input               iStart, 
    input       [8-1:0] iParData,

    output              oSerData,
    output              oTxBusy 
);

localparam  CLKS_PER_BIT = CLOCK_FREQ_HZ / BAUD_RATE;

parameter   sIdle   = 2'b00,
            sStart  = 2'b01,
            sLoad   = 2'b10,
            sStop   = 2'b11;

reg [2-1:0] rState;
reg [9-1:0] rBaudCnt;
reg [3-1:0] rBitIdx;
reg [8-1:0] rShiftReg;
reg         rTxLine;
reg         rTxBusy;

always @(posedge Clk) begin : u_rState
    if (!RstB) begin
        rState <= sIdle;
    end else begin
        case (rState)
            sIdle: begin
                if (iStart)
                    rState <= sStart;
                else
                    rState <= rState;
            end

            sStart: begin
                if (rBaudCnt == CLKS_PER_BIT - 1)
                    rState <= sLoad;
                else
                    rState <= rState;
            end

            sLoad: begin
                if (rBaudCnt == CLKS_PER_BIT - 1) begin
                    if (rBitIdx == 3'd7)
                        rState <= sStop;
                    else
                        rState <= rState;
                end else begin
                    rState <= rState;
                end
            end

            sStop: begin
                if (rBaudCnt == CLKS_PER_BIT - 1)
                    rState <= sIdle;
                else
                    rState <= rState;
            end

            default: rState <= sIdle;
        endcase
    end
end

always @(posedge Clk) begin : u_rBaudCnt
    if (!RstB) begin
        rBaudCnt <= 9'd0;
    end else begin
        if (rState == sStart || rState == sLoad || rState == sStop) begin
            if (rBaudCnt == CLKS_PER_BIT - 1)
                rBaudCnt <= 9'd0;
            else
                rBaudCnt <= rBaudCnt + 1;
        end else begin
            rBaudCnt <= 9'd0;
        end
    end
end

always @(posedge Clk) begin : u_rBitIdx
    if (!RstB) begin
        rBitIdx <= 3'd0;
    end else begin
        if (rState == sLoad) begin
            if (rBaudCnt == CLKS_PER_BIT - 1) begin
                if (rBitIdx == 3'd7)
                    rBitIdx <= 3'd0;
                else
                    rBitIdx <= rBitIdx + 1;
            end else begin
                rBitIdx <= rBitIdx;
            end
        end else begin
            rBitIdx <= 3'd0;
        end
    end
end

always @(posedge Clk) begin : u_rShiftReg
    if (!RstB) begin
        rShiftReg <= 8'h00;
    end else begin
        if (rState == sIdle && iStart) begin
            rShiftReg <= iParData;
        end else begin
            rShiftReg <= rShiftReg;
        end
    end
end

always @(posedge Clk) begin : u_rTxLine
    if (!RstB) begin
        rTxLine <= 1'b1;
    end else begin
        case (rState)
            sIdle:  rTxLine <= 1'b1;
            sStart: rTxLine <= 1'b0;
            sLoad:  rTxLine <= rShiftReg[rBitIdx];
            sStop:  rTxLine <= 1'b1;
            default: rTxLine <= 1'b1;
        endcase
    end
end

always @(posedge Clk) begin : u_rTxBusy
    if (!RstB) begin
        rTxBusy <= 1'b0;
    end else begin
        if (rState == sIdle && iStart)
            rTxBusy <= 1'b1;
        else if (rState == sStop && rBaudCnt == CLKS_PER_BIT - 1)
            rTxBusy <= 1'b0;
        else
            rTxBusy <= rTxBusy;
    end
end

assign oSerData = rTxLine;
assign oTxBusy  = rTxBusy;

endmodule

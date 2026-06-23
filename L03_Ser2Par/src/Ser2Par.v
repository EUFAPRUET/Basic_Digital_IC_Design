`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Thai-Nichi Institute of Technology
// Engineer: Ph.Pruet
// 
// Create Date: 06/15/2026 11:58:44 AM
// Design Name: Serial to Parallel
// Module Name: Ser2Par
// Project Name: L03_Ser2Par
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


module Ser2Par #(
    parameter CLOCK_FREQ_HZ = 50_000_000,
    parameter BAUD_RATE     = 115_200
)(
    input               Clk,
    input               Rst,

    input               iSerData,
    output      [8-1:0] oParData,
    output              oDataValid
);

localparam  CLKS_PER_BIT     = CLOCK_FREQ_HZ / BAUD_RATE,
            HALF_BIT         = CLKS_PER_BIT / 2;

parameter   sIdle   = 2'b00,
            sStart  = 2'b01,
            sLoad   = 2'b10,
            sStop   = 2'b11;

reg [2-1:0]     rSerData;

always @(posedge Clk) begin : u_rSerData
    if (!Rst) begin
        rSerData <= 2'b11;
    end else begin
        rSerData <= {rSerData[0], iSerData};
    end
end

reg [2-1:0]     rState;
reg [9-1:0]     rBaudCnt;
reg [3-1:0]     rBitIdx;
reg [8-1:0]     rShiftReg;

always @(posedge Clk) begin : u_rState
    if (!Rst) begin
        rState <= sIdle;
    end else begin
        case (rState)
            sIdle: begin
                if (rSerData[1] == 1'b0)
                    rState <= sStart;
                else
                    rState <= rState;
            end

            sStart: begin
                if (rBaudCnt == HALF_BIT - 1) begin
                    if (rSerData[1] == 1'b0)
                        rState <= sLoad;
                    else
                        rState <= sIdle;
                end else begin
                    rState <= rState;
                end
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
    if (!Rst) begin
        rBaudCnt <= 9'd0;
    end else begin
        if (rState == sStart) begin
            if (rBaudCnt == HALF_BIT - 1)
                rBaudCnt <= 9'd0;
            else
                rBaudCnt <= rBaudCnt + 1;

        end else if (rState == sLoad || rState == sStop) begin
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
    if (!Rst) begin
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
    if (!Rst) begin
        rShiftReg <= 8'h00;
    end else begin
        if (rState == sLoad && rBaudCnt == CLKS_PER_BIT - 1) begin
            rShiftReg[rBitIdx] <= rSerData[1];
        end else begin
            rShiftReg <= rShiftReg;
        end
    end
end

reg [8-1:0] rParData;
reg         rDataValid;

always @(posedge Clk) begin : u_rOutput
    if (!Rst) begin
        rParData   <= 8'h00;
        rDataValid <= 1'b0;
    end else begin
        rDataValid <= 1'b0;
        if (rState == sStop && rBaudCnt == CLKS_PER_BIT - 1) begin
            if (rSerData[1] == 1'b1) begin
                rParData   <= rShiftReg;
                rDataValid <= 1'b1;
            end
        end
    end
end

assign oParData   = rParData;
assign oDataValid = rDataValid;



endmodule

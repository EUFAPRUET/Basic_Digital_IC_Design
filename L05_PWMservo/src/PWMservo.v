`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Thai-Nichi Institute of Technology
// Engineer: Ph.Pruet
// 
// Create Date: 07/01/2026 12:55:14 PM
// Design Name: PWM for servo motor
// Module Name: PWMservo
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


module PWMservo(
    /* Clock/Reset */
    input   wire                Clk,
    input   wire                Rst,

    input   wire    [2-1:0]     iCmdLR,
    output  wire    [2-1:0]     oPWMSv,

    output  wire    [32-1:0]    oStatusSv
);
    localparam  SV_PERIOD = 21'd2_000_000,
                PW_CENTER = 21'd150_000,
                PW_RIGHT  = 21'd125_000,
                PW_LEFT   = 21'd175_000;

    reg     [21-1:0]    rCnt,
                        rPulseWidth;

    wire    [1-1:0]     wPWMSv = (rCnt < rPulseWidth);

    always @(posedge Clk) begin : PERIOD_COUNTER
        if (!Rst) begin
            rCnt <= 21'd0;
        end else begin
            if (rCnt >= (SV_PERIOD - 1)) begin
                rCnt <= 21'd0;
            end else begin
                rCnt <= rCnt + 1;
            end
        end
    end // PERIOD_COUNTER


    always @(posedge Clk) begin : CMD_DECODER
        if (!Rst) begin
            rPulseWidth <= PW_CENTER;
        end else begin
            case (iCmdLR)
                2'b00   :   rPulseWidth <= PW_CENTER;
                2'b01   :   rPulseWidth <= PW_RIGHT;
                2'b10   :   rPulseWidth <= PW_LEFT;
                default :   rPulseWidth <= PW_CENTER; 
            endcase
        end
    end // CMD_DECODER


    assign  oPWMSv      = {2{wPWMSv}};
    assign  oStatusSv   = {7'd0, oPWMSv, rPulseWidth, iCmdLR};

endmodule


`timescale 1ns / 1ps

`include "params.vh"

module fifo_synch(
    input clk, 
    input rst_n,
    
    input i_wr_en, 
    input [7:0] i_data_in,
    output o_full,
    
    input i_rd_en,
    output o_empty,
    output logic [7:0] o_data
);

    logic [7:0] memory [0:DEPTH-1];
    logic [2:0] rd_ptr;
    logic [2:0] wr_ptr;
    logic [3:0] counter;

    // === Writing ===
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 3'd0;
        end
        else begin 
            if (i_wr_en) begin
                memory[wr_ptr] <= i_data_in;
                wr_ptr <= wr_ptr + 1;
            end
        end
    end

    // === Reading ===
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin 
            rd_ptr <= 3'd0;
        end
        else begin 
            if (i_rd_en) begin
                o_data <= memory[rd_ptr];
                rd_ptr <= rd_ptr + 1;
            end
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 4'd0;
        end
        else begin
            case ({i_wr_en, i_rd_en}) 
                2'b10: counter <= counter + 1;
                2'b01: counter <= counter - 1;
                2'b11: counter <= 0;
                2'b00: counter <= 0;
                default: counter <= counter;
            endcase
        end
    end

    assign o_full   = (counter == DEPTH) ? 1'b1 : 1'b0;
    assign o_empty  = (counter == 0) ? 1'b1 : 1'b0;

endmodule


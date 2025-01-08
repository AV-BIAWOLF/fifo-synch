`timescale 1ns / 1ps

module tb_fifo_synch;

    // Parameters
    `include "params.vh"

    // Signals
    logic clk; 
    logic rst_n;

    logic i_wr_en; 
    logic [7:0] i_data_in;
    logic o_full;

    logic i_rd_en;
    logic o_empty;
    logic [7:0] o_data;
    

    // DUT instantiation
    fifo_synch #() fifo_synch_dut (
        .clk(clk), 
        .rst_n(rst_n),
        .i_wr_en(i_wr_en), 
        .i_data_in(i_data_in),
        .o_full(o_full),
        .i_rd_en(i_rd_en),
        .o_empty(o_empty),
        .o_data(o_data)
    );
    
    

    // === Clock signal generation ===
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // === Testbench tasks ===
    task reset_fifo();
        begin
            rst_n = 1'b0;
            repeat (2) @(posedge clk); // Hold reset for 2 clock cycles
            rst_n = 1'b1;
        end
    endtask

    task write_data(input [7:0] data);
        begin
            if (!o_full) begin
                i_wr_en = 1'b1;
                i_data_in = data;
                @(posedge clk);
                i_wr_en = 1'b0;
            end else begin
                $display("FIFO is full, cannot write %0d at time %t", data, $time);
            end
        end
    endtask

    task read_data(output [7:0] data_out);
        begin
            if (!o_empty) begin
                i_rd_en = 1'b1;
                @(posedge clk);
                data_out = o_data;
                i_rd_en = 1'b0;
            end else begin
                $display("FIFO is empty, cannot read at time %t", $time);
            end
        end
    endtask

    logic [7:0] read_data_out;    
    
    logic [3:0] test_scenario;

    
    // === Main test sequence ===
    initial begin
        // Initialize inputs
        i_wr_en = 1'b0;
        i_rd_en = 1'b0;
        i_data_in = 8'd0;
        //
        test_scenario = 4'd0;
        //

        // Reset the FIFO
        reset_fifo();

        // Test 1: Write and Read
        $display("\nStarting Test 1: Write and Read...");
        test_scenario = 4'd1;
        write_data(8'd10);
        write_data(8'd20);
        write_data(8'd30);
        
        
        read_data(read_data_out);
        $display("Read data: %0d at time %t", read_data_out, $time);
        read_data(read_data_out);
        $display("Read data: %0d at time %t", read_data_out, $time);

        // Test 2: Write until Full
        $display("\nStarting Test 2: Write until Full...");
        test_scenario = 4'd2;
        for (int i = 0; i < DEPTH; i++) begin
            write_data(i);
        end
        write_data(8'd100); // Attempt to write beyond full

        // Test 3: Read until Empty
        $display("\nStarting Test 3: Read until Empty...");
        test_scenario = 4'd3;
        for (int i = 0; i < DEPTH; i++) begin
            read_data(read_data_out);
            $display("Read data: %0d at time %t", read_data_out, $time);
        end
        read_data(read_data_out); // Attempt to read beyond empty

        // Finish simulation
        $display("Test completed at time %t", $time);
        $finish;
    end

    // Monitor signals for debugging
    initial begin
        $monitor("Time: %0t | wr_en: %b, data_in: %0d, full: %b | rd_en: %b, data_out: %0d, empty: %b", 
                 $time, i_wr_en, i_data_in, o_full, i_rd_en, o_data, o_empty);
    end

endmodule

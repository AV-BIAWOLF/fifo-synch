# Synchronous FIFO Design and Testbench

This repository contains a simple implementation of a **Synchronous FIFO (First-In-First-Out)** module and a corresponding testbench for functional verification. The design is written in **SystemVerilog** and verified using basic directed tests. Below are the details of the implementation and how to run it.

---

## Design Overview

The FIFO is a synchronous memory structure that allows for sequential write and read operations. It includes mechanisms to signal when the FIFO is full or empty. The following are the key components of the design:

### Features
- **Depth**: Parameterized using the `DEPTH` macro in `params.vh`.
- **Width**: Fixed at 8 bits for this implementation.
- **Full and Empty Flags**: Output signals indicate when the FIFO is full (`o_full`) or empty (`o_empty`).
- **Counters**: Internally tracks the number of stored items.

### Module Interface
```verilog
module fifo_synch(
    input clk, 
    input rst_n,               // Active-low reset
    input i_wr_en,             // Write enable
    input [7:0] i_data_in,     // Input data
    output o_full,             // Full flag
    input i_rd_en,             // Read enable
    output o_empty,            // Empty flag
    output logic [7:0] o_data  // Output data
);
```

### Key Processes
1. **Write Operation**:
   - Data is written into the memory if `i_wr_en` is asserted and the FIFO is not full (`o_full == 0`).
   - Write pointer (`wr_ptr`) increments after each write.

2. **Read Operation**:
   - Data is read from the memory if `i_rd_en` is asserted and the FIFO is not empty (`o_empty == 0`).
   - Read pointer (`rd_ptr`) increments after each read.

3. **Counter Logic**:
   - Tracks the number of elements in the FIFO.
   - Ensures proper management of `o_full` and `o_empty` flags.

---

## Testbench

The testbench verifies the FIFO functionality through directed tests. It initializes the design, performs reset, and sequentially tests the following scenarios:

### Scenarios
1. **Write and Read Test**:
   - Writes data into the FIFO and reads it back to verify functionality.
   
2. **Write Until Full Test**:
   - Writes data until the FIFO is full, then verifies that no further writes are allowed.

3. **Read Until Empty Test**:
   - Reads data until the FIFO is empty, then verifies that no further reads are allowed.

### Testbench Features
- **Task-Based Verification**:
  - Tasks `write_data` and `read_data` simplify the test code.
- **Test Scenario Markers**:
  - A `test_scenario` signal is used to mark the active test on waveforms.

---

## Simulation Output

The simulation provides the following key outputs:
1. **Console Logs**:
   - Detailed logs for each test scenario, including data written/read, FIFO status, and error messages for invalid operations.

   Example:
   ```
   Starting Test 1: Write and Read...
   Read data: 10 at time 55000
   Read data: 20 at time 65000

   Starting Test 2: Write until Full...
   FIFO is full, cannot write 100 at time 135000

   Starting Test 3: Read until Empty...
   FIFO is empty, cannot read at time 215000
   Test completed at time 215000
   ```

2. **Waveforms**:
   - Visual representation of all signals, including `wr_ptr`, `rd_ptr`, `o_full`, `o_empty`, and `test_scenario`.

---
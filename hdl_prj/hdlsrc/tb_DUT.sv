// -------------------------------------------------------------
// Testbench: DUT (BPSK Modulator + Demodulator loopback)
// Target: Xilinx Zynq-7020 (xc7z020-2clg400)
//
// Pipeline:
//   bits_in sampled at posedge N
//   → BPSK_Mod_HDL 2-cycle pipeline → tx_mod_out valid at posedge N+2
//   → rx_sig_in applied at negedge N+2 → BPSK_Demod_HDL combinational
//   → bits_out valid at same time step
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module tb_DUT;

    // DUT signals
    reg         clk;
    reg         reset;
    reg         clk_enable;
    reg  [7:0]  bits_in;
    reg  [15:0] rx_sig_in;
    wire        ce_out;
    wire [15:0] tx_mod_out;
    wire [7:0]  bits_out;

    // Testbench state
    reg  [7:0]  expected [0:1023];  // expected output per cycle
    integer     i, bit_count, error_count;
    integer     cycle;

    // DUT instantiation
    DUT u_DUT (
        .clk        (clk),
        .reset      (reset),
        .clk_enable (clk_enable),
        .bits_in    (bits_in),
        .rx_sig_in  (rx_sig_in),
        .ce_out     (ce_out),
        .tx_mod_out (tx_mod_out),
        .bits_out   (bits_out)
    );

    // Clock generation: 100 MHz (10 ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Main test - drive inputs on negedge to avoid races
    initial begin
        // Initialize
        reset       = 1;
        clk_enable  = 0;
        bits_in     = 8'd0;
        rx_sig_in   = 16'd0;
        error_count = 0;
        bit_count   = 0;
        cycle       = 0;

        // Reset sequence (hold through 2 posedges)
        repeat (2) @(posedge clk);
        reset = 0;
        @(posedge clk);
        clk_enable = 1;

        // Generate and test 1000 random bits
        for (i = 0; i < 1000; i = i + 1) begin
            @(negedge clk);
            cycle = cycle + 1;

            // Set new stimulus on negedge (stable before next posedge)
            bits_in = ($random % 2) ? 8'd1 : 8'd0;

            // Loopback tx_mod_out → rx_sig_in
            // tx_mod_out reflects bits_in from 2 posedges ago
            rx_sig_in = tx_mod_out;

            // Record expected: what bits_out should be when this bit
            // has propagated through the 2-cycle pipeline.
            // Bits_in latched at posedge N appears at bits_out
            // at the negedge N+2 (same as cycle N+2).
            // So at cycle C, bits_out corresponds to bits_in set at cycle C-2.
            expected[cycle] = bits_in;

            // Check: at cycle >= 3, bits_out = expected[cycle-2]
            if (cycle >= 3) begin
                bit_count = bit_count + 1;
                if (bits_out !== expected[cycle-2]) begin
                    error_count = error_count + 1;
                    $display("[ERROR] Cycle %0d: sent=0b%b, got=0b%b (expected=0b%b)",
                             cycle, expected[cycle-2], bits_out, expected[cycle-2]);
                end
            end
        end

        // Drain pipeline
        repeat (4) @(negedge clk);

        // Report
        $display("");
        $display("========================================");
        $display("  BPSK DUT Loopback Test Results");
        $display("========================================");
        $display("  Total bits checked : %0d", bit_count);
        $display("  Bit errors         : %0d", error_count);
        if (error_count == 0) begin
            $display("  STATUS             : PASS");
        end else begin
            $display("  STATUS             : FAIL");
        end
        $display("========================================");

        $finish;
    end

    // Monitor waveform signals
    initial begin
        $dumpfile("tb_DUT.vcd");
        $dumpvars(0, tb_DUT);
    end

    // Timeout
    initial begin
        #100000;
        $display("[ERROR] Simulation timeout!");
        $finish;
    end

endmodule

// -------------------------------------------------------------
// Testbench: DUT (D-BPSK Modulator + Demodulator loopback)
// Target: Xilinx Zynq-7020 (xc7z020-2clg400)
//
// Pipeline (3 clock cycles):
//   bits_in sampled at posedge N
//   -> DBPSK_Mod_HDL 2-cycle pipeline -> tx_mod_out valid at posedge N+2
//   -> rx_sig_in applied at negedge N+2 -> DBPSK_Demod_HDL
//   -> bits_out valid at cycle N+3
//
// D-BPSK algorithm (differential encoding/decoding is transparent):
//   enc[n] = bits_in[n] XOR enc[n-1]  (init=0)
//   bits_out[n] = enc[n] XOR enc[n-1] = bits_in[n]
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
    reg  [7:0]  expected [0:1023];
    integer     i, bit_count, error_count;
    integer     cycle;

    // Waveform-friendly expected value
    reg  [7:0]  expected_now;
    reg  [7:0]  expected_prev;

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

            // Loopback tx_mod_out -> rx_sig_in
            rx_sig_in = tx_mod_out;

            // Record expected
            expected[cycle] = bits_in;

            // Check: at cycle >= 4, bits_out = expected[cycle-3]
            // (3-cycle pipeline: Mod 2 cycles + Demod 1 cycle)
            if (cycle >= 4) begin
                expected_prev = expected[cycle-3];
                expected_now  = bits_in;
                bit_count = bit_count + 1;
                if (bits_out !== expected[cycle-3]) begin
                    error_count = error_count + 1;
                    $display("[ERROR] Cycle %0d: sent=0b%b, got=0b%b (expected=0b%b)",
                             cycle, expected[cycle-3], bits_out, expected[cycle-3]);
                end
            end
        end

        // Drain pipeline
        repeat (4) @(negedge clk);

        // Report
        $display("");
        $display("========================================");
        $display("  D-BPSK DUT Loopback Test Results");
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
        $dumpfile("tb_DUT_dbpsk.vcd");
        $dumpvars(0, tb_DUT);
    end

    // Timeout
    initial begin
        #100000;
        $display("[ERROR] Simulation timeout!");
        $finish;
    end

endmodule

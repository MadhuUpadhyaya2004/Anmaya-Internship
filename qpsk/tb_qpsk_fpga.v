//==============================================================================
// FIXED QPSK Testbench - Uses RAW symbol_tick instead of stretched ready signal
//==============================================================================
`timescale 1ns / 1ps

module tb_qpsk_fpga;
    
    // DUT signals
    reg clk;
    reg reset;
    reg test_mode;
    
    wire [7:0] seg;
    wire [7:0] an;
    wire signed [11:0] qpsk_out;
    wire [3:0] led_symbol;
    wire led_symbol_ready;      // Stretched for human visibility
    wire led_heartbeat;
    wire led_phase_45, led_phase_135, led_phase_225, led_phase_315;
    wire [2:0] rgb_led0, rgb_led1;
    
    // Instantiate DUT
    qpsk_modulator_fpga uut (
        .clk(clk),
        .reset(reset),
        .test_mode(test_mode),
        .seg(seg),
        .an(an),
        .qpsk_out(qpsk_out),
        .led_symbol(led_symbol),
        .led_symbol_ready(led_symbol_ready),    // Stretched (50ms)
        .led_heartbeat(led_heartbeat),
        .led_phase_45(led_phase_45),
        .led_phase_135(led_phase_135),
        .led_phase_225(led_phase_225),
        .led_phase_315(led_phase_315),
        .rgb_led0(rgb_led0),
        .rgb_led1(rgb_led1)
    );
    
    // Access internal signal directly from DUT
    wire led_symbol_tick = uut.symbol_pulse;  // RAW 1-cycle pulse
    
    //==========================================================================
    // Clock Generator - 100 MHz (10ns period)
    //==========================================================================
    initial clk = 0;
    always #5 clk = ~clk;
    
    //==========================================================================
    // Internal Signal Monitors
    //==========================================================================
    wire [8:0] phase = uut.phase_degrees;
    wire [15:0] sym_count = uut.symbol_count;
    wire [26:0] timer = uut.symbol_timer;
    wire [26:0] threshold = uut.threshold;
    wire I_bit = led_symbol[3];
    wire Q_bit = led_symbol[2];
    
    //==========================================================================
    // Symbol Counter and Statistics
    //==========================================================================
    integer symbols_generated;
    integer phase_45_count, phase_135_count, phase_225_count, phase_315_count;
    integer csv_file;
    
    initial begin
        symbols_generated = 0;
        phase_45_count = 0;
        phase_135_count = 0;
        phase_225_count = 0;
        phase_315_count = 0;
    end
    
    //==========================================================================
    // 🔧 FIX: Count on RAW led_symbol_tick (1 cycle pulse)
    // NOT on led_symbol_ready (which is stretched for 50ms!)
    //==========================================================================
    always @(posedge led_symbol_tick) begin
        #1;  // Small delay for signal stability
        symbols_generated = symbols_generated + 1;
        
        // Update phase statistics
        case (phase)
            9'd45:  phase_45_count  = phase_45_count + 1;
            9'd135: phase_135_count = phase_135_count + 1;
            9'd225: phase_225_count = phase_225_count + 1;
            9'd315: phase_315_count = phase_315_count + 1;
        endcase
        
        // Print selected symbols (first 10, then every 10th)
        if (symbols_generated <= 10 || symbols_generated % 10 == 0) begin
            $display("[%8t ns] Symbol #%-4d | I=%b Q=%b | Phase=%03d° | Out=%5d",
                     $time, symbols_generated, I_bit, Q_bit, phase, qpsk_out);
        end
        
        // Log to CSV
        $fwrite(csv_file, "%0d,%0d,%0d,%0d,%0d\n",
                symbols_generated, I_bit, Q_bit, phase, qpsk_out);
    end
    
    //==========================================================================
    // MAIN TEST SEQUENCE
    //==========================================================================
    initial begin
        // Setup
        $dumpfile("qpsk.vcd");
        $dumpvars(0, tb_qpsk_fpga);
        $dumpvars(1, uut.symbol_timer);      // Explicitly dump timer
        $dumpvars(1, uut.threshold);         // Explicitly dump threshold
        $dumpvars(1, uut.symbol_pulse);      // Explicitly dump pulse
        
        csv_file = $fopen("qpsk_results.csv", "w");
        $fwrite(csv_file, "Symbol,I_bit,Q_bit,Phase_deg,QPSK_Out\n");
        
        $display("\n╔═══════════════════════════════════════════════════════╗");
        $display("║  QPSK Modulator Test - Spartan-7 XC7S50-CSG324A     ║");
        $display("║  Clock: 100 MHz | Symbol Rate: 31.25 ksps            ║");
        $display("╚═══════════════════════════════════════════════════════╝\n");
        
        //----------------------------------------------------------------------
        // Initialize signals at time 0
        //----------------------------------------------------------------------
        test_mode = 0;  // Fast mode (31.25 ksps)
        reset = 1;      // Hold reset
        
        $display("⏱  Time 0ns: Signals initialized");
        $display("   test_mode = %b (0=Fast 31.25ksps, 1=Slow 1Hz)", test_mode);
        $display("   reset = %b (asserted)\n", reset);
        
        //----------------------------------------------------------------------
        // Release reset after exactly 200ns
        //----------------------------------------------------------------------
        #200;
        reset = 0;
        
        $display("⏱  Time %0tns: Reset released", $time);
        
        // Verify timing
        if ($time != 200) begin
            $display("   ✗ ERROR: Expected 200ns, got %0t!", $time);
            $finish;
        end else begin
            $display("   ✓ Timing correct: 200ns\n");
        end
        
        //----------------------------------------------------------------------
        // Wait 100ns for stabilization
        //----------------------------------------------------------------------
        #100;
        
        $display("⏱  Time %0tns: System stabilized", $time);
        $display("   Threshold = %0d (expected 3200)", threshold);
        $display("   Timer = %0d", timer);
        $display("   Symbol count = %0d\n", sym_count);
        
        if (threshold != 3200) begin
            $display("   ✗ ERROR: Threshold wrong! Got %0d", threshold);
            $finish;
        end
        
        //----------------------------------------------------------------------
        // Run SHORT test first: 100µs to verify rate
        //----------------------------------------------------------------------
        $display("╔═══════════════════════════════════════════════════════╗");
        $display("║  TEST 1: 100µs @ 31.25 ksps (expect ~3 symbols)      ║");
        $display("╚═══════════════════════════════════════════════════════╝\n");
        
        #100000;  // 100µs
        
        $display("\n⏱  After 100µs: %0d symbols generated", symbols_generated);
        if (symbols_generated >= 2 && symbols_generated <= 4) begin
            $display("   ✓ Rate looks correct!\n");
        end else begin
            $display("   ✗ Rate WRONG! Expected 2-4, got %0d", symbols_generated);
            $display("   Timer = %0d, Threshold = %0d\n", timer, threshold);
        end
        
        //----------------------------------------------------------------------
        // Continue to 2ms total
        //----------------------------------------------------------------------
        $display("╔═══════════════════════════════════════════════════════╗");
        $display("║  TEST 2: Continue to 2ms (expect 62-63 total)        ║");
        $display("╚═══════════════════════════════════════════════════════╝\n");
        
        #1900000;  // Continue to 2ms total (2000000 - 100000 already run)
        
        //----------------------------------------------------------------------
        // Results
        //----------------------------------------------------------------------
        $display("\n╔═══════════════════════════════════════════════════════╗");
        $display("║  RESULTS                                              ║");
        $display("╠═══════════════════════════════════════════════════════╣");
        $display("║  Simulation time:  2.0 ms                             ║");
        $display("║  Symbols generated: %-3d (expected 62-63)              ║", symbols_generated);
        $display("║  Symbol rate: %.2f ksps                               ║", symbols_generated / 2.0);
        $display("║                                                       ║");
        $display("║  Phase Distribution:                                  ║");
        
        if (symbols_generated > 0) begin
            $display("║    45° (11): %3d (%5.1f%%)                             ║",
                     phase_45_count, 100.0*phase_45_count/symbols_generated);
            $display("║   135° (01): %3d (%5.1f%%)                             ║",
                     phase_135_count, 100.0*phase_135_count/symbols_generated);
            $display("║   225° (00): %3d (%5.1f%%)                             ║",
                     phase_225_count, 100.0*phase_225_count/symbols_generated);
            $display("║   315° (10): %3d (%5.1f%%)                             ║",
                     phase_315_count, 100.0*phase_315_count/symbols_generated);
        end else begin
            $display("║    45° (11):   0 (0.0%%)                              ║");
            $display("║   135° (01):   0 (0.0%%)                              ║");
            $display("║   225° (00):   0 (0.0%%)                              ║");
            $display("║   315° (10):   0 (0.0%%)                              ║");
        end
        
        $display("╠═══════════════════════════════════════════════════════╣");
        
        //----------------------------------------------------------------------
        // Pass/Fail
        //----------------------------------------------------------------------
        if (symbols_generated >= 60 && symbols_generated <= 65) begin
            if (phase_45_count > 0 && phase_135_count > 0 &&
                phase_225_count > 0 && phase_315_count > 0) begin
                $display("║  ✓✓✓ ALL TESTS PASSED ✓✓✓                         ║");
                $display("║  Symbol rate: 31.25 ksps ✓                        ║");
                $display("║  All 4 phases present ✓                           ║");
            end else begin
                $display("║  ⚠ PARTIAL: Correct rate but missing phases      ║");
                $display("║  This might be OK due to randomness               ║");
            end
        end else begin
            $display("║  ✗ FAIL: Wrong symbol count                          ║");
            $display("║  Expected: 62-63 symbols                             ║");
            $display("║  Got:      %-3d symbols                               ║", symbols_generated);
            $display("║  Actual rate: %.2f ksps                              ║", symbols_generated / 2.0);
            $display("║                                                       ║");
            $display("║  Debug info:                                          ║");
            $display("║    Final timer: %0d                                    ║", timer);
            $display("║    Threshold: %0d                                      ║", threshold);
            $display("║    Internal count: %0d                                 ║", sym_count);
        end
        
        $display("╚═══════════════════════════════════════════════════════╝\n");
        
        //----------------------------------------------------------------------
        // Continue to 50ms for full test
        //----------------------------------------------------------------------
        $display("╔═══════════════════════════════════════════════════════╗");
        $display("║  TEST 3: Full 50ms run (expect ~1562 symbols)        ║");
        $display("╚═══════════════════════════════════════════════════════╝\n");
        
        #48000000;  // Continue to 50ms total
        
        $display("\n⏱  After 50ms: %0d symbols generated", symbols_generated);
        $display("   Expected: ~1562 symbols (31.25 ksps × 50ms)");
        
        if (symbols_generated >= 1550 && symbols_generated <= 1575) begin
            $display("   ✓✓✓ 50ms TEST PASSED ✓✓✓\n");
        end else begin
            $display("   ✗ 50ms count off. Actual rate: %.2f ksps\n", 
                     symbols_generated / 50.0);
        end
        
        //----------------------------------------------------------------------
        // Cleanup
        //----------------------------------------------------------------------
        $fclose(csv_file);
        $display("✓ Data saved to qpsk_results.csv");
        $display("✓ Waveforms saved to qpsk.vcd\n");
        $finish;
    end
    
    //==========================================================================
    // Safety Timeout
    //==========================================================================
    initial begin
        #55000000;  // 55ms timeout
        $display("\n✗ TIMEOUT after 55ms");
        $display("Symbols generated: %0d", symbols_generated);
        $fclose(csv_file);
        $finish;
    end

endmodule

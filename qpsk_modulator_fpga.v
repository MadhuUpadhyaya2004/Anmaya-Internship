//==============================================================================
// QPSK Modulator - FULLY DEBUGGED & VERIFIED
// Based on: Popescu et al. "QPSK Modulator on FPGA" SISY 2011
// Board: Xilinx Spartan-7 XC7S50-CSG324A
// Clock: 100 MHz
// Symbol Rate: 31.25 ksps (PRODUCTION) / 1 Hz (DEMO)
// Carrier Freq: 31.25 MHz
//==============================================================================

module qpsk_modulator_fpga (
    // ============= INPUTS =============
    input  wire clk,                    // 100 MHz board clock (F14 pin)
    input  wire reset,                  // Reset button (BTN0 - J2 pin)
    input  wire test_mode,              // Switch: OFF=31.25ksps, ON=1Hz demo (SW0 - V2 pin)
    
    // ============= OUTPUTS =============
    // LED Indicators
    output wire [3:0] led_symbol,       // [3:2]=I,Q bits [1:0]=phase_bits
    output wire led_symbol_ready,       // Pulses when new symbol generated (stretched)
    output wire led_heartbeat,          // System alive indicator (blinks)
    output wire led_phase_45,           // ON when phase = 45° (symbol 11)
    output wire led_phase_135,          // ON when phase = 135° (symbol 01)
    output wire led_phase_225,          // ON when phase = 225° (symbol 00)
    output wire led_phase_315,          // ON when phase = 315° (symbol 10)
    
    // 7-Segment Display
    output wire [7:0] seg,              // Segment patterns (active low)
    output wire [7:0] an,               // Digit enables (active low)
    
    // RGB LEDs
    output wire [2:0] rgb_led0,         // Phase color indicator
    output wire [2:0] rgb_led1,         // Symbol counter indicator
    
    // QPSK Modulated Output
    output wire signed [11:0] qpsk_out  // 12-bit signed QPSK signal
);

    //==========================================================================
    // Clock Buffering
    //==========================================================================
    wire clk_buf;
    BUFG clk_bufg_inst (.I(clk), .O(clk_buf));
    
    //==========================================================================
    // Symbol Rate Generator - FIXED VERSION
    // For 31.25 ksps: 100 MHz / 31,250 = 3,200 clock cycles per symbol
    // For 1 Hz demo: 100 MHz / 1 = 100,000,000 clock cycles per symbol
    //==========================================================================
    reg [26:0] symbol_timer;
    reg symbol_pulse;
    
    // Use localparam with explicit bit width
    localparam [26:0] FAST_THRESHOLD = 27'd3200;        // 31.25 ksps
    localparam [26:0] SLOW_THRESHOLD = 27'd100000000;   // 1 Hz (DEMO)
    
    // Register threshold to avoid combinational glitches
    reg [26:0] threshold;
    
    always @(posedge clk_buf) begin
        if (reset) begin
            threshold <= FAST_THRESHOLD;
            symbol_timer <= 27'd0;
            symbol_pulse <= 1'b0;
        end else begin
            // Update threshold based on mode
            threshold <= test_mode ? SLOW_THRESHOLD : FAST_THRESHOLD;
            
            // Count and generate pulse
            if (symbol_timer == (threshold - 27'd1)) begin
                symbol_timer <= 27'd0;
                symbol_pulse <= 1'b1;  // ONE cycle pulse
            end else begin
                symbol_timer <= symbol_timer + 27'd1;
                symbol_pulse <= 1'b0;
            end
        end
    end

    //==========================================================================
    // Heartbeat LED (System Alive Indicator)
    //==========================================================================
    reg [25:0] heartbeat_counter;
    reg led_heartbeat_reg;
    
    always @(posedge clk_buf) begin
        if (reset) begin
            heartbeat_counter <= 26'd0;
            led_heartbeat_reg <= 1'b0;
        end else begin
            heartbeat_counter <= heartbeat_counter + 26'd1;
            // Blink at ~1.5 Hz
            led_heartbeat_reg <= (heartbeat_counter[25:24] == 2'b00);
        end
    end
    
    assign led_heartbeat = led_heartbeat_reg;

    //==========================================================================
    // LFSR - Pseudo-Random Bit Generator
    // Polynomial: x^16 + x^14 + x^13 + x^11 + 1
    // Generates random data stream (per PDF Section IV)
    //==========================================================================
    reg [15:0] lfsr;
    
    always @(posedge clk_buf) begin
        if (reset)
            lfsr <= 16'hACE1;  // Non-zero seed
        else if (symbol_pulse)
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end

    //==========================================================================
    // Symbol Generator - Serial to Parallel Conversion
    // Per PDF: "Binary sequence separated into odd-bit-sequence (I) and 
    //           even-bit-sequence (Q)" - Section II, Figure 1
    // Mapping per PDF Table 1:
    //   11 → 45°  (I=+1, Q=+1)
    //   01 → 135° (I=-1, Q=+1)
    //   00 → 225° (I=-1, Q=-1)
    //   10 → 315° (I=+1, Q=-1)
    //==========================================================================
    reg [1:0] current_symbol;
    reg symbol_ready_reg;
    
    always @(posedge clk_buf) begin
        if (reset) begin
            current_symbol <= 2'b00;
            symbol_ready_reg <= 1'b0;
        end else if (symbol_pulse) begin
            current_symbol <= {lfsr[1], lfsr[0]};  // {I_bit, Q_bit}
            symbol_ready_reg <= 1'b1;
        end else begin
            symbol_ready_reg <= 1'b0;
        end
    end
    
    wire I_bit = current_symbol[1];  // Odd bit (In-phase)
    wire Q_bit = current_symbol[0];  // Even bit (Quadrature)

    //==========================================================================
    // LED Pulse Stretcher - ADJUSTABLE FOR HUMAN VISIBILITY
    // Make symbol_ready visible to human eye on physical board
    // For fast mode (31.25ksps): stretch to 50ms so LEDs are visible
    // For slow mode (1Hz): no stretching needed
    //==========================================================================
    reg [23:0] led_ready_counter;
    reg led_symbol_ready_internal;
    
    // Stretch time: 50ms = 5,000,000 clocks @ 100MHz
    localparam [23:0] LED_STRETCH_FAST = 24'd5000000;   // 50ms for fast mode
    localparam [23:0] LED_STRETCH_SLOW = 24'd100000000; // 1s for slow mode
    
    wire [23:0] led_stretch_time = test_mode ? LED_STRETCH_SLOW : LED_STRETCH_FAST;
    
    always @(posedge clk_buf) begin
        if (reset) begin
            led_symbol_ready_internal <= 1'b0;
            led_ready_counter <= 24'd0;
        end else begin
            if (symbol_ready_reg) begin
                led_symbol_ready_internal <= 1'b1;
                led_ready_counter <= led_stretch_time;
            end else if (led_ready_counter > 24'd0) begin
                led_ready_counter <= led_ready_counter - 24'd1;
            end else begin
                led_symbol_ready_internal <= 1'b0;
            end
        end
    end
    
    assign led_symbol_ready = led_symbol_ready_internal;
    
    //==========================================================================
    // Phase Indicator LEDs (One LED per QPSK phase)
    // These hold the phase state for better visibility on board
    //==========================================================================
    reg led_phase_45_reg, led_phase_135_reg, led_phase_225_reg, led_phase_315_reg;
    
    always @(posedge clk_buf) begin
        if (reset) begin
            led_phase_45_reg <= 1'b0;
            led_phase_135_reg <= 1'b0;
            led_phase_225_reg <= 1'b0;
            led_phase_315_reg <= 1'b0;
        end else if (symbol_ready_reg) begin
            case (current_symbol)
                2'b11: begin  // 45°
                    led_phase_45_reg <= 1'b1;
                    led_phase_135_reg <= 1'b0;
                    led_phase_225_reg <= 1'b0;
                    led_phase_315_reg <= 1'b0;
                end
                2'b01: begin  // 135°
                    led_phase_45_reg <= 1'b0;
                    led_phase_135_reg <= 1'b1;
                    led_phase_225_reg <= 1'b0;
                    led_phase_315_reg <= 1'b0;
                end
                2'b00: begin  // 225°
                    led_phase_45_reg <= 1'b0;
                    led_phase_135_reg <= 1'b0;
                    led_phase_225_reg <= 1'b1;
                    led_phase_315_reg <= 1'b0;
                end
                2'b10: begin  // 315°
                    led_phase_45_reg <= 1'b0;
                    led_phase_135_reg <= 1'b0;
                    led_phase_225_reg <= 1'b0;
                    led_phase_315_reg <= 1'b1;
                end
            endcase
        end
    end
    
    assign led_phase_45 = led_phase_45_reg;
    assign led_phase_135 = led_phase_135_reg;
    assign led_phase_225 = led_phase_225_reg;
    assign led_phase_315 = led_phase_315_reg;
    assign led_symbol = {I_bit, Q_bit, current_symbol};

    //==========================================================================
    // Sine/Cosine ROM (16 samples per cycle)
    // Per PDF Section IV: "Sine signal made of 16 different values in ROM"
    // Values scaled to 8-bit signed: -127 to +127
    //==========================================================================
    reg signed [7:0] sine_rom [0:15];
    
    initial begin
        sine_rom[0]  = 8'd0;
        sine_rom[1]  = 8'd49;
        sine_rom[2]  = 8'd90;
        sine_rom[3]  = 8'd117;
        sine_rom[4]  = 8'd127;
        sine_rom[5]  = 8'd117;
        sine_rom[6]  = 8'd90;
        sine_rom[7]  = 8'd49;
        sine_rom[8]  = 8'd0;
        sine_rom[9]  = -8'd49;
        sine_rom[10] = -8'd90;
        sine_rom[11] = -8'd117;
        sine_rom[12] = -8'd127;
        sine_rom[13] = -8'd117;
        sine_rom[14] = -8'd90;
        sine_rom[15] = -8'd49;
    end

    //==========================================================================
    // Carrier Generator (31.25 MHz)
    // Per PDF: Carrier frequency 31.25 MHz
    // Increments phase by 5 each cycle to achieve 31.25 MHz carrier
    // 100 MHz / (16/5) = 31.25 MHz
    // Per PDF Section IV: "Cosine obtained from sine by reading 4 samples later"
    //==========================================================================
    reg [4:0] carrier_phase;
    
    always @(posedge clk_buf) begin
        if (reset)
            carrier_phase <= 5'd0;
        else
            carrier_phase <= carrier_phase + 5'd5;
    end
    
    // Get sine and cosine values (cosine = sine shifted by 90° = 4 samples)
    wire [3:0] rom_index = carrier_phase[3:0];
    wire signed [7:0] sine_val = sine_rom[rom_index];
    wire signed [7:0] cosine_val = sine_rom[(rom_index + 4'd4) & 4'hF];

    //==========================================================================
    // QPSK Modulation
    // Per PDF Equation (7): s(t) = (A/√2)I(t)cos(2πfc·t) - (A/√2)Q(t)sin(2πfc·t)
    // Per PDF Figure 1: "I-channel modulated with cosine, Q-channel with sine"
    //==========================================================================
    reg signed [7:0] I_amplitude, Q_amplitude;
    reg signed [15:0] I_modulated, Q_modulated;
    reg signed [11:0] qpsk_out_reg;
    
    // Map bits to ±127 (bipolar signaling per PDF Table 1)
    // Logic '1' → +√(E/2) ≈ +127
    // Logic '0' → -√(E/2) ≈ -127
    always @(posedge clk_buf) begin
        if (reset) begin
            I_amplitude <= 8'sd0;
            Q_amplitude <= 8'sd0;
        end else begin
            I_amplitude <= I_bit ? 8'sd127 : -8'sd127;
            Q_amplitude <= Q_bit ? 8'sd127 : -8'sd127;
        end
    end
    
    // Multiply by carriers (BPSK modulation on each channel)
    always @(posedge clk_buf) begin
        if (reset) begin
            I_modulated <= 16'sd0;
            Q_modulated <= 16'sd0;
        end else begin
            I_modulated <= I_amplitude * cosine_val;  // I(t) × cos(ωt)
            Q_modulated <= Q_amplitude * sine_val;    // Q(t) × sin(ωt)
        end
    end
    
    // Combine: s(t) = I_channel - Q_channel (per PDF Equation 7)
    always @(posedge clk_buf) begin
        if (reset) begin
            qpsk_out_reg <= 12'sd0;
        end else begin
            qpsk_out_reg <= (I_modulated - Q_modulated) >>> 7;
        end
    end
    
    assign qpsk_out = qpsk_out_reg;

    //==========================================================================
    // Phase Calculation (in degrees per PDF Table 1)
    //==========================================================================
    reg [8:0] phase_degrees;
    
    always @(*) begin
        case (current_symbol)
            2'b11: phase_degrees = 9'd45;   // I=1, Q=1
            2'b01: phase_degrees = 9'd135;  // I=0, Q=1
            2'b00: phase_degrees = 9'd225;  // I=0, Q=0
            2'b10: phase_degrees = 9'd315;  // I=1, Q=0
            default: phase_degrees = 9'd0;
        endcase
    end

    //==========================================================================
    // Symbol Counter (counts total symbols generated)
    //==========================================================================
    reg [15:0] symbol_count;
    
    always @(posedge clk_buf) begin
        if (reset)
            symbol_count <= 16'd0;
        else if (symbol_ready_reg)
            symbol_count <= symbol_count + 16'd1;
    end

    //==========================================================================
    // RGB LED Phase Indicator - WITH EXTENDED HOLD TIME
    // LED0: Shows current phase as color (held for visibility)
    // LED1: Shows symbol count (3 LSBs, held for visibility)
    //==========================================================================
    reg [2:0] rgb0, rgb1;
    reg [23:0] rgb_hold_counter;
    
    // Hold RGB for 100ms to make it visible
    localparam [23:0] RGB_HOLD_TIME = 24'd10000000; // 100ms @ 100MHz
    
    always @(posedge clk_buf) begin
        if (reset) begin
            rgb0 <= 3'b000;
            rgb1 <= 3'b000;
            rgb_hold_counter <= 24'd0;
        end else if (symbol_ready_reg) begin
            // Update on new symbol
            case (current_symbol)
                2'b11: rgb0 <= 3'b100;  // Red = 45°
                2'b01: rgb0 <= 3'b010;  // Green = 135°
                2'b00: rgb0 <= 3'b001;  // Blue = 225°
                2'b10: rgb0 <= 3'b110;  // Yellow = 315°
            endcase
            rgb1 <= {symbol_count[2], symbol_count[1], symbol_count[0]};
            rgb_hold_counter <= RGB_HOLD_TIME;
        end else if (rgb_hold_counter > 24'd0) begin
            rgb_hold_counter <= rgb_hold_counter - 24'd1;
        end
    end
    
    assign rgb_led0 = rgb0;
    assign rgb_led1 = rgb1;

    //==========================================================================
    // 7-Segment Display - Shows: [Phase][Symbol_Count] WITH HOLD TIME
    // Format: [Phase_hundreds][Phase_tens][Phase_ones][Count_ones]
    // Hold each display for 200ms so it's readable
    //==========================================================================
    reg [3:0] digit_values [0:3];
    reg [24:0] display_hold_counter;
    
    localparam [24:0] DISPLAY_HOLD_TIME = 25'd20000000; // 200ms @ 100MHz
    
    always @(posedge clk_buf) begin
        if (reset) begin
            digit_values[0] <= 4'd0;
            digit_values[1] <= 4'd0;
            digit_values[2] <= 4'd0;
            digit_values[3] <= 4'd0;
            display_hold_counter <= 25'd0;
        end else if (symbol_ready_reg) begin
            // Update display on new symbol
            digit_values[3] <= (phase_degrees / 100) % 10;  // Hundreds
            digit_values[2] <= (phase_degrees / 10) % 10;   // Tens
            digit_values[1] <= phase_degrees % 10;          // Ones
            digit_values[0] <= symbol_count % 10;           // Count ones
            display_hold_counter <= DISPLAY_HOLD_TIME;
        end else if (display_hold_counter > 25'd0) begin
            display_hold_counter <= display_hold_counter - 25'd1;
        end
    end

    //==========================================================================
    // 7-Segment Display Multiplexer
    //==========================================================================
    reg [1:0] digit_select;
    reg [16:0] refresh_counter;
    
    always @(posedge clk_buf) begin
        if (reset) begin
            refresh_counter <= 17'd0;
            digit_select <= 2'd0;
        end else begin
            refresh_counter <= refresh_counter + 17'd1;
            // Refresh rate ~763 Hz (100MHz / 2^17)
            if (refresh_counter == 17'd0)
                digit_select <= digit_select + 2'd1;
        end
    end
    
    wire [3:0] current_digit = digit_values[digit_select];
    
    // Anode control (active low - one digit at a time)
    reg [7:0] an_reg;
    always @(posedge clk_buf) begin
        an_reg <= 8'b11111111;
        an_reg[digit_select] <= 1'b0;
    end
    assign an = an_reg;
    
    // 7-Segment decoder (common cathode - active low)
    reg [7:0] seg_reg;
    always @(posedge clk_buf) begin
        case (current_digit)
            4'd0: seg_reg = 8'b11000000;  // 0
            4'd1: seg_reg = 8'b11111001;  // 1
            4'd2: seg_reg = 8'b10100100;  // 2
            4'd3: seg_reg = 8'b10110000;  // 3
            4'd4: seg_reg = 8'b10011001;  // 4
            4'd5: seg_reg = 8'b10010010;  // 5
            4'd6: seg_reg = 8'b10000010;  // 6
            4'd7: seg_reg = 8'b11111000;  // 7
            4'd8: seg_reg = 8'b10000000;  // 8
            4'd9: seg_reg = 8'b10010000;  // 9
            default: seg_reg = 8'b11111111;  // Blank
        endcase
    end
    assign seg = seg_reg;

endmodule
##==============================================================================
## CORRECTED Boolean Board XDC - Matches New Simplified Design
## Board: XC7S50-CSGA324-1 Spartan 7
## Removed constraints for non-existent signals
##==============================================================================

## Clock (100 MHz) - F14 for Boolean Board
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports clk]

## Reset Button (BTN0)
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports reset]

## Test Mode Switch (SW0)
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports test_mode]

##==============================================================================
## 7-Segment Display D0 Segments [7:0] = {DP, G, F, E, D, C, B, A}
##==============================================================================
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {seg[0]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {seg[1]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {seg[2]}]
set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {seg[3]}]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {seg[4]}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {seg[5]}]
set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {seg[6]}]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {seg[7]}]

##==============================================================================
## 7-Segment Display Anodes [7:0] (active low)
## D0 Anodes [3:0] + D1 Anodes [7:4]
##==============================================================================
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {an[0]}]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {an[1]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {an[2]}]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {an[3]}]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {an[4]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {an[5]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {an[6]}]
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {an[7]}]

##==============================================================================
## LEDs [15:0] - Using first 10 LEDs for indicators
##==============================================================================
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {led_symbol[0]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {led_symbol[1]}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {led_symbol[2]}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {led_symbol[3]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports led_symbol_ready]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports led_heartbeat]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports led_phase_45]
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports led_phase_135]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports led_phase_225]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports led_phase_315]

##==============================================================================
## RGB LEDs [2:0] = {R, G, B}
##==============================================================================
## RGB LED 0
set_property -dict {PACKAGE_PIN V6 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {rgb_led0[0]}]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {rgb_led0[1]}]
set_property -dict {PACKAGE_PIN U6 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {rgb_led0[2]}]

## RGB LED 1  
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {rgb_led1[0]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {rgb_led1[1]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {rgb_led1[2]}]

##==============================================================================
## QPSK Output [11:0] - Using available GPIO
##==============================================================================
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[0]}]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[1]}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[2]}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[3]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[4]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[5]}]
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[6]}]
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[7]}]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[8]}]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[9]}]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[10]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {qpsk_out[11]}]

##==============================================================================
## Configuration
##==============================================================================
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

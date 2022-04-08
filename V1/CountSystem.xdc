## Clock signal 100 MHz
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports {CLK}];
create_clock -add -name clk_pin -period 10 -waveform {0 5} [get_ports {CLK}];

## Buttons
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {UP}];

#7 segment display
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports {SEG[0]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {SEG[1]}]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {SEG[2]}]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports {SEG[3]}]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports {SEG[4]}]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {SEG[5]}]
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports {SEG[6]}]
set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS33} [get_ports {SEG[7]}]

set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports {MUX[0]}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {MUX[1]}]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {MUX[2]}]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {MUX[3]}]


## Clock signal 100 MHz
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports { CLK }];
create_clock -add -name clk_pin -period 10 -waveform {0 5} [get_ports { CLK }];

## LEDs
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { LD0 }];
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports { LD1 }];

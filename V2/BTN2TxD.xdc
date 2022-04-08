## Clock signal 100 MHz
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports { Takt }];
create_clock -add -name sys_clk_pin -period 10 -waveform {0 5} [get_ports {Takt}];

## Buttons
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { BTN[0] }];
set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports { BTN[1] }];
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports { BTN[2] }];
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports { BTN[3] }];

## UART
set_property -dict { PACKAGE_PIN A17 IOSTANDARD LVCMOS33 } [get_ports { TXD }];




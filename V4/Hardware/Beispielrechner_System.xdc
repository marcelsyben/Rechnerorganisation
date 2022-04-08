# Spezifikation des Eingangstaktes
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports { CLKIN }];
create_clock -add -name clkin_pin -period 10 -waveform { 0 5 } [get_ports { CLKIN }];

# Serial Debug Interface (SDI)
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports { SDI_TXD }];
set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports { SDI_RXD }];

# Taster
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports {PINS[0]}];
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports {PINS[1]}];
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports {PINS[2]}];

# TODO: Signale fuer die Siebensegment-Anzeige ergaenzen (V4)

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

# TODO: Signale fuer die Serielle Schnittstelle ergaenzen (V5)


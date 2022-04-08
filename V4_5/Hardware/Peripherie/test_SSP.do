---------------------------------------------------------------------------------------------------
-- Kommandodatei zur Testbench der Komponente "SSP"
-- Bernhard Lang
-- (c) Hochschule Osnabrueck
---------------------------------------------------------------------------------------------------
# Benoetigte Dateien uebersetzen
vcom Siebensegment_Anzeige.vhd
vcom SSP.vhd
vcom wb_test_pack_v2_0.vhd
vcom SSP_testbench.vhd

# Simulator starten
vsim -voptargs=+acc work.SSP_testbench

# Breite der Namensspalte
configure wave -namecolwidth 128
# Breite der Wertespalte
configure wave -valuecolwidth 128
# Angezeigte Pfadelemente
configure wave -signalnamewidth 1
# sim: nicht anzeigen
configure wave -datasetprefix 0
# Einheit der Zeitachse
configure wave -timelineunits ns

# Signale hinzufuegen
add wave              /SSP_testbench/CLK
add wave              /SSP_testbench/RST

add wave -divider "Externe Signale"
add wave              /SSP_testbench/Seg
add wave              /SSP_testbench/Mux
add wave              /SSP_testbench/Anzeige

add wave -divider "Wishbone Bus"
add wave              /SSP_testbench/STB
add wave              /SSP_testbench/WE
add wave -hexadecimal /SSP_testbench/ADR
add wave -hexadecimal /SSP_testbench/DAT
add wave -hexadecimal /SSP_testbench/ACK
add wave -hexadecimal /SSP_testbench/SSP_DAT

add wave -divider "Interne Signale"
add wave -hexadecimal /SSP_testbench/uut/wert0
add wave -hexadecimal /SSP_testbench/uut/wert1
add wave -hexadecimal /SSP_testbench/uut/wert2
add wave -hexadecimal /SSP_testbench/uut/wert3

# Simulation ausfuehren
run 200 ns

# Alles Anzeigen
wave zoom full

# Benoetigte Dateien uebersetzen
vcom -work work UART_Empfaenger.vhd
vcom -work work UART_Sender.vhd
vcom -work work UART.vhd
vcom wb_test_pack_v2_0.vhd
vcom -work work UART_testbench.vhd

# Simulator starten
vsim -voptargs=+acc -t ns work.uart_testbench

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
add wave              /uart_testbench/CLK
add wave              /uart_testbench/RST

add wave -divider "Wishbone Bus"
add wave              /uart_testbench/STB
add wave              /uart_testbench/WE
add wave              /uart_testbench/SEL
add wave -hexadecimal /uart_testbench/ADR
add wave -hexadecimal /uart_testbench/DAT
add wave              /uart_testbench/ACK
add wave -hexadecimal /uart_testbench/UART_DAT

add wave -divider "Decodierung"
add wave sim:/uart_testbench/uut/STB_TxD
add wave sim:/uart_testbench/uut/STB_K
add wave sim:/uart_testbench/uut/RD_Stat
add wave sim:/uart_testbench/uut/RD_RxD
add wave sim:/uart_testbench/uut/RD_Sel

add wave -divider "Sendeseite"
add wave              /uart_testbench/TxD
add wave              /uart_testbench/Ir_TxD
add wave              /uart_testbench/uut/STB_TxD
add wave              /uart_testbench/uut/TxD_IrEn

add wave -divider "Empfangsseite"
add wave              /uart_testbench/RxD
add wave              /uart_testbench/Ir_RxD
add wave -hexadecimal /uart_testbench/uut/Empfaenger_OK
add wave -hexadecimal /uart_testbench/uut/Empfaenger_Dout
add wave              /uart_testbench/uut/Empfaenger_Err
add wave              /uart_testbench/uut/RxD_OK
add wave              /uart_testbench/uut/RxD_Err

# Simulation ausfuehren
run 180 us

# Alles Anzeigen
wave zoom full


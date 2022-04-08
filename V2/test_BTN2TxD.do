vcom -work work DF_Fifo.vhd
vcom -work work UART_Sender.vhd
vcom -work work BTN2TxD.vhd
vcom -work work BTN2TxD_tb.vhd

vsim -voptargs=+acc work.BTN2TxD_tb

configure wave -namecolwidth 128
configure wave -valuecolwidth 64
configure wave -signalnamewidth 1
configure wave -datasetprefix 0
configure wave -timelineunits us

add wave -divider "Testbench-Signale"
add wave               /btn2txd_tb/Takt
add wave -radix binary /btn2txd_tb/BTN
add wave               /btn2txd_tb/TxD
add wave -radix ascii  /btn2txd_tb/Empfangen_char

add wave -divider "BTN2TxD-Signale"
add wave -radix binary /btn2txd_tb/DUT/BTN_neu
add wave -radix binary /btn2txd_tb/DUT/BTN_alt
add wave               /btn2txd_tb/DUT/Ungleich
add wave -radix ascii  /btn2txd_tb/DUT/BTN_ASCII
add wave               /btn2txd_tb/DUT/Senden
add wave -radix ascii  /btn2txd_tb/DUT/Wert
add wave               /btn2txd_tb/DUT/OK

add wave -divider "UART_Sender-Signale"
add wave -radix binary /btn2txd_tb/DUT/Sender/Starte
add wave -radix binary /btn2txd_tb/DUT/Sender/Schiebe
add wave -radix binary /btn2txd_tb/DUT/Sender/Fertig
add wave -radix binary /btn2txd_tb/DUT/Sender/Bitende

run 1700 us
wave zoom full

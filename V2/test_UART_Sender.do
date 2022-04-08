vcom UART_Sender.vhd
vcom UART_Sender_tb.vhd

vsim -voptargs=+acc work.UART_Sender_tb 

configure wave -namecolwidth 128
configure wave -valuecolwidth 64
configure wave -signalnamewidth 1
configure wave -datasetprefix 0
configure wave -timelineunits us

add wave /UART_Sender_tb/ok
add wave /UART_Sender_tb/reset
add wave /UART_Sender_tb/senden
add wave /UART_Sender_tb/takt
add wave /UART_Sender_tb/txd
add wave /UART_Sender_tb/wert
add wave /UART_Sender_tb/dut/steuerwerk/zustand
add wave /UART_Sender_tb/dut/bitende
add wave /UART_Sender_tb/dut/fertig
add wave /UART_Sender_tb/dut/schiebe
add wave /UART_Sender_tb/dut/starte

run 1500 us


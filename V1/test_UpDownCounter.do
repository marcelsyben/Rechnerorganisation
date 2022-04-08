if {![file exists work]} { 
	vlib work 
}

vcom UpDownCounter.vhd
vcom UpDownCounter_tb.vhd

vsim -voptargs=+acc work.updowncounter_tb

configure wave -namecolwidth 173
configure wave -valuecolwidth 106
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0

add wave           /updowncounter_tb/Clk
add wave           /updowncounter_tb/En
add wave           /updowncounter_tb/Up
add wave -unsigned /updowncounter_tb/Q
add wave           /updowncounter_tb/TC

run 200 ns
wave zoom full

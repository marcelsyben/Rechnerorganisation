# Benoetigte Dateien uebersetzen
vcom Prozessor/df_serial_in_v1_0.vhd
vcom Prozessor/df_serial_out_v1_0.vhd
vcom Prozessor/df_wishbone_interface.vhd
vcom Prozessor/serial_wishbone_interface.vhd
vcom Prozessor/div.vhd
vcom Prozessor/mult.vhd
vcom Prozessor/wb_arbiter.vhd
vcom Prozessor/txt_util_pack_v1_2.vhd
vcom Prozessor/bsr2_processor_core.vhd
vcom Prozessor/bsr2_processor.vhd
vcom Peripherie/Clocking_sim.vhd

vcom Speicher/intel_hex_pack.vhd
vcom Speicher/Memory.vhd

vcom Peripherie/Timer.vhd

vcom Peripherie/GPIO.vhd

vcom Peripherie/Siebensegment_Anzeige.vhd
vcom Peripherie/SSP.vhd


vcom Beispielrechner_System.vhd
vcom Beispielrechner_System_V4_testbench.vhd

# Simulator starten
vsim -t ns -voptargs=+acc work.Beispielrechner_System_V4_testbench

# Breite der Namensspalte
configure wave -namecolwidth 128
# Breite der Wertespalte
configure wave -valuecolwidth 128
# Angezeigte Pfadelemente
configure wave -signalnamewidth 1
# sim: nicht anzeigen
configure wave -datasetprefix 0
# Einheit der Zeitachse
configure wave -timelineunits ms

# Keine Warnung von der Bibliothek numeric_std
set NumericStdNoWarnings 1

# Signale hinzufuegen
if (1) {
    #add wave             /Beispielrechner_System_V4_testbench/uut/CLK
    add wave              /beispielrechner_system_v4_testbench/START
    add wave              /beispielrechner_system_v4_testbench/STOP
    add wave              /beispielrechner_system_v4_testbench/RESET
	add wave              /Beispielrechner_System_V4_testbench/Anzeige 
}
	
if (1) {
	add wave -divider "Wishbone Bus"
	add wave              /Beispielrechner_System_V4_testbench/uut/STB
	add wave              /Beispielrechner_System_V4_testbench/uut/WE
	add wave              /Beispielrechner_System_V4_testbench/uut/SEL
	add wave -hexadecimal /Beispielrechner_System_V4_testbench/uut/ADR
	add wave -hexadecimal /Beispielrechner_System_V4_testbench/uut/DAT_O
	add wave              /Beispielrechner_System_V4_testbench/uut/ACK
	add wave -hexadecimal /Beispielrechner_System_V4_testbench/uut/DAT_I
}

if (1) {
	add wave -divider "Timer"
	add wave -unsigned /Beispielrechner_System_V4_testbench/UUT/Timer_Inst/Periode
	add wave -unsigned /Beispielrechner_System_V4_testbench/UUT/Timer_Inst/Zaehlerstand
	add wave -unsigned /Beispielrechner_System_V4_testbench/UUT/Timer_Inst/Schwelle
	add wave           /Beispielrechner_System_V4_testbench/UUT/Timer_Inst/IrEn
	add wave           /Beispielrechner_System_V4_testbench/UUT/Timer_Inst/Interrupt_FF
	add wave           /Beispielrechner_System_V4_testbench/UUT/Timer_Inst/IR_Tim
}

if (0) {
	add wave -divider "GPIO"
    add wave              /Beispielrechner_System_V4_testbench/uut/GPIO_STB
    add wave              /Beispielrechner_System_V4_testbench/uut/GPIO_ACK
    add wave              /Beispielrechner_System_V4_testbench/uut/GPIO_DAT
	add wave -hexadecimal /beispielrechner_system_v4_testbench/uut/GPIO_inst/Richtung
	add wave -hexadecimal /beispielrechner_system_v4_testbench/uut/GPIO_inst/Ausgabe
	add wave -hexadecimal /beispielrechner_system_v4_testbench/uut/GPIO_inst/Eingabe
}

if (1) {
	add wave -divider "SSP"
	add wave -hexadecimal /Beispielrechner_System_V4_testbench/uut/SSP_Inst/Wert3
	add wave -hexadecimal /Beispielrechner_System_V4_testbench/uut/SSP_Inst/Wert2
	add wave -hexadecimal /Beispielrechner_System_V4_testbench/uut/SSP_Inst/Wert1
	add wave -hexadecimal /Beispielrechner_System_V4_testbench/uut/SSP_Inst/Wert0
	#add wave sim:/Beispielrechner_System_V4_testbench/SEG 
	#add wave sim:/Beispielrechner_System_V4_testbench/MUX
}

if (1) {
	add wave -divider "RAM"
	add wave -unsigned -label "ms" /Beispielrechner_System_V4_testbench/uut/RAM_Inst/mem(0)
}
	
if (1) {
	add wave -divider "Wichtige Register"
	#add wave -unsigned    -label "\$at"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(1)
	#add wave -unsigned    -label "\$v0"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(2)
	#add wave -unsigned    -label "\$v1"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(3)
	add wave -unsigned    -label "\$a0"   /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(4)
	add wave -unsigned    -label "\$a1"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(5)
	add wave -unsigned    -label "\$a2"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(6)
	add wave -unsigned    -label "\$a3"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(7)
	add wave -unsigned    -label "\$t0"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(8)
	add wave -unsigned    -label "\$t1"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(9)
	#add wave -unsigned    -label "\$t2"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(10)
	#add wave -unsigned    -label "\$t3"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(11)
	#add wave -unsigned    -label "\$t4"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(12)
	#add wave -unsigned    -label "\$t5"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(13)
	#add wave -unsigned    -label "\$t6"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(14)
	#add wave -unsigned    -label "\$t7"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(15)
	add wave -unsigned    -label "\$s0"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(16)
	add wave -unsigned    -label "\$s1"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(17)
	add wave -unsigned    -label "\$s2"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(18)
	add wave -unsigned    -label "\$s3"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(19)
	#add wave -unsigned    -label "\$s4"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(20)
	#add wave -unsigned    -label "\$s5"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(21)
	#add wave -unsigned    -label "\$s6"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(22)
	#add wave -unsigned    -label "\$s7"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(23)
	#add wave -unsigned    -label "\$t8"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(24)
	#add wave -unsigned    -label "\$t9"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(25)
	#add wave -hexadecimal -label "\$k0"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(26)
	#add wave -hexadecimal -label "\$k1"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(27)
	#add wave -hexadecimal -label "\$gp"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(28)
	add wave -hexadecimal -label "\$sp"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(29)
	#add wave -hexadecimal -label "\$fp"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(30)
	add wave -hexadecimal -label "\$ra"  /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/Registers/regs(31)
}

if (1) {
	add wave -divider "Prozessor"
    add wave              /Beispielrechner_System_V4_testbench/uut/Processor_Inst/core/EXL
	add wave              /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/IE
	add wave -hexadecimal /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/EPC
	add wave              /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DataPath/IM2
	add wave              /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/IP2
	add wave -hexadecimal /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/PC
	add wave              /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/ControlUnit/state
	add wave              /Beispielrechner_System_V4_testbench/UUT/processor_inst/core/DissBlock/Diss_Inst
}

# Simulation ausfuehren
run 6500 us



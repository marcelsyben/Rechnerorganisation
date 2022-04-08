@echo off

echo Executing %0

set BITFILE=..\Hardware\Synthese_V3\Synthese_V3.runs\impl_1\Beispielrechner_System_V3.bit
set XILINX=D:\Xilinx\Vivado\2019.2
set VIVADO=%XILINX%\bin\vivado.bat

echo Using bit file %BITFILE%
echo Calling %VIVADO%...

call %VIVADO% -nojournal -nolog -mode batch -source .\program_fpga.tcl -notrace -tclargs .\%BITFILE%

del webtalk*.jou
del webtalk*.log
rmdir .Xil

echo on

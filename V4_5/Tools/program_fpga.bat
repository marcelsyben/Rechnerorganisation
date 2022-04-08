@echo off

echo Executing %0

rem HIER KANN DER PFAD ZUR VIVADO-INSTALLATION ANGEPASST WERDEN
set XILINX=D:\Xilinx\Vivado\2019.2
set BITFILE=..\Hardware\Synthese\Synthese.runs\impl_1\Beispielrechner_System.bit
set VIVADO=%XILINX%\bin\vivado.bat

echo Using bit file %BITFILE%
echo Calling %VIVADO%...

call %VIVADO% -nojournal -nolog -mode batch -source .\program_fpga.tcl -notrace -tclargs .\%BITFILE%

del webtalk*.jou
del webtalk*.log
rmdir .Xil

echo on


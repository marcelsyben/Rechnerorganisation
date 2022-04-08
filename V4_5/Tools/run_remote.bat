@echo off

rem Configuration File
set CONFIG=bsr2-gdb-server.ini

bsr2-gdb-server.exe -r -C %CONFIG%

@echo off
call F:\AMDDesignTools\2025.2\Vivado\settings64.bat
cd /d D:\zizim\Documents\UJN_HW\proj2
vivado -mode batch -source vivado\bpsk\create_project.tcl
echo.
echo Done. Press any key to exit.
pause >nul

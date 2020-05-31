@echo off
if [%1]==[] goto end
:loop
echo Current processed file is: %1
shift
if not [%1]==[] goto loop
:end
pause
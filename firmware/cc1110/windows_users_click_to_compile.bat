@echo off
if not exist "Output"\ (
mkdir Output
)

make
echo Your compiled code should now be in output/minimed_rf.hex, you may now close this window.
pause > nul

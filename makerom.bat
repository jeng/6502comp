@echo off
call build.bat
call dumpbin
call hexdump -C bootrom.bin
echo "done"

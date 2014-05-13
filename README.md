mips32r1_ml605
==============


Run MIPS32 release 1 on ML605.
This is a port of mips32r1.
Original project is
https://github.com/grantea/mips32r1



Main file of this project (src/vhdl/Topv.vhd) is wrapper.
Remove clock manager from Top.v (original) and use alternate clock manager.


I tested in Windows7 64bit and ISE 12.4 .



Place mips32r1 project under non_share folder like below

mips32r1_ml605/
 +- non_share/
     +- mips32r1-master/ (extract zip from grantea/mips32r1)
         +- Documentation/
         +- Hardware/
         +- ...


Generate two binaries

run C:\Xilinx\12.4\ISE_DS\settings64.bat
move to cores
run coregen -p coregen.cgp -b BRAM_592KB_2R.xco
run coregen -p coregen.cgp -b clk_200_33_66.xco


And generate .bit file in ISE.


For your information, I can compile and run toolchain included in mips32r1
in CentOS 6.5 64bit.


All files in this project is licensed under the GNU LGPL same as mips32r1.

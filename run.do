#vlog -sv *.sv

if {![file exists work]} {
    vlib work
}

vlog axi_if.sv
vlog test_pkg.sv
vlog top.sv

#vopt top -o opt -debug -assertdebug -designfile design.bin


vopt top -o opt -debug,livesim -assertdebug -designfile design.bin

vsim opt -assertdebug -visualizer -qwavedb=+signal+assertion=atv


#+assertion=atv 

#vsim opt -assertdebug -visualizer -qwavedb=+signal+class+transaction+assertion=atv 
#+classdynarray=queue
#+assertion=pass,atv 

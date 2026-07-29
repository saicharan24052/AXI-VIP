#vlog -sv *.sv

if {![file exists work]} {
    vlib work
}

vlog axi_if.sv
vlog test_pkg.sv
vlog top.sv

#vopt -o opt top -debug -designfile design.bin

vopt top -o opt -debug -assertdebug -designfile design.bin

vsim -c -qwavedb=+signal+class+transaction+assertion=atv opt -do "run -all; quit -f"  

visualizer design.bin qwave.db
transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {LED.vo}

vlog -vlog01compat -work work +incdir+C:/Users/MACHENIKE/Desktop/LED/simulation/modelsim {C:/Users/MACHENIKE/Desktop/LED/simulation/modelsim/LED.vt}

vsim -t 1ps -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  tb

add wave *
view structure
view signals
run -all

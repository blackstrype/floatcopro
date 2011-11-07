# Placez ici le nom du répertoire de sources
src_dir =  ../src
pack_file = ${src_dir}/float_pack.sv
# Corrigez ces lignes pour que les nom des champs (s,exposant,mantisse) corresponde au noms que vous avez utilisé
vlog_option_23_8 =  +define+TB_EXP_SIZE=8 +define+TB_MANT_SIZE=23 +define+SIGN=s +define+EXP=exposant +define+MANT=mantisse
vlog_option_8_4 =  +define+TB_EXP_SIZE=4 +define+TB_MANT_SIZE=8 +define+SIGN=s +define+EXP=exposant +define+MANT=mantisse


all: simu_float_conv_23_8 simu_float_mult_23_8 simu_float_div_23_8 simu_float_add_23_8 simu_float_conv_8_4  simu_float_mult_8_4 simu_float_div_8_4 simu_float_add_8_4 


simu_float_add_8_4: .tb_float_add_8_4 
	vsim -c tb_float_add -do "run -all"
	touch simu_float_add_8_4
	cp add.dat add_8_4.dat

simu_float_div_8_4: .tb_float_div_8_4 
	vsim -c tb_float_div -do "run -all"
	touch simu_float_div_8_4
	cp div.dat div_8_4.dat

simu_float_mult_8_4: .tb_float_mult_8_4 
	vsim -c tb_float_mult -do "run -all"
	touch simu_float_mult_8_4
	cp mult.dat mult_8_4.dat

simu_float_conv_8_4: .tb_float_conv_8_4 
	vsim -c tb_float_conv -do "run -all"
	touch simu_float_conv_8_4
	cp conv.dat conv_8_4.dat

.tb_float_add_8_4: .floatpack_8_4 .tb_float_pack_8_4
	vlog ${vlog_option_8_4} tb_float_add.sv
	touch .tb_float_add_8_4

.tb_float_div_8_4: .floatpack_8_4 .tb_float_pack_8_4
	vlog ${vlog_option_8_4} tb_float_div.sv
	touch .tb_float_div_8_4

.tb_float_mult_8_4: .floatpack_8_4 .tb_float_pack_8_4
	vlog ${vlog_option_8_4} tb_float_mult.sv
	touch .tb_float_mult_8_4

.tb_float_conv_8_4: .floatpack_8_4 .tb_float_pack_8_4
	vlog ${vlog_option_8_4} tb_float_conv.sv
	touch .tb_float_conv_8_4

.floatpack_8_4: work 
	vlog ${vlog_option_8_4} ${pack_file}
	touch .floatpack_8_4

.tb_float_pack_8_4: work 
	vlog ${vlog_option_8_4} tb_float_pack.svp
	touch .tb_floatpack_8_4

simu_float_add_23_8: .tb_float_add_23_8 
	vsim -c tb_float_add -do "run -all"
	touch simu_float_add_23_8
	cp add.dat add_23_8.dat

simu_float_div_23_8: .tb_float_div_23_8 
	vsim -c tb_float_div -do "run -all"
	touch simu_float_div_23_8
	cp div.dat div_23_8.dat

simu_float_mult_23_8: .tb_float_mult_23_8 
	vsim -c tb_float_mult -do "run -all"
	touch simu_float_mult_23_8
	cp mult.dat mult_23_8.dat

simu_float_conv_23_8: .tb_float_conv_23_8 
	vsim -c tb_float_conv -do "run -all"
	touch simu_float_conv_23_8
	cp conv.dat conv_23_8.dat

.tb_float_add_23_8: .floatpack_23_8 .tb_float_pack_23_8
	vlog ${vlog_option_23_8} tb_float_add.sv
	touch .tb_float_add_23_8

.tb_float_div_23_8: .floatpack_23_8 .tb_float_pack_23_8
	vlog ${vlog_option_23_8} tb_float_div.sv
	touch .tb_float_div_23_8

.tb_float_mult_23_8: .floatpack_23_8 .tb_float_pack_23_8
	vlog ${vlog_option_23_8} tb_float_mult.sv
	touch .tb_float_mult_23_8

.tb_float_conv_23_8: .floatpack_23_8 .tb_float_pack_23_8
	vlog ${vlog_option_23_8} tb_float_conv.sv
	touch .tb_float_conv_23_8

.floatpack_23_8: work 
	vlog ${vlog_option_23_8} ${pack_file}
	touch .floatpack_23_8

.tb_float_pack_23_8: work 
	vlog ${vlog_option_23_8} tb_float_pack.svp
	touch .tb_floatpack_23_8

work: 
	@rm -rf work
	vlib work

clean:
	@rm -rf *.dat
	@rm -rf .simu_float*
	@rm -rf .tb_float*
	@rm -rf .floatpack*
	@rm -rf work 
	@rm -rf transcript
	@rm -rf vsim.wlf
	@rm -rf wl*
	@rm simu_*

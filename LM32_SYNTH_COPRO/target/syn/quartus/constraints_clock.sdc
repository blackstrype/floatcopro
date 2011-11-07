# Create generated clocks based on PLLs
#
derive_pll_clocks -use_tan_name
#
# ------------------------------------------


# Original Clock Setting Name: 50MHZ
#
create_clock -period "20.000 ns" -name {CLOCK_50MHz} [get_ports CLOCK_50]
#
# ---------------------------------------------

# Set Multicycle Path
#
set_multicycle_path  -hold -from [get_registers {float_copro:COPROi|op0*}] -to [get_registers {float_copro:COPROi|copro_result*}] 11
set_multicycle_path  -hold -from [get_registers {float_copro:COPROi|op1*}] -to [get_registers {float_copro:COPROi|copro_result*}] 11
set_multicycle_path  -setup -end -from [get_registers {float_copro:COPROi|op0*}] -to [get_registers {float_copro:COPROi|copro_result*}] 11
set_multicycle_path  -setup -end -from [get_registers {float_copro:COPROi|op1*}] -to [get_registers {float_copro:COPROi|copro_result*}] 11


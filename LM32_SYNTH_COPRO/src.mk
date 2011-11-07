##########################################
#                Modules                 #
##########################################

LM32_MODULES = lm32_adder            \
			   lm32_addsub           \
			   lm32_cpu              \
			   lm32_dcache           \
			   lm32_decoder          \
			   lm32_icache           \
			   lm32_instruction_unit \
			   lm32_interrupt        \
			   lm32_load_store_unit  \
			   lm32_logic_op         \
			   lm32_mc_arithmetic    \
			   lm32_monitor          \
			   lm32_multiplier       \
			   lm32_ram              \
			   lm32_shifter          \
			   lm32_top

SOC_MODULES = wb_conbus_arb \
			  wb_conbus_top \
			  wb_timer      \
			  wb_bram       \
			  uart          \
			  wb_uart       \
			  wb_sram16

COPRO_MODULES= float_pack float_copro_dp float_copro 

SOC_TOP = system

TARGET_MODULES = pll \
				 DE2_TOP


GLOBAL_INCLUDE = $(dir $(shell find $(TOPDIR)/src -regex '.*/$(SOC_TOP)\.[s]?v' ))

COPRO_SRC_DIR = $(TOPDIR)/copro_src
SRC_DIR = $(TOPDIR)/src
TARGET_DIR = $(TOPDIR)/target/src

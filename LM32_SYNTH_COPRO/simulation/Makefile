include  $(TOPDIR)/src.mk

CURRENT_DIR = $(shell pwd)
TEST_BENCH   = test_bench_DE2 
TEST_MODULES = sram_model  \
			   $(TEST_BENCH)
SC_MODULES  = xtermtty 

MODULES = $(LM32_MODULES)  $(SOC_MODULES) $(SOC_TOP)


SIMLIB = -L altera_mf_ver
.PHONY: all clean simu compile

all: simu

work:
	vlib $@

simu: compile
	vsim    -t 1ps $(SIMLIB) $(TEST_BENCH)

compile: $(MODULES) $(TARGET_MODULES) $(TEST_MODULES) $(SC_MODULES) $(COPRO_MODULES)

# Templates for modules compilation
# TODO: When modules have upper case letters in their names, modelsim generates
# the _primary.dat file in a directory where the upper case letter letters are
# replaces by @ followed by a lower case letter
define COMPILE_rule
$(1) : .$(1).compiled
$(1)_VSRC = $(shell find $(2) -regex ".*[/]?$(1)\.[s]?v")
$(1)_DEP  = $(shell find $(2) -regex ".*[/]?$(1)\.dep")

ifneq ($$($(1)_DEP),)
include $$($(1)_DEP)
endif

ifneq ($$($(1)_VSRC),)
.$(1).compiled: $$($(1)_VSRC) | work
	vlog +acc  +incdir+$$(GLOBAL_INCLUDE) +incdir+$$(dir $$($(1)_VSRC)) -work work  $$($(1)_VSRC) && touch $$@ 
endif

endef

define SCCOMPILE_rule
$(1) : .$(1).compiled
$(1)_SCSRC= $(shell find $(2) -regex ".*/$(1)\.cpp")

ifneq ($$($(1)_SCSRC),)
.$(1).compiled: $$($(1)_SCSRC) | work
	sccom -work work  $$($(1)_SCSRC) && sccom -link && touch $$@ 
endif

endef

# Rules  automatic generation
$(foreach module,$(COPRO_MODULES), $(eval $(call COMPILE_rule,$(module),$(COPRO_SRC_DIR))))
$(foreach module,$(MODULES),       $(eval $(call COMPILE_rule,$(module),$(SRC_DIR))))
$(foreach module,$(TARGET_MODULES),$(eval $(call COMPILE_rule,$(module),$(TARGET_DIR))))
$(foreach module,$(TEST_MODULES),  $(eval $(call COMPILE_rule,$(module),$(CURRENT_DIR))))
$(foreach module,$(SC_MODULES),    $(eval $(call SCCOMPILE_rule,$(module),$(CURRENT_DIR))))


clean::
	rm -rf work
	rm -f transcript  vsim.wlf 
	rm -f xtermtty.log
	rm -f soft.vm
	rm -f .*.compiled


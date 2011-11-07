export TOPDIR = $(shell pwd)

.PHONY: all clean simu_code bootloader simu syn

all: syn

bootloader:
	make all -C soft

simu_code:
	make simu_copro -C soft

simu:simu_code
	make all -C simulation

syn:bootloader 
	make all -C target/syn

program:
	make -C target/syn program

clean:
	make clean -C soft
	make clean -C simulation
	make clean -C target/syn

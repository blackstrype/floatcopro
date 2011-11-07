# Definition des outils
CC_PREFIX= lm32-elf-
CC = $(CC_PREFIX)gcc
AS = $(CC_PREFIX)as
LD = $(CC_PREFIX)ld
OBJCOPY = $(CC_PREFIX)objcopy

# Le fichier elf cible
SOFT_IMAGE = soft.elf
BIN_IMAGE  = soft.bin
RAM_IMAGE  = soft.ram

# Definition des objets
OBJS       = main.o 

SPECFLAGS  =   -gstabs+ -mmultiply-enabled -mbarrel-shift-enabled
CFLAGS     =  -Wall -g -O3 -I. -ggdb -I$(LIB)/include $(SPECFLAGS)

LD_SCRIPT = sram.ld
LDFLAGS   = $(SPECFLAGS) -L$(LIB) -nostartfiles -T$(LD_SCRIPT) -Wl,--print-map -Wl--cref 

.PHONY: all clean 


all:$(RAM_IMAGE)


$(SOFT_IMAGE): $(OBJS) 
	$(CC)  $(LDFLAGS) -o $@ $(filter %.o,$^) > $(patsubst %.elf,%.ldmap,$@)


%.bin:%.elf
	$(OBJCOPY) -I elf32-lm32 -O binary $< $@

%.ram:%.bin
	od -An -v -w1 -t x1 $< | tr -d [:blank:] | tr -d '\n' > $@

%.o: %.s
	$(AS) $< -o $@

%.o : %.S
	$(CC) -o $@ $(CFLAGS) -c $<

%.o : %.c
	$(CC) -o $@ $(CFLAGS) -c $<

clean :
	rm -f $(RAM_IMAGE) $(BIN_IMAGE) $(SOFT_IMAGE) $(OBJS) *.ldmap


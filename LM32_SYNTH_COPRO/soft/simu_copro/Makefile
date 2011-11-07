# Definition des outils
CC_PREFIX= lm32-elf-
CC = $(CC_PREFIX)gcc
AS = $(CC_PREFIX)as
LD = $(CC_PREFIX)ld
OBJDUMP = $(CC_PREFIX)objdump
OBJCOPY = $(CC_PREFIX)objcopy
SREC_CAT = srec_cat

VPATH = ../common

# Le fichier elf cible
SOFT_IMAGE = soft.elf

# Fichier binaire qui sera enregistré dans la bram
SOFT_VM = soft.vm

# Definition des objets
OBJS       = main.o my_printf.o

SPECFLAGS  =   -mmultiply-enabled -mbarrel-shift-enabled
CPPFLAGS  +=  -I . -I ../common
CFLAGS    +=  -Wall -g -O2 -ggdb $(SPECFLAGS)

LDFLAGS = -Tbootloader.ld -Wl,--print-map -Wl,--cref $(SPECFLAGS)

.PHONY: all clean copy

all: copy

copy: $(SOFT_VM)
	cp $< ../../simulation

%.vm: %.srec
	$(SREC_CAT) $< -Output $@ -Vmem 32

%.srec : %.elf
	$(OBJCOPY)  -O srec $< $@

$(SOFT_IMAGE): $(OBJS) 
	$(CC)  $(LDFLAGS) -o $@ $(filter %.o,$^) > $(patsubst %.elf,%.ldmap,$@)


%.o: %.s
	$(AS) $< -o $@

%.o : %.S
	$(CC) -o $@ $(CFLAGS) -c $<

%.o : %.c
	$(CC) -o $@ $(CPPFLAGS) $(CFLAGS) -c $<

clean :
	rm -f $(SOFT_IMAGE) *.vm *.srec $(OBJS) *.ldmap


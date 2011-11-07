SRCS     = xtermtty tb
COMPILED = $(patsubst %,.%.compiled,$(SRCS))

LINKED   = .LINKED

.PHONY: all clean uclean

all:$(LINKED)
$(LINKED):$(COMPILED)
	sccom -link && touch $@

.%.compiled:%.cpp | work
	sccom -I. $< && touch $@

work:
	vlib work

clean:
	rm -f xtermtty.log
	rm -f transcript
	rm -f vsim.wlf
	rm -f $(LINKED)

uclean:clean
	rm -f $(COMPILED)
	rm -rf work

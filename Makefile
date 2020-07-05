PROJECT_NAME := bin2dec
TOP_MODULE := top

SOURCES := bin2dec.v

CONSTRAINTS := $(PROJECT_NAME).pcf

DEVICE := 1k
PACKAGE := vq100

TEST_TOP_MODULE := $(PROJECT_NAME)_tb
TEST_SOURCES := $(PROJECT_NAME)_tb.v
TEST_EXECUTABLE := test_$(PROJECT_NAME)

########################################################################

all: $(PROJECT_NAME).bin
	@echo 'Build complete!'

$(PROJECT_NAME).bin: $(PROJECT_NAME).asc
	icepack $< $@

$(PROJECT_NAME).asc: $(PROJECT_NAME).blif
	arachne-pnr -d $(DEVICE) -P $(PACKAGE) -p $(CONSTRAINTS) -o $@ $<

$(PROJECT_NAME).blif: $(SOURCES)
	yosys -p 'synth_ice40 -top $(TOP_MODULE) -blif $@' $^

test: $(TEST_EXECUTABLE)
	./$(TEST_EXECUTABLE)

$(TEST_EXECUTABLE): $(SOURCES) $(TEST_SOURCES)
	iverilog -s $(TEST_TOP_MODULE) -o $(TEST_EXECUTABLE) $(SOURCES) $(TEST_SOURCES)

timing: $(PROJECT_NAME).asc
	icetime -mt $<

clean:
	rm -f *.blif *.asc *.bin $(TEST_EXECUTABLE)

.PHONY: all test timing clean

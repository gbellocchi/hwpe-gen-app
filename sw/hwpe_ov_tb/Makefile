ROOT := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
# COMMON_ROOT := $(ROOT)/inc/common

only = pulp
CSRCS = $(wildcard *.c)

-include $(HERO_OV_OPENMP_TESTS)/common/default.mk

ref_sw:
	cd inc/ref_sw && make -s

CFLAGS_PULP += -I$(HERO_HOST_INC_DIR)
#!/bin/bash
./configure --disable-linuxmodule --enable-user-multithread --disable-dynamic-linking CPPFLAGS="-D__STDC_LIMIT_MACROS -I/home/justine/DPDK-1.5.0/x86_64-default-linuxapp-gcc/include" LDFLAGS=-L/home/justine/DPDK-1.5.0/x86_64-default-linuxapp-gcc/lib


default: output/minimed_rf.hex
CC=sdcc
CFLAGS=-I. --verbose
output:
	mkdir output

output/main.rel: main.c 
	$(CC) $(CFLAGS) -c main.c -o output/
output/minimed_rf.rel: minimed_rf.c minimed_rf.h
	$(CC) $(CFLAGS) -c minimed_rf.c -o output/
output/minimed_rf.hex: output/minimed_rf.rel output/main.rel
	$(CC) $(CFLAGS) output/minimed_rf.rel output/main.rel -o output/minimed_rf.hex
install: output/minimed_rf.hex
	cc-tool -n cc1110 --log install.log -ew output/minimed_rf.hex

test_bin: test.c
	gcc -g -o output/test test.c

test: test_bin
	output/test

stress_test_bin: minimed_rf.c stress_test.c
	gcc -g -DMOCK_RADIO -o output/stress_test minimed_rf.c stress_test.c

stress_test: stress_test_bin
	output/stress_test

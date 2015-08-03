
default: output/minimed_rf.hex

output:
	mkdir output

output/main.rel: main.c 
	sdcc -I. -c main.c -o output/
output/minimed_rf.rel: minimed_rf.c minimed_rf.h
	sdcc -I. -c minimed_rf.c -o output/
output/minimed_rf.hex: output/minimed_rf.rel output/main.rel
	sdcc -I. output/minimed_rf.rel output/main.rel -o output/minimed_rf.hex
install: output/minimed_rf.hex
	cc-tool --log install.log -ew output/minimed_rf.hex

test_bin: test.c
	gcc -g -o output/test test.c

test: test_bin
	output/test

stress_test_bin: minimed_rf.c stress_test.c
	gcc -g -DMOCK_RADIO -o output/stress_test minimed_rf.c stress_test.c

stress_test: stress_test_bin
	output/stress_test

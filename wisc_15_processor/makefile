all:
	iverilog cpu.v cpu_tb.v
test:
	iverilog cpu.v cpu_tb.v
	mv a.out ../compiled_tests
	cd ../compiled_tests && ./a.out
	

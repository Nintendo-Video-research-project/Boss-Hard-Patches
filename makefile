.PHONY: all clean

all:
		@mkdir -p build out
		@"C:\armips-v0.11.0-windows-x86\armips.exe" boss.s
		@flips -c code.bin build/patched_code.bin out/code.ips

clean:
		@rm -rf build out
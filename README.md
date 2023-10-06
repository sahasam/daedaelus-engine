# Daedaelus-Engine

This repository holds my work on creating the Daedaelus Protocol Demo. See [Daedaelus](https://daedaelus.com)

This repository is developed with an entirely open source toolchain to ensure platform-independence, and projects can(will) be generated for different FPGA families. Currently, I am testing on a Xilinx KR260, so output products will only be generated for that platform in the near future.

## UART

Due to difficulties getting PL-only ethernet processing on the Xilinx KR260, I've used UART as the backup link protocol. To fit with the expectations of the protocol, the UART standard has been modified to use 64 data bits, and 1 stop bit. [This](https://www.rohde-schwarz.com/us/products/test-and-measurement/essentials-test-equipment/digital-oscilloscopes/understanding-uart_254524.html) is a good reference to understand the UART protocol, and is the reference I used to create this implementation. I have defaulted to 115200 baud and the samples are clocked at 10MHz. However, in an FPGA to FPGA link this is not set in stone and can be pushed much faster. It's limited by the quality of the wires creating the link.


## Tests

Tests have been created with cocotb, a python HDL verification library, and run with pytest. Cocotb is a fast growing verification platform, which is touted for its flexibility and compatibility with commercial and free toolchains.

To run tests, make sure necessary packages are installed, navigate to tb/uart, and run
`pytest -o log_cli=True test.py`

The tests are automated, and will eventually be baked into a CI flow. Waveforms are still useful though, and they will be generated as `vcf` files in the test's `_sim` directory and can be viewed with GTKWave.

#### The repository as it stands now is just a dump of my work over the past few days. I'll clean it up and make it a proper repository in future commits



## Introduction

This design targets the Xilinx KR260 FPGA board.
* FPGA: K26 SoM (xck26-sfvc784-2LV-c)

## Quick start for Ubuntu

### Build FPGA bitstream

Run `make app` in the `fpga` subdirectory to build the bitstream, `.xsa` file, and device tree overlay.  Ensure that the Xilinx Vivado toolchain components are in PATH (source `settings64.sh` in Vivado installation directory).

### Installation

Download an Ubuntu image for the KR260 here: https://ubuntu.com/download/amd-xilinx.  Write the image to an SD card with `dd`, for example:

	xzcat ubuntu.img.xz | dd of=/dev/sdX

Copy files in `fpga/app` to `/lib/firmware/xilinx/ddl_demo` on the KR260.  Also make a copy of the source repo on the KR260 from which the kernel module and userspace tools can be built.

### Testing

On the KR260, run `sudo xmutil unloadapp` to unload the FPGA, then `sudo xmutil loadapp ddl_demo` to load the configuration.

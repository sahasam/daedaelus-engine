# Sahas Munamala
# Created: Thu Oct 05 2023, 02:50PM PDT
# Purpose: Run Cocotb Test Suite

import os

import pytest
from cocotb_test.simulator import run

curdir = os.path.curdir
uart_vsource_dir = os.path.join(curdir, '../../rtl/uart')


def test_uart_rx():
    run(
        verilog_sources=[os.path.join(uart_vsource_dir, 'uart_rx.v')],
        toplevel='uart_rx',
        toplevel_lang='verilog',
        module='test_uart_rx',
        sim_build='uart_rx_sim',
        timescale='1ns/1ns', # ns
        waves=True,
    )

def test_uart_tx():
    run(
        verilog_sources=[os.path.join(uart_vsource_dir, 'uart_tx.v')],
        toplevel='uart_tx',
        toplevel_lang='verilog',
        module='test_uart_tx',
        sim_build='uart_tx_sim',
        timescale='1ns/1ns',
        waves=True,
    )


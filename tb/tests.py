# Sahas Munamala
# Created: Thu Oct 05 2023, 02:50PM PDT
# Purpose: Run Cocotb Test Suite

import os

import pytest
from cocotb_test.simulator import run

curdir = os.path.curdir
rtl_dir = os.path.join(curdir, '../rtl')


def test_uart_rx():
    run(
        verilog_sources=[os.path.join(rtl_dir, 'uart', 'uart_rx.v')],
        toplevel='uart_rx',
        toplevel_lang='verilog',
        module='uart_tests.test_uart_rx',
        sim_build='uart_rx_sim',
        timescale='1ns/1ns', # ns
        waves=True,
    )

def test_uart_tx():
    run(
        verilog_sources=[os.path.join(rtl_dir, 'uart_tx.v')],
        toplevel='uart_tx',
        toplevel_lang='verilog',
        module='uart_tests.test_uart_tx',
        sim_build='uart_tx_sim',
        timescale='1ns/1ns',
        waves=True,
    )

def test_uart_loopback():
    run(
        verilog_sources=[os.path.join(rtl_dir, 'uart_loopback.v')],
        toplevel='uart_loopback',
        toplevel_lang='verilog',
        module='uart_tests.test_uart_loopback',
        sim_build='uart_loopback_sim',
        timescale='1ns/1ns',
        waves=True,
    )


# Sahas Munamala
# Created: Thu Oct 05 2023, 09:38AM PDT
# Purpose: Test uart_tx module


import logging
import random

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.triggers import FallingEdge, RisingEdge, Event, Timer

from uart_interface import UartSink


class TB:
    def __init__(self, dut):
        self._dut = dut

        self.log = logging.getLogger('cocotb.tb')
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 100, units="ns").start())

        self.uart_sink = UartSink(dut.tx, baud=115200, bits=64, stop_bits=1)


@cocotb.test()
async def uart_tx_test(dut):
    """Test the UART TX Interface"""
    tb = TB(dut)

    await Timer(100, units="us")
    await RisingEdge(dut.clk)

    dut.s_axis_tx_tdata.value = BinaryValue(0xdeadbeefdeadbeef)
    dut.s_axis_tx_tvalid.value = 1

    await RisingEdge(dut.clk)
    dut.s_axis_tx_tvalid.value = 0

    await RisingEdge(dut.clk)
    rx_data = await tb.uart_sink.read()
    assert BinaryValue(rx_data) == BinaryValue(0xdeadbeefdeadbeef)

    await Timer(10, units="us")





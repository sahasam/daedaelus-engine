# Sahas Munamala
# Created: Tue Oct 03 2023, 01:00PM PDT
# Purpose: Test UART_RX module

import logging
import random

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.queue import Queue 
from cocotb.triggers import RisingEdge, Event, Timer

from uart_interface import UartSource


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger('cocotb.tb')
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 100, units="ns").start())

        self.uart_source = UartSource(dut.rx, baud=115200, bits=64, stop_bits=1)

    async def send(self, data):
        await self.uart_source.write(data)
        await self.uart_source.wait()
        

@cocotb.test()
async def uart_rx_test(dut):
    """Send a single frame of 64 bits through rx interface"""
    tb = TB(dut)
    dut.m_axis_rx_tready.value = 0

    await tb.send(0xdeadbeefdeadbeef)

    await Timer(20, units="us")
    assert dut.m_axis_rx_tdata.value == BinaryValue(0xdeadbeefdeadbeef)
    assert dut.m_axis_rx_tvalid.value == 1

    await RisingEdge(dut.clk)
    dut.m_axis_rx_tready.value = 1
    await RisingEdge(dut.clk)
    dut.m_axis_rx_tready.value = 0
    await RisingEdge(dut.clk)
    assert dut.m_axis_rx_tvalid.value == 0

    # send 10 frames 
    for _ in range(10):
        await Timer(10+random.randint(0,100), units="us")
        bits_64rand = random.getrandbits(64)
        await tb.send(bits_64rand)
        await Timer(20, units="us")

        await RisingEdge(dut.clk)
        assert dut.m_axis_rx_tdata.value == BinaryValue(bits_64rand)
        
        #pump tready to cycle state machine for next piece of data
        await RisingEdge(dut.clk)
        dut.m_axis_rx_tready.value = 1
        await RisingEdge(dut.clk)
        dut.m_axis_rx_tready.value = 0










# Sahas Munamala
# Created: Tue Oct 03 2023, 01:00PM PDT
# Purpose: Test UART_RX module

import logging

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.queue import Queue 
from cocotb.triggers import RisingEdge, Event, Timer
import random


class UartSource:
    def __init__(self, data, baud=115200, bits=8, stop_bits=1, *args, **kwargs):
        self.log = logging.getLogger(f"cocotb.{data._path}")

        self._data = data
        self._baud = baud
        self._bits = bits
        self._stop_bits = stop_bits


        super().__init__(*args, **kwargs)

        self.active = False
        self.queue = Queue()

        self._idle = Event()

        self._data.setimmediatevalue(1)

        self.log.info( "UART source configuration")
        self.log.info(f" Baud Rate: {self._baud}")
        self.log.info(f" Byte size: {self._bits} bits")
        self.log.info(f" Stop bits: {self._stop_bits} bits")

        self._run_cr = None
        self._restart()

    def _restart(self):
        if self._run_cr is not None:
            self._run_cr.kill()
        self._run_cr = cocotb.start_soon(self._run())

    async def write(self, data):
        await self.queue.put(data)
        self._idle.clear()
    
    async def wait(self):
        await self._idle.wait()

    async def _run(self):
        self.active = False

        bit_t = Timer(8.681, units='us')
        stop_bit_t = Timer(8.681, units='us')

        while True:
            if self.queue.empty():
                self.active = False
                self._idle.set()

            b = await self.queue.get()
            self.active = True

            self.log.info("Write byte 0x%02x", b)

            # start bit
            self._data.value = 0
            await bit_t

            # data bits
            for _ in range(self._bits):
                self._data.value = b & 1
                b >>= 1
                await bit_t

            # stop bit
            self._data.value = 1
            await stop_bit_t



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










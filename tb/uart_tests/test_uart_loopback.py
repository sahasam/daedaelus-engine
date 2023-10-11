# Sahas Munamala
# Sahas Munamala
# Created: Mon Oct 09 2023, 03:47PM PDT

import logging
import random

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.queue import Queue 
from cocotb.triggers import RisingEdge, Event, Timer

from cocotbext.axi import AxiStreamSource, AxiStreamSink, AxiStreamBus

class TB:
    def __init__(self, dut):
        self._dut = dut

        self.log = logging.getLogger('cocotb.tb')
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 100, units="ns").start())

        self.axis_source = AxiStreamSource(
            bus=AxiStreamBus.from_prefix(dut, "s_axis_din"),
            clock=dut.clk
        )

        self.axis_sink = AxiStreamSink (
            bus=AxiStreamBus.from_prefix(dut, "m_axis_dout"),
            clock=dut.clk
        )


    async def send_and_receive(self, data):
        await self.axis_source.send(data)
        data = await self.axis_sink.recv()
        self.log.debug("Received Byte:%x" % data.tdata[0])
        return data.tdata[0]




@cocotb.test()
async def uart_loopback_test(dut):
    """Test the loopback module """
    tb = TB(dut)

    await Timer(100, units="us")

    data = await tb.send_and_receive(b'h')
    assert BinaryValue(data) == BinaryValue(b'h')


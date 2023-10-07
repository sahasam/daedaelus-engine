# Sahas Munamala
# Created: Sat Oct 07 2023, 09:25AM PDT
# Used as a test interface for UART.

import logging

import cocotb
from cocotb.queue import Queue
from cocotb.triggers import FallingEdge, Timer, First, Event


# UART Source. This sits on the RX side, and translates bytes
# to a Serialized UART signal. Enqueue data with .write()
# then use .wait() to be signalled on completion
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

    @property
    def baud(self):
        return self._baud

    @baud.setter
    def baud(self, value):
        self.baud = value
        self._restart()

    @property
    def bits(self):
        return self._bits

    @bits.setter
    def bits(self, value):
        self.bits = value
        self._restart()

    @property
    def stop_bits(self):
        return self._stop_bits

    @stop_bits.setter
    def stop_bits(self, value):
        self.stop_bits = value
        self._restart()

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


# UART Sink. This class sits on the TX side, and automatically detects
# when data is being sent on the TX line. Wait until you are sure the
# data is there then use uartsink.read_nowait(), or use uartsink.read()
# to be notified on frame completion
class UartSink:

    def __init__(self, data, baud=9600, bits=8, stop_bits=1, *args, **kwargs):
        self.log = logging.getLogger(f"cocotb.{data._path}")
        self._data = data
        self._baud = baud
        self._bits = bits
        self._stop_bits = stop_bits

        super().__init__(*args, **kwargs)

        self.active = False
        self.queue = Queue()
        self.sync = Event()

        self.log.info("UART sink configuration:")
        self.log.info("  Baud rate: %d bps", self._baud)
        self.log.info("  Byte size: %d bits", self._bits)
        self.log.info("  Stop bits: %f bits", self._stop_bits)

        self._run_cr = None
        self._restart()

    def _restart(self):
        if self._run_cr is not None:
            self._run_cr.kill()
        self._run_cr = cocotb.start_soon(self._run(self._data, self._baud, self._bits, self._stop_bits))

    @property
    def baud(self):
        return self._baud

    @baud.setter
    def baud(self, value):
        self.baud = value
        self._restart()

    @property
    def bits(self):
        return self._bits

    @bits.setter
    def bits(self, value):
        self.bits = value
        self._restart()

    @property
    def stop_bits(self):
        return self._stop_bits

    @stop_bits.setter
    def stop_bits(self, value):
        self.stop_bits = value
        self._restart()

    async def read(self, count=-1):
        while self.empty():
            self.sync.clear()
            await self.sync.wait()
        return self.read_nowait(count)

    def read_nowait(self, count=-1):
        return self.queue.get_nowait()

    def count(self):
        return self.queue.qsize()

    def empty(self):
        return self.queue.empty()

    def idle(self):
        return not self.active

    def clear(self):
        while not self.queue.empty():
            frame = self.queue.get_nowait()

    async def wait(self, timeout=0, timeout_unit='ns'):
        if not self.empty():
            return
        self.sync.clear()
        if timeout:
            await First(self.sync.wait(), Timer(timeout, timeout_unit))
        else:
            await self.sync.wait()

    async def _run(self, data, baud, bits, stop_bits):
        self.active = False

        half_bit_t = Timer(int(1e9/self.baud/2), 'ns')
        bit_t = Timer(int(1e9/self.baud), 'ns')
        stop_bit_t = Timer(int(1e9/self.baud*stop_bits), 'ns')

        while True:
            await FallingEdge(data)

            self.active = True

            # start bit
            await half_bit_t

            # data bits
            b = 0
            for k in range(bits):
                await bit_t
                b |= bool(data.value.integer) << k

            # stop bit
            await stop_bit_t

            self.log.info("Read byte 0x%02x", b)

            self.queue.put_nowait(b)
            self.sync.set()

            self.active = False




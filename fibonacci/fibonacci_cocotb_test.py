import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer, Combine, First

@cocotb.test()
async def fibonacci_cocotb_test(dut):
    ''' Local Variables ''' 

    ''' Local Coroutines '''
    @cocotb.coroutine
    async def wait_for_done():
        await RisingEdge(dut.done)
        await RisingEdge(dut.clk)

    @cocotb.coroutine
    async def timeout(number_of_cycles):
        cnt = 0
        for c in range(number_of_cycles):
            await RisingEdge(dut.clk)
            cnt = cnt + 1
            if cnt == 100:
                assert 0 , "Timed out waiting for done signal wrong END_COUNT{}".format(dut.END_COUNT)

    ''' Local Tasks '''
    async def reset_dut():
        ''' Initialize '''
        dut.clk.value = 0
        dut.rst.value = 0         
        await Timer(10, units='ns')
        dut.rst.value    = 1
        await Timer(10, units='ns')
        dut.rst.value    = 0

    ''' Reset Generation '''
    await reset_dut()

    ''' Clock Generation '''
    clock_gen = cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    ''' Wait for the done'''
    coro_done = cocotb.start_soon(wait_for_done())
    coro_time = cocotb.start_soon(timeout(100))
    await First(coro_done, coro_time)
    assert dut.result.value == dut.END_COUNT, "Failed on the Fibonacci opartion. Got {}, expected {}".format(dut.result,dut.END_COUNT)
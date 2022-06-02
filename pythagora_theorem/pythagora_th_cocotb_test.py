import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from math import sqrt, floor

@cocotb.test()
async def pythagora_th_cocotb_test(dut):
    ''' Initialize '''
    dut.py_clock.value  = 0
    dut.py_rst.value    = 0
    dut.py_start.value  = 0
    dut.py_s0.value     = 0
    dut.py_s1.value     = 0

    ''' Reset Generation '''
    await Timer(10, units='ns')
    dut.py_rst.value    = 1
    await Timer(10, units='ns')
    dut.py_rst.value    = 0

    ''' Clock Generation '''
    clock = Clock(dut.py_clock, 10, units="ns")
    cocotb.start_soon(clock.start())

    ''' Assign random values to input and start'''
    for i in range(20):
        await RisingEdge(dut.py_clock)
        side0 = random.randint(1, 50)
        side1 = random.randint(1, 50)
        dut.py_s0.value = side0
        dut.py_s1.value = side1
        exp_h = floor(sqrt((side0*side0) + (side1*side1)))
        dut.py_start.value  = 1
        await RisingEdge(dut.py_clock)
        dut.py_start.value  = 0
        await RisingEdge(dut.py_valid)
        await RisingEdge(dut.py_clock)
        await FallingEdge(dut.py_clock)
        assert dut.py_hyp == exp_h, "Failed on the {}th cycle. Got {}, expected {}".format(i,dut.py_hyp,exp_h)
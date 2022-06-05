import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from math import sqrt, floor
from enum import Enum

''' Create Enum Value '''
class Opcode(Enum):
    SUM     = 1
    MULT    = 2
    SUB     = 3
    SQRT    = 4
    DIV     = 5

''' Model of Operations '''
def get_exp_result(op: int, o1: int, o2: int, sel: int) -> int:
    if(op == Opcode.SUM.value):
        return (o1 + o2)
    if(op == Opcode.MULT.value):
        return (o1 * o2)
    if(op == Opcode.SUB.value):
        return (o2 - o1)
    if(op == Opcode.SQRT.value):
        if(sel == 0):
            return floor(sqrt(o2))
        else:
            return floor(sqrt(o1))
    if(op == Opcode.DIV.value):
        return 0

@cocotb.test()
async def calculator_cocotb_test(dut):

    ''' Initialize '''
    dut.calc_clock.value    = 0
    dut.calc_rst.value      = 0 
    dut.opcode.value        = 0
    dut.op_in1.value        = 0
    dut.op_in2.value        = 0
    dut.op_in_sel.value     = 0

    ''' Reset Generation '''
    await Timer(10, units='ns')
    dut.calc_rst.value    = 1
    await Timer(10, units='ns')
    dut.calc_rst.value    = 0

    ''' Clock Generation '''
    clock = Clock(dut.calc_clock, 10, units="ns")
    cocotb.start_soon(clock.start())

    ''' Assign random values to input and start'''
    for elem in Opcode:
        await FallingEdge(dut.calc_clock)
        ''' SUM '''
        dut.opcode.value    = elem.value
        op1                 = random.randint(0, 50)
        op2                 = random.randint(0, 50)
        op_sel              = random.randint(0, 1)
        dut.op_in1.value    = op1
        dut.op_in2.value    = op2
        dut.op_in_sel.value = op_sel
        exp_h               = get_exp_result(elem.value,op1,op2,op_sel)
        await FallingEdge(dut.calc_clock)
        if(dut.valid_res == 1):
            assert dut.result == exp_h, "Failed on the {} opartion. Got {}, expected {}".format(elem.name,dut.result,exp_h)
        else:
            assert dut.result == 0, "Failed on the {} opartion. Got {}, expected {} when result is not valid".format(elem.name,dut.result,0)
        await RisingEdge(dut.calc_clock)
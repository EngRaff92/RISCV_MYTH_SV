from cocotb_test.simulator import run
from glob import glob
import pytest

@pytest.mark.parametrize("parameters", [{"DW" : "32", "DUMP_NAME" : "calculator_dump"}])
def test_calculator(parameters):
    run(
        verilog_sources     = ["./sqrt_c.sv","./en_ff.sv","./calculator.sv",],
        toplevel            = "calculator",                # top level HDL
        module              = "calculator_cocotb_test",    # name of cocotb test module
        simulator           = "icarus",
        verilog_compile_args= ["-g2012"],
        parameters          = parameters,
        extra_env           = parameters,
        sim_build           = "./sim_build/" + ",".join((f"{key}={value}" for key, value in parameters.items())),
    )

@pytest.mark.parametrize("parameters", [
    {   "DW" : "32", 
        "DUMP_NAME" : "calculator_piped_dump",
        "N_OF_STAGES" : "3",
        "IS_PIPED" : "1",
        "IS_FULLY_PIPED" : "1"  }])
def test_calculator_piped(parameters):
    run(
        verilog_sources     = ["./sqrt_c.sv","./pipe_ff.sv","./en_ff.sv","./calculator_piped.sv",],
        toplevel            = "calculator_piped",                # top level HDL
        module              = "calculator_piped_cocotb_test",    # name of cocotb test module
        simulator           = "icarus",
        verilog_compile_args= ["-g2012"],
        parameters          = parameters,
        extra_env           = parameters,
        sim_build           = "./sim_build/" + ",".join((f"{key}={value}" for key, value in parameters.items())),
    )    

@pytest.mark.parametrize("parameters", [
    {   "DW" : "32", 
        "DUMP_NAME" : "calculator_piped_zero_dump",
        "N_OF_STAGES" : "0",
        "IS_PIPED" : "0",
        "IS_FULLY_PIPED" : "0"  }])
def test_calculator_zero_piped(parameters):
    run(
        verilog_sources     = ["./sqrt_c.sv","./pipe_ff.sv","./en_ff.sv","./calculator_piped.sv",],
        toplevel            = "calculator_piped",                # top level HDL
        module              = "calculator_piped_cocotb_test",    # name of cocotb test module
        simulator           = "icarus",
        verilog_compile_args= ["-g2012"],
        parameters          = parameters,
        extra_env           = parameters,
        sim_build           = "./sim_build/" + ",".join((f"{key}={value}" for key, value in parameters.items())),
    ) 